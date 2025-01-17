void integrate (Fluid f) {
    for (int i = 1; i < f.numX; i++) {
      for (int j = 1; j < f.numY - 1; j++) {
        if (f.s[i * f.numY + j] != 0.0 && f.s[i * f.numY + j-1] != 0.0) {
          f.v[i*f.numY + j] += DT * GRAVITY;
        }
      }
    }
  }

float findDivergence (Fluid f, int x, int y) {
  return f.u[IX(x+1, y)] -
         f.u[IX(x, y)] + 
         f.v[IX(x, y+1)] - 
         f.v[IX(x, y)];
}

void forceIncompressibility (Fluid f) {
  for (int iter = 0; iter < ITERS; iter++) {
    
    for (int i = 1; i < f.numX - 1; i++) {
      for (int j = 1; j < f.numY - 1; j++) {
      
        float sAdjacent = f.s[IX(i-1, j)] +
                          f.s[IX(i+1, j)] +
                          f.s[IX(i, j-1)] +
                          f.s[IX(i, j+1)];
        
        if (sAdjacent != 0.0 && f.s[IX(i, j)] != 0.0) {
          float div = findDivergence(f, i, j);
          float pressureCorrection = (-div / sAdjacent) * OVERRELAXATION;
          float adjustmentFactor = f.rho * f.size / DT;
          
          f.p[IX(i, j)] += pressureCorrection * adjustmentFactor;
          f.u[IX(i, j)] -= f.s[IX(i - 1, j)] * pressureCorrection;
          f.u[IX(i + 1, j)] += f.s[IX(i + 1, j)] * pressureCorrection;
          f.v[IX(i, j)] += f.s[IX(i, j - 1)] * pressureCorrection;
          f.v[IX(i, j + 1)] -= f.s[IX(i, j + 1)] * pressureCorrection;
        }
      }
    }
    
  }
}

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

float interpolate (float[] arr, float x, float y, float offsetX, float offsetY, int size, int maxX, int maxY) {
  float gridX = (x - offsetX) / float(size); // fractional x position in grid space
  int iLeft = min(floor(gridX), maxX);
  int iRight = min(iLeft + 1, maxX);
  float xFactor = gridX - iLeft; // interpolation factor in x
  
  float gridY = (y - offsetY) / float(size); // fractional y position in grid space
  int jTop = min(floor(gridY), maxY);
  int jBottom = min(jTop + 1, maxY);
  float yFactor = gridY - jTop; // interpolation factor in y
  
  float v00 = arr[IX(iLeft, jTop)];      // top-left
  float v10 = arr[IX(iRight, jTop)];     // top-right
  float v01 = arr[IX(iLeft, jBottom)];   // bottom-left
  float v11 = arr[IX(iRight, jBottom)];  // bottom-right
  
  return (1 - xFactor) * yFactor       * v00 +
         xFactor       * yFactor       * v10 +
         (1 - xFactor) * (1 - yFactor) * v01 +
         xFactor       * (1 - yFactor) * v11;
  
  
  
}


void advectVel (Fluid f) {
  
  // copied arrays hold the advected results
  arrayCopy(f.u, f.new_u);
  arrayCopy(f.v, f.new_v);
  arrayCopy(f.smoke, f.new_smoke);
  
  for (int i = 1; i < f.numX; i++) {
    for (int j = 1; j < f.numY; j++) {
      // horizontal velocities
      // cells must be active
      if (f.s[IX(i, j)] != 0.0 && f.s[IX(i-1, j)] != 0.0 && j < f.numY - 1) {
        float x = i*f.size;
        float y = (j + 0.5) * f.size;
        float uVel = f.u[IX(i, j)];
        float vVel = (f.v[IX(i, j)] + 
                      f.v[IX(i - 1, j)] + 
                      f.v[IX(i - 1, j + 1)] + 
                      f.v[IX(i, j + 1)]) 
                      * 0.25;
        
        // trace velocities backwards using a semi-Lagrangian approach
        x = constrain(x - DT * uVel, f.size, (f.numX-1) * f.size);
        y = constrain(y - DT * vVel, f.size, (f.numY-1) * f.size);
        
        // read old velocity field that "arrives" at the new (i, j)
        f.new_u[IX(i, j)] = interpolate(f.u, x, y, 0.0, f.size/2, f.size, f.numX-1, f.numY-1);
      }
  
      // vertical velocities
      if (f.s[IX(i, j)] != 0.0 && f.s[IX(i, j - 1)] != 0.0 && i < f.numX - 1) {
        float x = (i + 0.5) * f.size;
        float y = j*f.size;
        float uVel = (f.u[IX(i, j)] + 
                      f.u[IX(i, j - 1)] + 
                      f.u[IX(i + 1, j - 1)] + 
                      f.u[IX(i + 1, j)]) 
                      * 0.25;
        float vVel = f.v[IX(i, j)];

        x = constrain(x - DT * uVel, f.size, (f.numX-1) * f.size);
        y = constrain(y - DT * vVel, f.size, (f.numY-1) * f.size);
        
        f.new_v[IX(i, j)] = interpolate(f.v, x, y, f.size/2, 0.0, f.size, f.numX-1, f.numY-1);
      }
      
      // smoke advection (rendering)
      if (f.s[IX(i, j)] != 0.0 && i < f.numX-1 && j < f.numY-1) {
        float uVel = (f.u[IX(i, j)] + f.u[IX(i + 1, j)]) * 0.5;
        float vVel = (f.v[IX(i, j)] + f.v[IX(i, j + 1)]) * 0.5;
        float x = constrain((i + 0.5) * f.size - (DT * uVel), f.size, (f.numX-1) * f.size);
        float y = constrain((j + 0.5) * f.size - (DT * vVel), f.size, (f.numY-1) * f.size);
        
        f.new_smoke[IX(i, j)] = interpolate(f.smoke, x, y, f.size/2, f.size/2, f.size, f.numX-1, f.numY-1);
      }
      
    }
  }
  
  arrayCopy(f.new_u, f.u);
  arrayCopy(f.new_v, f.v);
  arrayCopy(f.new_smoke, f.smoke);
  
}
