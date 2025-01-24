class Scene {
  // CONSTANTS
  float GRAVITY = -9.81;
  float DT = 1.0 / 60.0;
  int ITERS = 60;
  float OVERRELAXATION = 1.9;
  float DENSITY = 1000.0;
  
  // VARIABLES
  int smoke_size;    // width of smoke
  int smoke_sep;     // separation between adjacent stream lines
  String direction;  // direction of airflow ("left", "right", "up", "down")
  int type;          // smoke pattern ("full", "parallel")
  float invelocity;
  
  boolean show_gravity;
  boolean show_smoke;
  boolean show_pressure;
  
  boolean show_fps = true;
  boolean paused = false;
  
  Scene (int preset) {
    loadPreset(preset);
    setupScene();
  }
  
  void loadPreset (int preset) {
    obstacles.add(new CircleObstacle(width/4.0, height/2.0, N, 75.0));
    
    switch (preset) {
      case 1:
        smoke_size = 25;
        smoke_sep = 25;
        direction = "right";
        type = 1;
        invelocity = 500;
        show_gravity = false;
        show_smoke = true;
        show_pressure = false;
        break;
      case 2:
        smoke_size = 25;
        smoke_sep = 8;
        direction = "right";
        type = 1;
        invelocity = 500;
        show_gravity = false;
        show_smoke = true;
        show_pressure = true;
        break;
      case 3:
        smoke_size = 80;
        smoke_sep = 8;
        direction = "right";
        type = 2;
        invelocity = 500;
        show_gravity = false;
        show_smoke = true;
        show_pressure = false;
        break;
    }
  }
  
  void setupScene() {
    fluid = new Fluid(this, this.DENSITY, N, N, CELLSIZE);
    
    fluid.updateCells(obstacles);
    
    addSmoke(fluid);
  }
  
  void addSmoke(Fluid f) {
    if (type == 0 || type == 1) {
      int lower_bound = 0, upper_bound = 0;
      
      if (type == 0) {
        lower_bound = 0;
        upper_bound = f.numY;
      } else if (type == 1) {
        lower_bound = f.numY/2 - smoke_size/2;
        upper_bound = f.numY/2 + smoke_size/2;
      }
        
      if (direction == "right") {
        for (int j = 0; j < f.numY; j++) {
          if (lower_bound <= j && j <= upper_bound) {f.smoke[j] = 0.0;}
        } 
      } else if (direction == "left") {
        for (int j = 0; j < f.numY; j++) {
          if (lower_bound <= j && j <= upper_bound) {f.smoke[IX(f.numX-1, j)] = 0.0;}
        }
      } else if (direction == "up") {
        for (int i = 0; i < f.numY; i++) {
          if (lower_bound <= i && i <= upper_bound) {f.smoke[IX(i, f.numY-1)] = 0.0;}
        } 
      } else if (direction == "down") {
        for (int i = 0; i < f.numY; i++) {
          if (lower_bound <= i && i <= upper_bound) {f.smoke[IX(i, 0)] = 0.0;}
        }
      }
    }
    
    else if (type == 2) {
      int new_smoke_size = smoke_size / (N/smoke_sep);
      
      if (direction == "right") {
        for (int j = 0; j < f.numY - new_smoke_size; j+=smoke_sep) {
          for (int k = 0; k < new_smoke_size; k++) {f.smoke[j+k] = 0.0;}
        } 
      } else if (direction == "left") {
        for (int j = 0; j < f.numY - new_smoke_size; j+=smoke_sep) {
          for (int k = 0; k < new_smoke_size; k++) {f.smoke[IX(f.numX-3, j+k)] = 0.0;}
        }
      } else if (direction == "up") {
        for (int i = 0; i < f.numY; i++) {
          for (int k = 0; k < new_smoke_size; k++) {f.smoke[IX(i+k, f.numY-3)] = 0.0;}
        } 
      } else if (direction == "down") {
        for (int i = 0; i < f.numY; i++) {
          for (int k = 0; k < new_smoke_size; k++) {f.smoke[IX(i+k, 0)] = 0.0;}
        }
      }
    }
  }
  
  void fpsDisplay() {
    // fps counter
    textAlign(RIGHT, TOP);
    textSize(24);
    fill(125);
    text("fps: " + frameRate, width - 10, 10);
  }
  
}
