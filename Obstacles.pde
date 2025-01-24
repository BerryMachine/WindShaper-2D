//void setDefaultObstacle(Fluid f, float cxFrac, float cyFrac, float radiusFrac) { // eg. radiusFrac = 0.15 means 15% of domain size
//  int cx = int(cxFrac * f.numX);
//  int cy = int(cyFrac * f.numY);
//  float rr = (radiusFrac * min(f.numX, f.numY));
//  rr = rr*rr; // compare squared distances

//  for (int i = 1; i < f.numX-1; i++) {
//    for (int j = 1; j < f.numY-1; j++) {
//      float offsetX = i - cx - 0.5;
//      float offsetY = j - cy - 0.5;
//      if (offsetX*offsetX + offsetY*offsetY < rr) {
//        f.s[IX(i,j)] = 0.0;
//        f.u[IX(i,j)] = 0;
//        f.u[IX(i+1,j)] = 0;
//        f.v[IX(i,j)] = 0;
//        f.v[IX(i,j+1)] = 0;
//      }
//    }
//  }
//}

abstract class Obstacle {
  PVector origin; // center (or reference) position in pixel units
  String type, status; // "awaiting" -> is waiting for another input to finish creating the object
                       // "moving" -> is being translated by the dragging of the mouse
                       // "static" -> is in a still state
  int N, numCells;
  boolean[] s;

  Obstacle (String type, float x, float y, int N) {
    x = constrain(x, 2, N*CELLSIZE);
    y = constrain(y, 2, N*CELLSIZE);
    this.type = type;
    this.origin = new PVector(x, y);
    this.N = N;
    this.numCells = (N+2)*(N+2);
    this.s = new boolean[numCells];
  }
  
  abstract void setupObstacle();

  abstract void drawObstacle(color c);
  
  abstract boolean clicked(float x, float y);
  
  abstract void moveObstacle(float x, float y);
}
