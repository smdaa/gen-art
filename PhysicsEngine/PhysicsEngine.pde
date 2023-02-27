int WindowSizeX = 1920;
int WindowSizeY = 1080;
color BgColor = color(0, 0, 0);

PhysicsWorld PhysicsWorld;
float dt = 0.5;

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

  void CheckObjectDetection(Object other) {
    PVector DistanceVec = PVector.sub(Position, other.Position);
    PVector VelocityVec = PVector.sub(Velocity, other.Velocity);
    float DistanceSq = DistanceVec.magSq();
    if (DistanceSq < (Radius + other.Radius)*(Radius + other.Radius)) {
      // collision occurred

      // https://en.wikipedia.org/wiki/Elastic_collision
      float factor = PVector.dot(VelocityVec, DistanceVec);
      factor = (((2*other.Mass)/(other.Mass+Mass))*factor) / DistanceSq;
      PVector temp = PVector.mult(DistanceVec, factor);
      Velocity.sub(temp);

      float otherfactor = PVector.dot(VelocityVec, DistanceVec);
      otherfactor = (((2*Mass)/(other.Mass+Mass))*otherfactor) / DistanceSq;
      PVector othertemp = PVector.mult(DistanceVec, -otherfactor);
      other.Velocity.sub(othertemp);
    }
  }


  void Draw() {
    noStroke();
    fill(Color);
    ellipse(Position.x, Position.y, Radius*2, Radius*2);
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

      object.CheckEdgeDetection();

      object.Force.add(PVector.mult(Gravity, object.Mass));
      object.Velocity.add(PVector.mult(object.Force, (1/object.Mass)*dt));
      object.Position.add(PVector.mult(object.Velocity, dt));
      object.Force = new PVector(0.0, 0.0, 0.0);


      for (int i = 1+Objects.indexOf(object); i <Objects.size(); i++) {
        object.CheckObjectDetection( Objects.get(i));
      }
    }
  }

  void Draw() {
    for (Object object : Objects) {
      object.Draw();
    }
  }

  void DrawObjectsConnections() {
    stroke(255, 0, 0);
    for (int i = 0; i < Objects.size(); ++i) {
      for (int j = i+1; j < Objects.size(); ++j) {
        PVector Position1 = Objects.get(j).Position;
        PVector Position2 = Objects.get(i).Position;
        line(Position1.x, Position1.y, Position2.x, Position2.y);
      }
    }
  }
}

void settings() {
  size(WindowSizeX, WindowSizeY);
}

void setup() {
  background(BgColor);
  PhysicsWorld = new PhysicsWorld();

  float Radius1 = 50;
  float Radius2 = 50;
  float Radius3 = 50;

  PVector Position1 = new PVector(WindowSizeX/4, WindowSizeY-Radius1);
  PVector Position2 = new PVector(3*WindowSizeX/4, WindowSizeY-Radius2);
  PVector Position3 = new PVector(WindowSizeX/2, WindowSizeY-Radius3);

  PVector Velocity1 = new PVector(50, 0);
  PVector Velocity2 = new PVector(-50, 0);
  PVector Velocity3 = new PVector(0, 0);

  PVector Force1 = new PVector(0.0, 0.0);
  PVector Force2 = new PVector(0.0, 0.0);
  PVector Force3 = new PVector(0.0, 0.0);

  float Mass1 = 10;
  float Mass2 = 10;
  float Mass3 = 10;

  color Color1 = color(126, 126, 126);
  color Color2 = color(126, 126, 126);
  color Color3 = color(126, 126, 126);

  Object Object1 = new Object(Position1, Velocity1, Force1, Mass1, Radius1, Color1);
  Object Object2 = new Object(Position2, Velocity2, Force2, Mass2, Radius2, Color2);
  Object Object3 = new Object(Position3, Velocity3, Force3, Mass3, Radius3, Color3);

  PhysicsWorld.AddObject(Object1);
  PhysicsWorld.AddObject(Object2);
  PhysicsWorld.AddObject(Object3);
}

void draw() {
  background(BgColor);
  PhysicsWorld.Step(dt);
  PhysicsWorld.Draw();
  PhysicsWorld.DrawObjectsConnections();
}
