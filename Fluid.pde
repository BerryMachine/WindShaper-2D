int IX (int x, int y) { // hashing
  return (x * (N + 2)) + y;
}

class Fluid {
  Scene sc;
  float rho;                  // density
  int numX, numY, numCells;   // grid size
  int size;                   // cell size
  float[] s;                  // 1.0 if fluid cell, 0.0 if wall cell
  float[] u;                  // velocities left/right per cell
  float[] v;                  // velocities up/down per ecll
  float[] new_u;              // temp velocities u
  float[] new_v;              // temp velocities v
  float[] p;                  // pressure per cell
  float[] smoke;              // smoke density per cell (for rendering)
  float[] new_smoke;          // temp smoke density
  
  Fluid (Scene sc, float density, int numX, int numY, int size) {
    this.sc = sc;
    this.rho = density;
    this.numX = numX + 2;
    this.numY = numY + 2;
    this.numCells = this.numX * this.numY;
    this.size = size;
    this.s = new float[numCells];
    this.u = new float[numCells];
    this.v = new float[numCells];
    this.new_u = new float[numCells];
    this.new_v = new float[numCells];
    this.p = new float[numCells];
    this.smoke = new float[numCells];
    this.new_smoke = new float[numCells];
    
    setupFluid();
  }
  
  void setupFluid () {
    for (int i = 0; i < numX; i++) {
      for (int j = 0; j < numY; j++) {
        int idx = IX(i, j);
        // default values
        float init_s = 1.0;
        float init_u = 0.0;
        float init_v = 0.0;
        float init_smoke = 1.0;
        
        // boundary conditions based on direction
        if (sc.direction == 0) { // left -> right
          if (i==0 || j==0 || j==numY-1) {init_s = 0.0;}
          if (i==1) {init_u = sc.invelocity;}
          
        } else if (sc.direction == 1) { // left <- right
          if (i==numX-1 || j==0 || j==numY-1) {init_s = 0.0;}
          if (i==numX-1) {init_u = -sc.invelocity;}
          
        } else if (sc.direction == 2) { // down -> up
          if (i==0 || i==numX-1 || j==numY-1) {init_s = 0.0;}
          if (j==numY-1) {init_v = -sc.invelocity;}
          
        } else if (sc.direction == 3) { // down <- up
          if (i==0 || i==numX-1 || j==0) {init_s = 0.0;}
          if (j==1) {init_v = sc.invelocity;}
        }
        
        s[idx] = init_s;
        u[idx] = init_u;
        v[idx] = init_v;
        smoke[idx] = init_smoke;
      }
    }
  }
  
  void updateCells (ArrayList<Obstacle> obstacles) {
    // ignore boundary
    for (int i = 2; i < numX-2; i++) {
      for (int j = 2; j < numY-2; j++) {
        int idx = IX(i, j);
        boolean is_fluid = true; // initial value
        for (Obstacle obs : obstacles) { // if any obstacle overlaps with a cell, turn it into a solid cell
          if (obs.s[idx]) {
            s[idx] = 0.0;
            // zero velocity:
            u[IX(i, j)] = 0;
            u[IX(i+1, j)] = 0;
            v[IX(i, j)] = 0;
            v[IX(i, j+1)] = 0;
            is_fluid = false;
            break;
          }
        }
        if (is_fluid) {this.s[idx] = 1.0;}
      }
    }
  }
  
  // zero pressure
  void resetPressure () {
    for (int i=0; i<numCells; i++) {
      p[i] = 0;
    }
  }
  
  // order of computation following Navier-Stokes Equations
  void step () {
    
    if (sc.show_gravity) {
      integrate(this, sc.DT, sc.GRAVITY);
    }
    
    resetPressure();
    
    forceIncompressibility(this, sc.ITERS, sc.DT, sc.OVERRELAXATION);
    
    closedBoundaries(this);
    
    advection(this, sc.DT);
  }
  
  // rendering
  void drawFluid () {
  
    // find min/max pressure
    float minP = p[0];
    float maxP = p[0];
    for (int i = 0; i < numCells; i++) {
      if (p[i] < minP) minP = p[i];
      if (p[i] > maxP) maxP = p[i];
    }
  
    // loop over each cell of the fluid
    for (int i = 0; i < numX; i++) {
      for (int j = 0; j < numY; j++) {
  
        // default white
        float r = 255;
        float g = 255;
        float b = 255;
      
        if (scene.show_pressure) {
          // If it's a solid cell
          if (s[IX(i, j)] == 0.0) {
            r = 255; g = 255; b = 255;
          }
          
          else {
            // pressure colormap
            float pVal = p[IX(i, j)];
            int[] pColor = getSciColor(pVal, minP, maxP);
            r = pColor[0];
            g = pColor[1];
            b = pColor[2];
  
            // darken if there is smoke
            if (scene.show_smoke) {
              float smokeVal = smoke[IX(i, j)];
              r = max(0, r - 255*smokeVal);
              g = max(0, g - 255*smokeVal);
              b = max(0, b - 255*smokeVal);
            }
          }
        }
        
        else if (scene.show_smoke) {
  
          if (s[IX(i, j)] == 0.0) { // blacks cells for black
            r = 0; g = 0; b = 0;
          }
          
          else {
            // grayscale smoke from 0..1 -> 25..255
            float sVal = smoke[IX(i, j)];
            r = 25 + 230 * sVal; // slightly brighter such that obstacles always visible
            g = 25 + 230 * sVal;
            b = 25 + 230 * sVal;
          }
          
        }
        
  
        noStroke();
        fill(r, g, b);
        rect(i*size, j*size, size, size);
      }
    }
  }
  
}

// blend colors
int[] getSciColor(float val, float minVal, float maxVal) {
  // clamp
  val = constrain(val, minVal, maxVal - 0.0001);
  
  // normalize t
  float d = maxVal - minVal;
  float t = (d == 0) ? 0.5 : (val - minVal) / d;
  
  // segment width
  float segWidth = 0.25;
  int seg = floor(t / segWidth); // figure out corner we are in
  float segT = (t - seg*segWidth) / segWidth;

  // interpolate color transitions
  float r,g,b;
  switch (seg) {
    case 0: r=0;   g=segT; b=1;   break;
    case 1: r=0;   g=1;    b=1-segT; break;
    case 2: r=segT;g=1;    b=0;   break;
    default: r=1;  g=1-segT; b=0; break;
  }

  // convert to 0 -> 255
  return new int[]{ int(255*r), int(255*g), int(255*b) };
}
