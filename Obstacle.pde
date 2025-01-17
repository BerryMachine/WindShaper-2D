int r = 50;

void updateCircleCells (Fluid f, int x, int y) {
  for (int i = 0; i < f.numX; i++) {
    for (int j = 0; j < f.numY; j++) {
      float cellCenterX = (i + 0.5) * CELLSIZE;
      float cellCenterY = (j + 0.5) * CELLSIZE;
      
      float dx = cellCenterX - x;
      float dy = cellCenterY - y;
      float distSq = dx*dx + dy*dy;
      float rSq = r*r;
      
      if (distSq < rSq) {
        f.s[IX(i, j)] = 0.0; // inside circle => inactive
      }
    }
  }
}
