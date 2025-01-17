int IX(int x, int y) {
  return (x*(N+2)) + y;
}

class Fluid {
  float rho;                     // density
  int numX, numY, numCells;      // grid size
  int size;                      // cell size
  float[] s;                     // 1.0 if fluid cell, 0.0 if wall cell
  float[] u;                     // velocities left/right per cell
  float[] v;                     // velocities up/down per ecll
  float[] new_u;                 // temp velocities u
  float[] new_v;                 // temp velocities v
  float[] p;                     // pressure per cell
  float[] smoke;                 // smoke density per cell (for rendering)
  float[] new_smoke;             // temp smoke density

  Fluid (float density, int n, int size) {
    this.rho = density;
    this.numX = n + 2;
    this.numY = n + 2;
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

    this.fluidSetup();
  }

  void fluidSetup() {
    for (int i = 0; i < numX; i++) {
      for (int j = 0; j < numY; j++) {
        int idx = IX(i, j);
        float init_s = 1.0; // fluid
        
        if (i == 0 || j == 0 || j == numY) {init_s = 0.0;}
        s[idx] = init_s;

        if (i == 1) {u[idx] = INVELOCITY;}
        
        smoke[idx] = 1.0;
      }
    }
    
    int jTop = numY/2 - 10;
    int jBottom = numY/2 + 19;
    for (int j = jTop; j < jBottom; j++) {
      smoke[j] = 0.0;
    }
  }
  
  void resetPressure () {
    for (int i = 0; i < numX; i++) {
      for (int j = 0; j < numY; j++) {
        p[IX(i, j)] = 0.0;
        //if (i == 1) {u[IX(i, j)] = INVELOCITY;}
        u[IX(i, j)] = INVELOCITY;
      }
    }
  }

  void step() {
    // integrate
    integrate(this);
    // reset pressure
    this.resetPressure();
    // projection to solve divergence
    forceIncompressibility(this);
    // boundary handling
    closedBoundaries(this);
    // advect velocity & smoke
    advectVel(this);
  }
}
