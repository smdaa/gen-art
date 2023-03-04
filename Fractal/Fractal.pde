int WindowSizeX = 1920;
int WindowSizeY = 1080;
color BgColor = color(255, 255, 255);

float initialradius = 1000;
float radius = initialradius;
float radius_step = 2;
int n_points = 5;
int rep = 50;
PVector[] poly;

color[] _colors;

color[] init_colors(int rep){
  color[] _colors = new color[rep];

  color _color1 = color(#F6E1C3);
  color _color2 = color(#E9A178);
  color _color3 = color(#A84448);
  color _color4 = color(#7A3E65);
  color[] colors_set = {_color1, _color2, _color3, _color4};

  for (int i = 0; i < rep; i += 1) {
    _colors[i] = colors_set[i%colors_set.length];
  }

  return _colors;

}

PVector[] init_polygon(float radius, int n_points) {
  float angle = TWO_PI / n_points;
  PVector[] poly = new PVector[n_points];

  for (int i = 0; i < n_points; i += 1) {
    float a = angle * i;
    float sx = cos(a) * radius;
    float sy = sin(a) * radius;
    poly[i] = new PVector(sx, sy);
  }

  return poly;
}

PVector[] init_subpolygon(PVector[] poly){
  PVector[] subpolygon = new PVector[poly.length];

  for (int i = 0; i < subpolygon.length-1; ++i) {
    subpolygon[i] = PVector.add(poly[i], poly[i+1]);
    subpolygon[i] = PVector.mult(subpolygon[i], 0.5);
  }
  
  subpolygon[subpolygon.length-1] = PVector.add(poly[0], poly[poly.length-1]);
  subpolygon[subpolygon.length-1] = PVector.mult(subpolygon[subpolygon.length-1], 0.5);

  return subpolygon;
}

void draw_polygon(PVector[] poly, color _color){
  beginShape();
  for (int i = 0; i < poly.length; i += 1) {
    fill(_color);
    vertex(poly[i].x, poly[i].y);
  }
  endShape(CLOSE);
}

void settings() {
  size(WindowSizeX, WindowSizeY);
}

void setup() {
  frameRate(60);
  strokeWeight(2);
  _colors = init_colors(rep);
}

void draw() {
  background(_colors[_colors.length -1]);

  poly = init_polygon(radius, n_points);
  for (int i = 0; i < rep; i+=1){
    pushMatrix();
    translate(WindowSizeX/2, WindowSizeY/2);
    draw_polygon(poly, _colors[i]);
    popMatrix();

    poly = init_subpolygon(poly);
  }

  radius += radius_step;

  if (radius > max(WindowSizeX, WindowSizeY)) {
    //radius = initialradius;
  }
  
}
