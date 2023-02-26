int WindowSizeX = 1920;
int WindowSizeY = 1080;
color BgColor = color(0, 0, 0);

PhysicsWorld PhysicsWorld;
float dt = 0.05;

int Nobjects = 10;

class Object {
  PVector Position;
  PVector Velocity;
  PVector Force;
  float Mass;
  float Radius;
  color Color;

  Object(PVector position, PVector velocity, PVector force, float mass, float radius, color _color) {
    Position = position;
    Velocity = velocity;
    Force = force;
    Mass = mass;
    Radius = radius;
    Color = _color;
  }

  void CheckEdgeDetection() {
    if (Position.x - Radius < 0) {
      Position.x = Radius;
      Velocity.x = -1 *Velocity.x;
    } else if (Position.x + Radius > WindowSizeX) {
      Position.x = WindowSizeX - Radius;
      Velocity.x = -1 *Velocity.x;
    } else if (Position.y - Radius < 0) {
      Position.y = Radius;
      Velocity.y = -1 *Velocity.y;
    } else if (Position.y + Radius > WindowSizeY) {
      Position.y = WindowSizeY - Radius;
      Velocity.y = -1 *Velocity.y;
    }
  }

  void CheckObjectDetection(Object object) {

  }
  

  void Draw() {
    noStroke();
    fill(Color);
    circle(Position.x, Position.y, Radius);
  }
}

class PhysicsWorld {
  ArrayList<Object> Objects = new ArrayList<Object>();
  ;
  PVector Gravity = new PVector(0, 9.81f, 0);

  void AddObject(Object object) {
    Objects.add(object);
  }

  void RemoveObject(Object object) {
    Objects.remove(object);
  }

  void Step(float dt) {
    for (Object object : Objects) {
      object.Force.add(PVector.mult(Gravity, object.Mass));
      object.Velocity.add(PVector.mult(object.Force, (1/object.Mass)*dt));
      object.Position.add(PVector.mult(object.Velocity, dt));
      object.Force = new PVector(0.0, 0.0, 0.0);

      object.CheckEdgeDetection();
      
    }
  }

  void Draw() {
    for (Object object : Objects) {
      object.Draw();
    }
  }
}

void settings() {
  size(WindowSizeX, WindowSizeY);
}

void setup() {
  background(BgColor);
  PhysicsWorld = new PhysicsWorld();

  for (int i = 0; i < Nobjects; i++) {
    Object Object = new Object(new PVector(random(WindowSizeX), random(WindowSizeY)), new PVector(random(50), random(5)), new PVector(0.0, 0.0), 10, 10, color(255, 255, 255));
    PhysicsWorld.AddObject(Object);
  }
}

void draw() {
  background(BgColor);
  PhysicsWorld.Step(dt);
  PhysicsWorld.Draw();
}
