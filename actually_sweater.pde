// CONSTANTS
int N = 128;
int CELLSIZE = 4;
float DT = 0.02;
int ITERS = 40;
float OVERRELAXATION = 1.9;
float GRAVITY = 0;
float DENSITY = 1000.0;
float INVELOCITY = 50.0;
String SRC = "left";


// VARIABLES
color bg = 255;

Fluid f;

void settings() {
  size(N*CELLSIZE, N*CELLSIZE);
}

void setup() {
  f = new Fluid(DENSITY, N, CELLSIZE);
 //frameRate(4);
 rectMode(CORNER);
 ellipseMode(RADIUS);
 updateCircleCells(f, N, N);
}

void draw() {
  background(bg);
  
  f.step();
  
  float minP = f.p[0];
  float maxP = f.p[0];
  for (int i = 0; i < f.numCells; i++) {
    if (f.p[i] < minP) {minP = f.p[i];}
    if (f.p[i] > maxP) {maxP = f.p[i];}
  }
  
  //loadPixels();
  
  for (int i = 0; i < f.numX; i++) {
    for (int j = 0; j < f.numY; j++) {
      float greyscale = 255;
      
      float sVal = f.smoke[IX(i, j)];
      greyscale *= sVal;
      
      if (f.s[IX(i, j)] == 0.0) {
        greyscale = 0;
      }
      
      noStroke();
      fill(greyscale);
      rect(i * CELLSIZE, j * CELLSIZE, CELLSIZE, CELLSIZE);
      
      
    }
  }
}
