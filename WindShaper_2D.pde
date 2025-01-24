int N = 200;
int CELLSIZE = 4;
Fluid fluid;
Scene scene;
ArrayList<Obstacle> obstacles;
MouseMode mouseMode = MouseMode.CIRCLE;
Obstacle selected;

int init_sc = 1;

void settings () {
  size(N*CELLSIZE, N*CELLSIZE);
}

void setup () {
  obstacles = new ArrayList<Obstacle>();
  // Create a new scene
  scene = new Scene(init_sc);
  rectMode(CORNER);
  ellipseMode(RADIUS);
}

void draw() {
  if (!scene.paused) {
    fluid.step();
    
    // Render fluid
    fluid.drawFluid();
    
    for (Obstacle obs : obstacles) {
      if (scene.show_pressure) {
        obs.drawObstacle(color(255));
      } else {
        obs.drawObstacle(color(0));
      }
    }
  
    if (scene.show_fps) {
      scene.fpsDisplay();
    }
  }
}
