void integrate(Fluid f, float dt, float gravity) {
  // ignore boundary cells
  for (int i = 1; i < f.numX-1; i++) {
    for (int j = 1; j < f.numY-1; j++) {
      if (f.s[IX(i, j)] != 0 && f.s[IX(i, j-1)] != 0) {
        f.v[IX(i, j)] -= gravity * 10 * dt; // substract scaled gravity because origin is top-left
      }
    }
  }
}


float findDivergence (Fluid f, int x, int y) {
  return (f.u[IX(x+1, y)] - f.u[IX(x, y)]) + // cancel opposing forces
         (f.v[IX(x, y+1)] - f.v[IX(x, y)]);
}

/* OLD CODE WITHOUT PARALLEL PROCESSING
void forceIncompressibility (Fluid f, int iters, float dt, float overrelaxation) {
  for (int iter = 0; iter < iters; iter++) {
    for (int i = 1; i < f.numX-1; i++) {
      for (int j = 1; j < f.numY-1; j++) {
        float sAdj = f.s[IX(i-1, j)] +
                     f.s[IX(i+1, j)] +
                     f.s[IX(i, j-1)] +
                     f.s[IX(i, j+1)];
                     
        if (sAdj == 0.0 || f.s[IX(i, j)] == 0.0) {continue;}
        
        float div = findDivergence(f, i, j);
        float pressureCorrection = (-div / sAdj) * overrelaxation;
        float adjustmentFactor = f.rho * f.size / dt;
        
        f.p[IX(i,   j)] += adjustmentFactor * pressureCorrection;
        f.u[IX(i,   j)] -= f.s[IX(i-1, j)] * pressureCorrection;
        f.u[IX(i+1, j)] += f.s[IX(i+1, j)] * pressureCorrection;
        f.v[IX(i,   j)] -= f.s[IX(i, j-1)] * pressureCorrection;
        f.v[IX(i, j+1)] += f.s[IX(i, j+1)] * pressureCorrection;
      }
    }
    
  }
}
*/


void forceIncompressibility(Fluid f, int iters, float dt, float overrelaxation) {
  float adjustmentFactor = f.rho * f.size / dt;

  for (int iter = 0; iter < iters; iter++) {
    
    // RED SWEEP
    for (int i = 1; i < f.numX-1; i++) {
      for (int j = 1; j < f.numY-1; j++) {
        
        // update cells where (i + j) % 2 == 0  (red cells)
        if ((i + j) % 2 == 0) {
          
          // skip if solid
          float sAdj = f.s[IX(i-1, j)] +
                       f.s[IX(i+1, j)] +
                       f.s[IX(i, j-1)] +
                       f.s[IX(i, j+1)];
          if (sAdj == 0.0 || f.s[IX(i, j)] == 0.0) {
            continue;
          }

          // compute divergence
          float div = findDivergence(f, i, j);

          // pressure correction (Gauss–Seidel update)
          float pressureCorrection = (-div / sAdj) * overrelaxation;
          
          // update pressure
          f.p[IX(i, j)] += adjustmentFactor * pressureCorrection;

          // Subtract/add gradient from/to neighboring velocities
          f.u[IX(i,   j)] -= f.s[IX(i-1, j)] * pressureCorrection;
          f.u[IX(i+1, j)] += f.s[IX(i+1, j)] * pressureCorrection;
          f.v[IX(i,   j)] -= f.s[IX(i, j-1)] * pressureCorrection;
          f.v[IX(i, j+1)] += f.s[IX(i, j+1)] * pressureCorrection;
        }
      }
    }

    // BLACK SWEEP
    for (int i = 1; i < f.numX-1; i++) {
      for (int j = 1; j < f.numY-1; j++) {
        
        // update cells where (i + j) % 2 == 1 (black cells)
        if ((i + j) % 2 == 1) {
          
          float sAdj = f.s[IX(i-1, j)] +
                       f.s[IX(i+1, j)] +
                       f.s[IX(i, j-1)] +
                       f.s[IX(i, j+1)];
          if (sAdj == 0.0 || f.s[IX(i, j)] == 0.0) {
            continue;
          }

          float div = findDivergence(f, i, j);
          float pressureCorrection = (-div / sAdj) * overrelaxation;
          
          f.p[IX(i, j)] += adjustmentFactor * pressureCorrection;

          f.u[IX(i,   j)] -= f.s[IX(i-1, j)] * pressureCorrection;
          f.u[IX(i+1, j)] += f.s[IX(i+1, j)] * pressureCorrection;
          f.v[IX(i,   j)] -= f.s[IX(i, j-1)] * pressureCorrection;
          f.v[IX(i, j+1)] += f.s[IX(i, j+1)] * pressureCorrection;
        }
      }
    }
  }
}

// boundary behaviour
// copies interior velocity to prevent fluid leakage
void closedBoundaries (Fluid f) {
  for (int i = 0; i < f.numX; i++) {
    f.u[IX(i, 0)] = f.u[IX(i, 1)];
    f.u[IX(i, f.numY - 1)] = f.u[IX(i, f.numY - 2)];
  }
  for (int j = 0; j < f.numY; j++) {
    f.v[IX(0, j)] = f.v[IX(1, j)];
    f.v[IX(f.numX - 1, j)] = f.v[IX(f.numX - 2, j)];
  }
}

void openBoundaries (Fluid f) {
  for (int i = 0; i < f.numX; i++) {
    // TOP EDGE (y = 0)
    if (f.v[IX(i, f.numY - 1)] < 0) {
      f.v[IX(i, f.numY - 1)] = 0;
    }
    
    // BOTTOM EDGE (y = numY - 1)
    if (f.v[IX(i, 0)] > 0) {
      f.v[IX(i, 0)] = 0;
    }
  }
  
  for (int j = 0; j < f.numY; j++) {
    // LEFT EDGE (x = 0)
    if (f.u[IX(0, j)] > 0) {
      f.u[IX(0, j)] = 0;
    }
  
    // RIGHT EDGE (x = numX - 1)
    if (f.u[IX(f.numX - 1, j)] < 0) {
      f.u[IX(f.numX - 1, j)] = 0;
    }
  }
}

// bilinear interpolation
// offset values let us sample cell-centered data
float interpolate (Fluid f, float[] arr, float x, float y, float offsetX, float offsetY) {
  float gridX = (x - offsetX) / float(f.size); // grid index 
  int iLeft = floor(gridX);
  int iRight = min(iLeft + 1, f.numX - 1);
  float xFactor = gridX - iLeft; // weight
  
  float gridY = (y - offsetY) / float(f.size);
  int jTop = floor(gridY);
  int jBottom = min(jTop + 1, f.numY - 1);
  float yFactor = gridY - jTop;
  
  float v00 = arr[IX(iLeft, jTop)];      // top-left
  float v10 = arr[IX(iRight, jTop)];     // top-right
  float v01 = arr[IX(iLeft, jBottom)];   // bottom-left
  float v11 = arr[IX(iRight, jBottom)];  // bottom-right
  
  return (1 - xFactor) * (1 - yFactor) * v00 +
         xFactor       * (1 - yFactor) * v10 +
         (1 - xFactor) * yFactor       * v01 +
         xFactor       * yFactor       * v11;
}

// fetch/move velocities
void advection (Fluid f, float dt) {
  arrayCopy(f.u, f.new_u);
  arrayCopy(f.v, f.new_v);
  arrayCopy(f.smoke, f.new_smoke);
  
  for (int i = 1; i < f.numX; i++) {
    for (int j = 1; j < f.numY; j++) {
      // horizontal velocities
      // cells must be active
      if (f.s[IX(i, j)] != 0 && f.s[IX(i-1, j)] != 0 && j < f.numY - 1) {
        float x = i*f.size;
        float y = (j + 0.5) * f.size;
        float uVel = f.u[IX(i, j)];
        float vVel = (f.v[IX(i, j)] + 
                      f.v[IX(i-1, j)] +
                      f.v[IX(i-1, j+1)] +
                      f.v[IX(i, j+1)]) * 0.25;
        
        // Semi-Lagrangian backtrace
        x = constrain(x - dt * uVel, f.size, (f.numX-1) * f.size);
        y = constrain(y - dt * vVel, f.size, (f.numY-1) * f.size);
        
        // read old velocity field that "arrives" at the new (i, j)
        f.new_u[IX(i, j)] = interpolate(f, f.u, x, y, 0.0, f.size*0.5);
      }
      
      // vertical velocities
      if (f.s[IX(i, j)] != 0 && f.s[IX(i, j-1)] != 0 && i < f.numX - 1) {
        float x = (i + 0.5) * f.size;
        float y = j*f.size;
        float uVel = (f.u[IX(i, j)] + 
                      f.u[IX(i, j - 1)] + 
                      f.u[IX(i + 1, j - 1)] + 
                      f.u[IX(i + 1, j)]) * 0.25;
        float vVel = f.v[IX(i, j)];
        
        x = constrain(x - dt * uVel, f.size, (f.numX-1) * f.size);
        y = constrain(y - dt * vVel, f.size, (f.numY-1) * f.size);
        
        f.new_v[IX(i, j)] = interpolate(f, f.v, x, y, f.size/2, 0);
      }
      
      // smoke advection
      if (f.s[IX(i, j)] != 0 && i < f.numX-1 && j < f.numY-1) {
        float uVel = (f.u[IX(i, j)] + f.u[IX(i+1, j)]) * 0.5;
        float vVel = (f.v[IX(i, j)] + f.v[IX(i, j+1)]) * 0.5;
        float x = constrain((i + 0.5) * f.size - (dt * uVel), f.size, (f.numX-1) * f.size);
        float y = constrain((j + 0.5) * f.size - (dt * vVel), f.size, (f.numY-1) * f.size);
        
        f.new_smoke[IX(i, j)] = interpolate(f, f.smoke, x, y, f.size/2, f.size/2);
      }
    }
  }
  
  arrayCopy(f.new_u, f.u);
  arrayCopy(f.new_v, f.v);
  arrayCopy(f.new_smoke, f.smoke);
}
