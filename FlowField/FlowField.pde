int windowSizeX = 1920;
int windowSizeY = 1080;
color bgColor = color(0, 0, 0, 100);

int gridResolution = 5;
int gridMargin = 100;
int nRows;
int nColumns;
float[][] Grid;
int arrowLength = 15;
color arrowColor = color(255, 255, 255);

float noiseScale = 20;

int nPoints = 1000;
PVector[][] Points;
color[] Colors;
float stepLength = 10;

float Time = 0;
float timeStep = 0.1;
float timeMax = 200;

boolean showGrid = false;

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
      Grid[i][j] = noise(j/noiseScale, i/noiseScale, Time/noiseScale) * 2 * PI;
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
  Points = new PVector[2][nPoints];
  for (int i = 0; i < nPoints; i++) {
    Points[0][i] = new PVector(windowSizeX + gridMargin, random(windowSizeY + gridMargin));
    Points[1][i] = Points[0][i].copy();
  }
}

void updatePoints() {
  for (int i = 0; i < nPoints; i++) {
    int rowIndex =(int)Points[0][i].y / gridResolution;
    int columnIndex =(int)Points[0][i].x / gridResolution;
    rowIndex = min(rowIndex, nRows - 1);
    columnIndex = min(columnIndex, nColumns - 1);
    float angle = Grid[rowIndex][columnIndex];

    float newX = Points[0][i].x + stepLength * cos(angle);
    float newY = Points[0][i].y + stepLength * sin(angle);

    if (newX > windowSizeX + gridMargin || newY > windowSizeY + gridMargin || newX < 0 || newY < 0) {
      newX = windowSizeX + gridMargin;
      newY = random(windowSizeY + gridMargin);

      Points[0][i].x = newX;
      Points[0][i].y = newY;

      Points[1][i].x = newX;
      Points[1][i].y = newY;
    } else {
      Points[1][i].x = Points[0][i].x;
      Points[1][i].y = Points[0][i].y;

      Points[0][i].x = newX;
      Points[0][i].y = newY;
    }
  }
}

void drawPoints() {
  for (int i = 0; i < nPoints; i++) {
    stroke(Colors[i]);
    strokeWeight(3);
    line(Points[1][i].x, Points[1][i].y, Points[0][i].x, Points[0][i].y);
  }
}

void initColors(color c1, color c2) {
  Colors = new color[nPoints];
  for (int i = 0; i < nPoints; i++) {
    float inter = map(i, 0, nPoints-1, 0, 1);
    Colors[i] = lerpColor(c1, c2, inter);
  }
}

void settings() {
  size(windowSizeX, windowSizeY);
}
void setup() {
  background(bgColor);

  initGrid();
  initPoints();
  initColors(color(#7EE8F5, 5), color(#F27EF5, 5));
}

void draw() {
  if (Time < timeMax) {
    updateGrid();
    if (showGrid) {
      drawGrid();
    }
    updatePoints();
    drawPoints();

    Time = Time + timeStep;
  }
}
