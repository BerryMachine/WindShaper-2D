enum MouseMode {
  MOVE,         // "MOVE" -> select existing shape obstacles to move
  DELETE,       // "DELETE" -> delete shape obstacles
  CIRCLE,       // "CIRCLE" -> create circle obstacle
  LINE,         // "LINE" -> create line obstacle
}


// ensure only one toggle is active at once
void changeMouseMode(MouseMode mode, GImageToggleButton source) {
  if (source.getState() == 1) { // if ON
    mouseMode = mode;
    for (GImageToggleButton button : mouseModeButtons) { // switch off all others
      if (button != source) {
          button.setState(0);
      }
    }
  }
}

void mousePressed () {
  switch (mouseMode) {
    case MOVE:
      // check mouse contact with any component
      // most recently created component has priority
      for (int i = obstacles.size()-1; i >= 0; i--) { // iterate backwards through the components of the layer
        Obstacle obs = obstacles.get(i);
        if (obs.clicked(mouseX, mouseY)) {
          selected = obs;
          selected.status = "moving";
          break;
        }
      }
      break;
    
    case DELETE: 
      // check mouse contact with any component
      // most recently created component has priority
      for (int i = obstacles.size()-1; i >= 0; i--) { // iterate backwards through the components of the layer
        Obstacle obs = obstacles.get(i);
        if (obs.clicked(mouseX, mouseY)) {
          obstacles.remove(i);
          fluid.updateCells(obstacles); // recompute which cells are solid/fluid
          break;
        }
      }
      break;
      
    case CIRCLE:
      if (mouseX > 0 && mouseX < N*CELLSIZE && mouseY > 0 && mouseY < N*CELLSIZE) {
        Obstacle obs = new CircleObstacle(constrain(mouseX, 75+2, N*CELLSIZE-75), constrain(mouseY, 75+2, N*CELLSIZE-75), N);
        obstacles.add(obs);
        selected = obs;
        selected.status = "awaiting"; // wait for set radius
      }
      break;
      
    case LINE:
      if (mouseX > 0 && mouseX < N*CELLSIZE && mouseY > 0 && mouseY < N*CELLSIZE) {
        Obstacle obs = new LineObstacle(mouseX, mouseY, N);
        obstacles.add(obs);
        selected = obs;
        selected.status = "awaiting"; // wait for endpoint
      }
      break;
  }
}

void mouseDragged () {
  if (selected != null) {
    switch (mouseMode) {
      case MOVE: // update new position
        selected.moveObstacle(mouseX, mouseY);
        fluid.updateCells(obstacles);
        break;
        
      case CIRCLE: // update radius
        if (selected.status == "awaiting") {
          selected.moveObstacle(mouseX, mouseY);
        }
        break;
        
      case LINE: // update endpoint
        if (selected.status == "awaiting") {
          selected.moveObstacle(mouseX, mouseY);
        }
        break;
    }
    
  }
}

void mouseReleased () { // reset all
  if (selected != null) {
    switch (mouseMode) {
      case MOVE:
        selected.status = "static";
        break;
      
      case CIRCLE:
        if (selected.status == "awaiting") {
          selected.setupObstacle();
          selected.status = "static";
          fluid.updateCells(obstacles);
        }
        break;
      
      case LINE:
        if (selected.status == "awaiting") {
          selected.setupObstacle();
          selected.status = "static";
          fluid.updateCells(obstacles);
        }
      
    }
    
    selected = null;
  }
}
