/* autogenerated by Processing revision 1292 on 2023-03-07 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class PhysicsEngine extends PApplet {

int WindowSizeX = 1920;
int WindowSizeY = 1080;
int BgColor = color(255, 255, 255);

PhysicsWorld PhysicsWorld;
float dt = 0.01f;

int Nobjects = 100;

class Object {
  PVector Position;
  PVector Velocity;
  float Mass;
  float Radius;
  int Color;

  Object(PVector position, PVector velocity, float mass, float radius, int _color) {
    Position = position;
    Velocity = velocity;
    Mass = mass;
    Radius = radius;
    Color = _color;
  }

  public void CheckEdgeDetection() {
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

  public void CheckObjectDetection(Object other) {
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

  public void Draw() {
    noStroke();
    fill(Color);
    ellipse(Position.x, Position.y, Radius * 2, Radius * 2);
  }
}

class PhysicsWorld {
  ArrayList<Object> Objects = new ArrayList<Object>();

  PVector Gravity = new PVector(0, 9.81f, 0);

  public void AddObject(Object object) {
    Objects.add(object);
  }

  public void RemoveObject(Object object) {
    Objects.remove(object);
  }

  public void Step(float dt) {

    Objects.parallelStream().forEach((object) -> 
      StepOneObject(dt, object)
    );

  }

  public void StepOneObject(float dt, Object object){
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

  public void Draw() {
    for (Object object : Objects) {
      object.Draw();
    }
  }

public void DrawObjectsConnections() {
    stroke(0, 0, 0, 100);
    for (int i = 0; i < Objects.size(); ++i) {
      for (int j = i + 1; j < Objects.size(); ++j) {
        PVector Position1 = Objects.get(j).Position;
        PVector Position2 = Objects.get(i).Position;
        line(Position1.x, Position1.y, Position2.x, Position2.y);
      }
    }
  }

}

public void settings() {
  size(WindowSizeX, WindowSizeY);
}

public void setup() {
  frameRate(60);
  background(BgColor);
  PhysicsWorld = new PhysicsWorld();


  for (int i = 0; i < Nobjects; i++) {
    float Radius = random(1, 5);

    float r = 200 * sqrt(random(1));
    float theta = random(1) * 2 * PI;
    float x = WindowSizeX / 2 + r * cos(theta);
    float y = WindowSizeY / 2 + r * sin(theta);
    PVector Position = new PVector(x, y);

    float vx = random(-3, 3) * cos(theta);
    float vy = random(-3, 3) * sin(theta);
    PVector Velocity = new PVector(vx, vy);

    float Mass = random(10, 100);;
    int Color = color(0, 0, 0);

    Object Object = new Object(Position, Velocity, Mass, Radius, Color);
    PhysicsWorld.AddObject(Object);
  }
}

public void draw() {
  background(BgColor);
  PhysicsWorld.Step(dt);
  PhysicsWorld.Draw();
  //PhysicsWorld.DrawObjectsConnections();

  //saveFrame("./images/######.png");
}


  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PhysicsEngine" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
