class LineObstacle extends Obstacle {
  PVector endpoint; // secondary point of line
  PVector clicked_point; // where the object was clicked
  float thickness = 4; // thickness
  
  LineObstacle (float x, float y, int N) {
    super("LINE", x, y, N);
    this.endpoint = origin.copy();
  }
  
  LineObstacle (float x, float y, int N, float x1, float y1) {
    super("LINE", x, y, N);
    this.endpoint = new PVector(x1, y1);
    setupObstacle();
    this.status = "static";
  }
  
  @Override void setupObstacle() {
    this.s = new boolean[numCells];

    // compute bounding box in pixel coords
    float minXpix = min(origin.x, endpoint.x) - thickness;
    float maxXpix = max(origin.x, endpoint.x) + thickness;
    float minYpix = min(origin.y, endpoint.y) - thickness;
    float maxYpix = max(origin.y, endpoint.y) + thickness;

    // convert bounding box to grid indices
    int minXcell = constrain(floor(minXpix / CELLSIZE), 2, N);
    int maxXcell = constrain(ceil(maxXpix  / CELLSIZE), 2, N);
    int minYcell = constrain(floor(minYpix / CELLSIZE), 2, N);
    int maxYcell = constrain(ceil(maxYpix  / CELLSIZE), 2, N);

    // store vectors
    PVector A = origin.copy();
    PVector B = endpoint.copy();
    PVector AB = PVector.sub(B, A);

    float AB_lengthSq = AB.magSq(); // squared length of the line segment

    for (int i = minXcell; i < maxXcell; i++) {
      for (int j = minYcell; j < maxYcell; j++) {
        // center of cell (i,j) in pixel coords
        PVector cellCenter = new PVector((i+0.5f)*CELLSIZE, (j+0.5f)*CELLSIZE);
        float distToLine = pointToSegmentDist(cellCenter, A, B, AB, AB_lengthSq); // calculate distance

        if (distToLine <= thickness) { // take into account thickness of line
          s[IX(i,j)] = true;
        }
      }
    }
  }
  
  float pointToSegmentDist(PVector P, PVector A, PVector B,
                           PVector AB, float AB_lengthSq) {

    if (AB_lengthSq == 0) { // A and B at same point
      return P.dist(A);
    }

    // project AP onto AB
    PVector AP = PVector.sub(P, A);
    float t = PVector.dot(AP, AB) / AB_lengthSq;
    t = constrain(t, 0, 1);

    // nearest point on segment
    PVector nearest = PVector.add(A, PVector.mult(AB, t));

    // return distance from P to that nearest point
    return P.dist(nearest);
  }

  @Override void drawObstacle(color c) {
    stroke(c);
    if (status == "awaiting") {
      strokeWeight(2);
      noFill();
      line(origin.x, origin.y, endpoint.x, endpoint.y);
    }
    else if (status == "static") {
      strokeWeight(thickness); // set thickness
      noFill();
      line(origin.x, origin.y, endpoint.x, endpoint.y);
      strokeWeight(1); // reset afterwards
    }
  }
  
  @Override
  boolean clicked(float x, float y) {
    PVector P = new PVector(x, y);
    // if distance <= thickness then it is clicked
    float dist = pointToSegmentDist(P, origin, endpoint,
      PVector.sub(endpoint, origin),
      PVector.sub(endpoint, origin).magSq());
    if (dist <= thickness) {
      clicked_point = new PVector(x, y);
      return true;
    }
    else {
      return false;
    }
  }
  
    @Override
  void moveObstacle(float x, float y) {
    if (status == "awaiting") { // origin is fixed, so clamp endpoint
      endpoint.x = constrain(x, 2, N*CELLSIZE-2);
      endpoint.y = constrain(y, 2, N*CELLSIZE-2);

    } else if (status == "moving") {
      // shift the entire line by offset = mouse - clicked point
      float dx = x - clicked_point.x;
      float dy = y - clicked_point.y;

      // update both endpoints
      origin.x += dx;
      origin.y += dy;
      endpoint.x += dx;
      endpoint.y += dy;

      // clamp endpoints (may unfortunately change line shape if user hits the edges)
      origin.x   = constrain(origin.x,   thickness, N*CELLSIZE-thickness);
      origin.y   = constrain(origin.y,   thickness, N*CELLSIZE-thickness);
      endpoint.x = constrain(endpoint.x, thickness, N*CELLSIZE-thickness);
      endpoint.y = constrain(endpoint.y, thickness, N*CELLSIZE-thickness);

      // reset clicked point
      clicked_point = new PVector(x, y);
    }
    // refresh obstacle coverage
    setupObstacle();
  }
}
