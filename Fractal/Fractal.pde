int WindowSizeX = 1920;
int WindowSizeY = 1080;
color BgColor = color(255, 255, 255);

float _strutFactor = 0.05;

class Root{
  PVector[] Polygon;
  color Color;
  Branch _Branch;

  Root(int n_points, float radius, color _color){
    Color = _color;
    Polygon = new PVector[n_points];

    float angle = TWO_PI / n_points;

    for (int i = 0; i < n_points; i += 1) {
      float a = angle * i;
      float sx = cos(a) * radius;
      float sy = sin(a) * radius;
      Polygon[i] = new PVector(sx, sy);
    }

    _Branch = new Branch(0, 0, Polygon, Color);
  }

  void display(){
    pushMatrix();
    translate(WindowSizeX/2, WindowSizeY/2);
    beginShape();
    for (int i = 0; i < Polygon.length; i += 1) {
      stroke(Color);
      strokeWeight(2);
      vertex(Polygon[i].x, Polygon[i].y);
    }
    endShape(CLOSE);
    popMatrix();
  }

}

class Branch{
  int level;
  int n;
  PVector[] Polygon;
  color Color;

  Branch(int _level, int _n, PVector[] _Polygon, color _color){
    level = _level;
    n = _n;
    Polygon = strut_points(mid_points(_Polygon));
    Color = _color;
  }

  void display(){
    pushMatrix();
    translate(WindowSizeX/2, WindowSizeY/2);
    beginShape();
    for (int i = 0; i < Polygon.length; i += 1) {
      stroke(Color);
      strokeWeight(2);
      vertex(Polygon[i].x, Polygon[i].y);
    }
    endShape(CLOSE);
    popMatrix();
  }

  PVector[] mid_points(PVector[] _Polygon){
    PVector[] MidPoints = new PVector[_Polygon.length];

    int next_i;
    for (int i = 0; i < _Polygon.length; ++i) {
      if (i == _Polygon.length - 1){
        next_i = 0;
      } else {
        next_i = i + 1;
      }
      MidPoints[i] = PVector.mult(PVector.add(_Polygon[i], _Polygon[next_i]), 0.5); 
    }

    return MidPoints;
  }

  PVector[] strut_points(PVector[] _Polygon){
    PVector[] StrutPoints = new PVector[_Polygon.length];

    int next_i;
    for (int i = 0; i < _Polygon.length; ++i) {
      next_i = i + 3;
      if (next_i >= _Polygon.length) { 
        next_i -= _Polygon.length; 
      }
      StrutPoints[i] = strut_2points(_Polygon[i], _Polygon[next_i]);
    }

    return StrutPoints;
  }

  PVector strut_2points(PVector _Point1, PVector _Point2){
    float px, py;
    float adj, opp;

    opp = abs(_Point2.x - _Point1.x);
    adj = abs(_Point2.y - _Point1.y);

    px = _Point1.x - Math.signum((int) (_Point1.x - _Point2.x)) * (opp * _strutFactor);
    py = _Point1.y - Math.signum((int) (_Point1.y - _Point2.y)) *(adj * _strutFactor);

    return new PVector(px, py);

  }

}

void settings() {
  size(WindowSizeX, WindowSizeY);
}

void setup() {
  frameRate(60);
  noFill();
}

void draw() {
  background(BgColor);
  Root Root0 = new Root(5, 400, color(0, 0, 0));
  Root0.display();
  Root0._Branch.display();
  
}