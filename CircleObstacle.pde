class CircleObstacle extends Obstacle {
  float radius = 75;

  CircleObstacle (float x, float y, int N) {
    super("CIRCLE", x, y, N);
  }

  CircleObstacle (float x, float y, int N, float r) {
    super("CIRCLE", x, y, N);
    this.radius = r;
    setupObstacle();
  }

  @Override void setupObstacle () {
    this.s = new boolean[numCells];
    int minX = constrain(floor((origin.x - radius)/CELLSIZE), 2, N);
    int maxX = constrain(ceil((origin.x + radius)/CELLSIZE), 2, N);
    int minY = constrain(floor((origin.y - radius)/CELLSIZE), 2, N);
    int maxY = constrain(ceil((origin.y + radius)/CELLSIZE), 2, N);
    for (int i = minX; i < maxX; i++) {
      for (int j = minY; j < maxY; j++) {
        PVector mid_cell = new PVector((i+0.5)*CELLSIZE, (j+0.5)*CELLSIZE);
        if (origin.dist(mid_cell) <= radius) {
          s[IX(i, j)] = true;
        }  
  
      }
    }
  }
//          // Mark solid
//          f.s[IX(i, j)] = 0.0;
//          // Optionally zero velocity:
//          f.u[IX(i, j)] = 0;
//          f.u[IX(i+1, j)] = 0;
//          f.v[IX(i, j)] = 0;
//          f.v[IX(i, j+1)] = 0;


  @Override void drawObstacle(color c) {
    if (status == "awaiting") {
    stroke(c);
    noFill();
    circle(origin.x, origin.y, radius);
    }
    
    else if (status == "static") {
      stroke(c);
      fill(c);
      circle(origin.x, origin.y, radius);
    }
  }
  
  @Override boolean clicked(float x, float y) {
    if (origin.dist(new PVector(x, y)) <= radius) {
      return true;
    } else {return false;}
  }
  
  @Override void moveObstacle(float x, float y) {
    if (status == "awaiting") {
      radius = origin.dist(new PVector(x, y));
      origin.x = constrain(origin.x, 2+radius, N*CELLSIZE-radius);
      origin.y = constrain(origin.y, 2+radius, N*CELLSIZE-radius);
    }
    
    else if (status == "moving") {
      x = constrain(x, 2+radius, N*CELLSIZE-radius);
      y = constrain(y, 2+radius, N*CELLSIZE-radius);
      origin = new PVector(x, y);
      setupObstacle();
    }
  }
  
}
