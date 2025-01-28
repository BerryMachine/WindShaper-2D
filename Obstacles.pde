abstract class Obstacle {
  PVector origin; // center (or reference) position in pixel units
  String type;   // used to determine which type of obstacle to init during obstacle reading
  String status; // "awaiting" -> is waiting for another input to finish creating the object
                       // "moving" -> is being translated by the dragging of the mouse
                       // "static" -> is in a still state
  int N, numCells;
  boolean[] s;

  Obstacle (String type, float x, float y, int N) {
    x = constrain(x, 2, N*CELLSIZE); // boundaries
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
