import g4p_controls.*;

// GLOBAL VARIABLES & CONSTANTS

GImageToggleButton[] mouseModeButtons; // array of toggle buttons for mouse operations (move, delete, circle, line)

int N = 200; // number of cells in each dimension for the fluid grid
int CELLSIZE = 4; // pixel size of each fluid cell
Fluid fluid; // Fluid simulation object
Scene scene; // scene object brings everything together
ArrayList<Obstacle> obstacles; // list of all obstacles to facilitate drawing, adding, and deleting
MouseMode mouseMode = MouseMode.MOVE; // current mouse behavior
Obstacle selected;

int init_sc = 2; // initial scene at startup

void settings () {
  size(N*CELLSIZE, N*CELLSIZE);
}

void setup () {
  // init obstacle list
  obstacles = new ArrayList<Obstacle>();
  
  // create a new scene
  scene = new Scene(init_sc);
  
  // drawing modes
  rectMode(CORNER);
  ellipseMode(RADIUS);
  
  // init GUI elements
  createGUI();
  
  // sync GUI elements with scene settings
  customGUI();
  
  mouseModeButtons = new GImageToggleButton[]{
    toolMove, toolDelete, toolCircle, toolLine
  };
}

void draw() {
  if (!scene.paused) { // if not paused
    fluid.step(); // compute one frame/timestep of fluid simulation
  }

  // render fluid
  fluid.drawFluid();
  
  // draw obstacles
  drawObstacles();
  
  // fps text
  if (scene.show_fps) {
    scene.fpsDisplay();
  }
 
}

void drawObstacles () {
  // loop all obstacles
  for (Obstacle obs : obstacles) { // color adjustment to match scene
    if (scene.show_pressure) {
      obs.drawObstacle(color(255));
    } else {
      obs.drawObstacle(color(0));
    }
  }
}


void customGUI () {
  // synch GUI to current scene settings
  ShowGravityCheck.setSelected(scene.show_gravity);
  ShowPressureCheck.setSelected(scene.show_pressure);
  ShowSmokeCheck.setSelected(scene.show_smoke);
  FPSCheck.setSelected(scene.show_fps);
  StreamlineCheck.setSelected(scene.show_streamline);
  SmokeSepSlider.setLimits(scene.smoke_sep, 1, 50);
  SmokeSizeSlider.setLimits(scene.smoke_size, 1, 100);
  InvelocitySlider.setLimits(scene.invelocity, 100.0, 1000.0);
  
  InvelocityDirection.setSelected(scene.direction);
  
}
