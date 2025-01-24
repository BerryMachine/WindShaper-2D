enum MouseMode {
  MOVE,         // "MOVE" -> select existing shape obstacles to move
  CIRCLE,       // "CIRCLE" -> create circle obstacle
  POLYGON,      // "POLYGON" -> create polygon obstacle
  DELETE,       // "DELETE" -> delete shape obstacles
  PAINT,        // "PAINT" -> set cells the mouse clicks as non-fluid
  ERASE         // "ERASE" -> reset cells the mouse clicks back as fluid
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
    case CIRCLE:
      if (mouseX > 0 && mouseX < N*CELLSIZE && mouseY > 0 && mouseY < N*CELLSIZE) {
        Obstacle obs = new CircleObstacle(constrain(mouseX, 75+2, N*CELLSIZE-75), constrain(mouseY, 75+2, N*CELLSIZE-75), N);
        obstacles.add(obs);
        selected = obs;
        selected.status = "awaiting";
      }
  }
}

void mouseDragged () {
  if (selected != null) {
    if (selected.status == "awaiting") {
      selected.moveObstacle(mouseX, mouseY);
    }
    switch (mouseMode) {
      case MOVE:
        selected.moveObstacle(mouseX, mouseY);
        fluid.updateCells(obstacles);
    }
  }
}

void mouseReleased () {
  selected = null;
}
