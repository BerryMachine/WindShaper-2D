class CircleObstacle extends Obstacle {
  float radius = 75;

  CircleObstacle (float x, float y, int N) {
    super("CIRCLE", x, y, N);
  }

  CircleObstacle (float x, float y, int N, float r) {
    super("CIRCLE", x, y, N);
    this.radius = r;
    setupObstacle();
    this.status = "static";
  } // immediate constructor

  @Override void setupObstacle () {
    this.s = new boolean[numCells];
    // prune for efficiency
    int minX = constrain(floor((origin.x - radius)/CELLSIZE), 2, N);
    int maxX = constrain(ceil((origin.x + radius)/CELLSIZE), 2, N);
    int minY = constrain(floor((origin.y - radius)/CELLSIZE), 2, N);
    int maxY = constrain(ceil((origin.y + radius)/CELLSIZE), 2, N);
    for (int i = minX; i < maxX; i++) {
      for (int j = minY; j < maxY; j++) {
        PVector mid_cell = new PVector((i+0.5)*CELLSIZE, (j+0.5)*CELLSIZE);
        if (origin.dist(mid_cell) <= radius) { // whether cell is in circle or not
          s[IX(i, j)] = true; // indicate solid cell
        }  
  
      }
    }
  }

  @Override void drawObstacle(color c) {
    if (status == "awaiting") { // outline
      stroke(c);
      noFill();
      circle(origin.x, origin.y, radius);
    }
    
    else if (status == "static") {
      noStroke();
      fill(c);
      circle(origin.x, origin.y, radius);
    }
  }
  
  @Override boolean clicked(float x, float y) { // check if mouse clicked on it
    if (origin.dist(new PVector(x, y)) <= radius) {
      return true;
    } else {return false;}
  }
  
  @Override void moveObstacle(float x, float y) {
    if (status == "awaiting") {
      radius = constrain(origin.dist(new PVector(x, y)), CELLSIZE/2, N); // boundaries
      origin.x = constrain(origin.x, 2+radius, N*CELLSIZE-radius);
      origin.y = constrain(origin.y, 2+radius, N*CELLSIZE-radius);
    }
    
    else if (status == "moving") {
      x = constrain(x, 2+radius, N*CELLSIZE-radius); // boundaries
      y = constrain(y, 2+radius, N*CELLSIZE-radius); 
      origin = new PVector(x, y);
      setupObstacle();
      drawObstacles();
    }
  }
  
}
