int windowSizeX = 1920;
int windowSizeY = 1080;
color bgColor = color(0, 0, 0);

int gridResolution = 100;
int gridMargin = 100;
int nRows;
int nColumns;
float[][] Grid;

int arrowLength = 15;
color arrowColor = color(255, 255, 255);

float noise_scale = 10;

int nPoints = 100;
PVector[] Points;
float stepLength = 5;

void drawArrow(int cx, int cy, int len, float angle, color c) {
  pushMatrix();
  translate(cx, cy);
  rotate(angle);
  stroke(c);
  line(0, 0, len, 0);
  line(len, 0, len - 4, -4);
  line(len, 0, len - 4, 4);
  popMatrix();
}

void initGrid() {
  nRows = (int)(windowSizeY + gridMargin) / gridResolution;
  nColumns = (int)(windowSizeX + gridMargin) / gridResolution;

  Grid = new float[nRows][nColumns];

  for (int i = 0; i < nRows; i++) {
    for (int j = 0; j < nColumns; j++) {
      Grid[i][j] = 0.0;
    }
  }
}

void updateGrid() {
  for (int i = 0; i < nRows; i++) {
    for (int j = 0; j < nColumns; j++) {
      Grid[i][j] = noise(i/noise_scale, j/noise_scale, second()/noise_scale) * 2 * PI;
    }
  }
}

void drawGrid() {
  for (int i = 0; i < nRows; i++) {
    for (int j = 0; j < nColumns; j++) {
      float angle = Grid[i][j];
      int y = (i * gridResolution);
      int x = (j * gridResolution);
      drawArrow(x, y, arrowLength, angle, arrowColor);
    }
  }
}

void initPoints() {
  Points = new PVector[nPoints];
  for (int i = 0; i < nPoints; i++) {
    Points[i] = new PVector(0, random(windowSizeY + gridMargin));
  }
}

void updatePoints(){
  for (int i = 0; i < nPoints; i++) {
    int rowIndex =(int)Points[i].y / gridResolution;
    int columnIndex =(int)Points[i].x / gridResolution;
    float angle = Grid[rowIndex][columnIndex];
    
    float newX = Points[i].x + stepLength * cos(angle);
    float newY = Points[i].y + stepLength * sin(angle);
    
    if (newX > windowSizeX + gridMargin || newY > windowSizeY + gridMargin || newX < 0 || newY < 0){
      newX = 0.0;
      newY = random(windowSizeY + gridMargin);
    }
    
    Points[i].x = newX;
    Points[i].y = newY;

    
  }
}

void drawPoints() {
  for (int i = 0; i < nPoints; i++) {
    fill(255, 255, 255);
    circle(Points[i].x, Points[i].y, 10);
  }
}

void settings() {
  size(windowSizeX, windowSizeY);
}
void setup() {
  frameRate(60);
  initGrid();
  initPoints();
}

void draw() {
  background(bgColor);
  updateGrid();
  //drawGrid();
  drawPoints();
}
