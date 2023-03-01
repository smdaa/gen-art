int WindowSizeX = 1920;
int WindowSizeY = 1080;
color BgColor = color(0, 0, 0);

PhysicsWorld PhysicsWorld;
float dt = 0.001;

int Nobjects = 5000;

class Object {
  PVector Position;
  PVector Velocity;
  float Mass;
  float Radius;
  color Color;

  Object(PVector position, PVector velocity, float mass, float radius, color _color) {
    Position = position;
    Velocity = velocity;
    Mass = mass;
    Radius = radius;
    Color = _color;
  }

  void CheckEdgeDetection() {
    if (Position.x - Radius < 0) {
      Position.x = Radius;
      Velocity.x = -1 * Velocity.x;
    } else if (Position.x + Radius > WindowSizeX) {
      Position.x = WindowSizeX - Radius;
      Velocity.x = -1 * Velocity.x;
    } else if (Position.y - Radius < 0) {
      Position.y = Radius;
      Velocity.y = -1 * Velocity.y;
    } else if (Position.y + Radius > WindowSizeY) {
      Position.y = WindowSizeY - Radius;
      Velocity.y = -1 * Velocity.y;
    }
  }

  void CheckObjectDetection(Object other) {
    PVector DistanceVec = PVector.sub(Position, other.Position);
    PVector VelocityVec = PVector.sub(Velocity, other.Velocity);
    float DistanceSq = DistanceVec.magSq();
    if (DistanceSq < (Radius + other.Radius) * (Radius + other.Radius)) {
      // collision occurred

      // https://en.wikipedia.org/wiki/Elastic_collision
      float factor = PVector.dot(VelocityVec, DistanceVec);
      factor = (((2 * other.Mass) / (other.Mass + Mass)) * factor) / DistanceSq;
      PVector temp = PVector.mult(DistanceVec, factor);
      Velocity.sub(temp);

      float otherfactor = PVector.dot(VelocityVec, DistanceVec);
      otherfactor = (((2 * Mass) / (other.Mass + Mass)) * otherfactor) / DistanceSq;
      PVector othertemp = PVector.mult(DistanceVec, -otherfactor);
      other.Velocity.sub(othertemp);
    }
  }

  void Draw() {
    noStroke();
    fill(Color);
    ellipse(Position.x, Position.y, Radius * 2, Radius * 2);
  }
}

class PhysicsWorld {
  ArrayList<Object> Objects = new ArrayList<Object>();

  PVector Gravity = new PVector(0, 9.81f, 0);

  void AddObject(Object object) {
    Objects.add(object);
  }

  void RemoveObject(Object object) {
    Objects.remove(object);
  }

  void Step(float dt) {

    Objects.parallelStream().forEach((object) -> 
      StepOneObject(dt, object)
    );

  }

  void StepOneObject(float dt, Object object){
      PVector Force = PVector.mult(Gravity, object.Mass);
      Force.sub(PVector.mult(object.Velocity, 6));
      object.Velocity.add(PVector.mult(Force, (dt / object.Mass)));

      for (int i = 1 + Objects.indexOf(object); i <Objects.size(); i++) {
        object.CheckObjectDetection(Objects.get(i));
        object.Position.add(PVector.mult(object.Velocity, dt));
        Objects.get(i).Position.add(PVector.mult(Objects.get(i).Velocity, dt));
      }

      object.CheckEdgeDetection();
  }

  void Draw() {
    for (Object object : Objects) {
      object.Draw();
    }
  }

void DrawObjectsConnections() {
    stroke(255, 0, 0);
    for (int i = 0; i < Objects.size(); ++i) {
      for (int j = i + 1; j < Objects.size(); ++j) {
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
  frameRate(60);
  background(BgColor);
  PhysicsWorld = new PhysicsWorld();


  for (int i = 0; i < Nobjects; i++) {
    float Radius = 3;

    float r = 50 * sqrt(random(1));
    float theta = random(1) * 2 * PI;
    float x = WindowSizeX / 2 + r * cos(theta);
    float y = WindowSizeY / 2 + r * sin(theta);
    PVector Position = new PVector(x, y);

    float vx = .5 * cos(theta);
    float vy = .5 * sin(theta);
    PVector Velocity = new PVector(vx, vy);

    float Mass = 5;

    color Color = color(255, 255, 255);

    Object Object = new Object(Position, Velocity, Mass, Radius, Color);
    PhysicsWorld.AddObject(Object);
  }
}

void draw() {
  background(BgColor);
  PhysicsWorld.Step(dt);
  PhysicsWorld.Draw();
  //PhysicsWorld.DrawObjectsConnections();

  saveFrame("./images / ######.png");

}
