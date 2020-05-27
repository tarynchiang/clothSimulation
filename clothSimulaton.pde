


float floor = 500;
float radius = 5;
float restLen = 7;
float ks = 50;
float kd = 10;
float mass = 1;
float sphereR = 100;
float cd = 0.5; // coeffiecient of air
float dAir = 1.225; //density of air 
int cols = 40;
int rows = 40;

float stringlen = 400/cols;

PVector gravity = new PVector(0,9.8,0);

Particle[][] particles = new Particle[cols][rows];

PImage kingBoo;
Camera camera;
Sphere sphere;

void setup(){
  size(800, 600, P3D);

  for(int i=0; i<cols;i++){
    for(int j=0;j < rows;j++){
      particles[i][j] = new Particle(200+i*stringlen,200,-j*stringlen);
    }
  }
  
  kingBoo = loadImage("king.jpg");  
  camera = new Camera();
  sphere = new Sphere();
}

void draw(){
  
  background(0,0,0);
  
  Update(1/frameRate);
  
  camera.Update( 1.0/frameRate );
  println("camera position: ", camera.position, "camera theta", camera.theta, "camera phi", camera.phi);
  drawThreads();
  //pushMatrix();
  //stroke(0,0,255);
  //line(0,0,0,10000,0,0);//x axis 
  //stroke(0,255,0);
  //line(0,0,0,0,10000,0);//y axis
  //stroke(255,0,0);
  //line(0,0,0,0,0,-10000);//z axis
  //popMatrix();
}


void Update(float dt){  
  //vertical force effect
  for(int i=0; i < cols;i++){
    for(int j=rows-1; j > 0;j--){
      Particle a = particles[i][j];
      Particle b = particles[i][j-1];
      PVector e = PVector.sub(b.pos,a.pos);
      float l = e.mag();
      e.normalize();
      float v1 = e.dot(a.vel);
      float v2 = e.dot(b.vel);
      float springF =  -ks*(restLen-l);
      float dampF = -kd*(v1-v2);
      float force = springF + dampF;
      PVector deltaVel = PVector.mult(e,force/mass*dt);
      particles[i][j].vel.add(deltaVel);
      particles[i][j-1].vel.sub(deltaVel);
    }
  }
  
  //horizontal force effect 
  for(int i=cols-1; i > 0;i--){
    for(int j=0; j < rows;j++){
      Particle a = particles[i][j];
      Particle b = particles[i-1][j];
      PVector e = PVector.sub(b.pos,a.pos);
      float l = e.mag();
      e.normalize();
      float v1 = e.dot(a.vel);
      float v2 = e.dot(b.vel);
      float springF =  -ks*(restLen-l);
      float dampF = -kd*(v1-v2);
      float force = springF + dampF;
      PVector deltaVel = PVector.mult(e,force/mass*dt);
      particles[i][j].vel.add(deltaVel);
      particles[i-1][j].vel.sub(deltaVel);
    }
  }
  
  for(int i=0;i<cols;i++){
    for(int j=0; j < rows;j++){
      
      //update velocity by adding gravity and fixed the top anchor
      if(j==0){
        particles[i][j].vel = new PVector(0,0,0);
      }
      else{
        PVector gt = PVector.mult(gravity,dt);
        particles[i][j].vel.add(gt);
      }
      
      //detect the interaction between sphere and cloth
      detectCollision();
      
      //update position
      PVector deltaDistance = PVector.mult(particles[i][j].vel,dt);
      particles[i][j].pos.add(deltaDistance);
      
      if(particles[i][j].pos.y + radius > floor){
        particles[i][j].vel.y *= -0.9;
        particles[i][j].pos.y = floor - radius;
      }
    }
  }
}


void drawThreads(){
  
  
  noStroke();
  for(int j=0; j< rows-1; j++){
    beginShape(TRIANGLE_STRIP);
    texture(kingBoo);
    for(int i=0; i <cols;i++){
      float u = map(i,0,cols,0,kingBoo.width);
      float v1 = map(j,0,rows,0,kingBoo.height);
      float v2 = map(j+1,0,rows,0,kingBoo.height);
     
      vertex(particles[i][j].pos.x,particles[i][j].pos.y,particles[i][j].pos.z,u,v1);
      vertex(particles[i][j+1].pos.x,particles[i][j+1].pos.y,particles[i][j+1].pos.z,u,v2);
    }
    endShape();
  }
  
  //stroke(255);
  //for(int i=0; i <cols;i++){
  //  for(int j=0; j< rows; j++){
  //   if( i != cols-1){
  //      pushMatrix();
  //      line(particles[i][j].pos.x,particles[i][j].pos.y,particles[i][j].pos.z,particles[i+1][j].pos.x,particles[i+1][j].pos.y,particles[i+1][j].pos.z);
  //      popMatrix();
      
  //    }
  //    if( j!= rows-1){
  //      pushMatrix();
  //      line(particles[i][j].pos.x,particles[i][j].pos.y,particles[i][j].pos.z,particles[i][j+1].pos.x,particles[i][j+1].pos.y,particles[i][j+1].pos.z);
  //      popMatrix();
  //    }
  //  }
  //}
  sphere.display();
}

void detectCollision(){
  for(int i=0;i < cols;i++){
    for(int j=0; j < rows; j++){
      PVector d = PVector.sub(sphere.pos,particles[i][j].pos);
      float distance = d.mag();
      
      if(distance < sphereR + 0.9){
        PVector n = PVector.mult(d,-1);
        n.normalize();
        float dotProduct = PVector.dot(n,particles[i][j].vel);
        PVector bounce = PVector.mult(n,dotProduct);
        bounce.mult(1.5);
        particles[i][j].vel.sub(bounce);
        n.mult(1+sphereR-distance);
        particles[i][j].pos.add(n);
      }
    }
  }
}

//void dragForce(Particle a,Particle b,Particle c,float dt){
//  PVector v1 = a.vel;
//  PVector v2 = b.vel;
//  PVector v3 = c.vel;
  
//  PVector v = new PVector(0,0,0);
//  v.add(v1);
//  v.add(v2);
//  v.add(v3);
//  v.div(3);
//  float vSquare = v.dot(v);
  
//  PVector u1 = PVector.sub(b.pos,a.pos);
//  PVector u2 = PVector.sub(c.pos,a.pos);
//  PVector u = u1.cross(u2);
//  PVector n = PVector.div(u,u.mag());
//  float dotProduct = v.dot(u);
//  float l = v.mag();
//  float area = 0.5 * dotProduct * l ;
//  PVector dragforce = PVector.mult(n,-0.5*dAir*vSquare*area*cd);
//  dragforce.div(3);
//  PVector dragAcc = PVector.div(dragforce,mass);
//  PVector dragVel = PVector.mult(dragAcc,dt);
//  a.vel.add(dragVel);
//  b.vel.add(dragVel);
//  c.vel.add(dragVel);
//}


void keyPressed()
{
  camera.HandleKeyPressed();
  sphere.HandleKeyPressed();
}

void keyReleased()
{
  camera.HandleKeyReleased();
}

class Particle{
  PVector pos;
  PVector vel;
  
  Particle(float x,float y,float z){
    pos = new PVector(x,y,z);
    vel = new PVector(0,0,0);
  }
}

class Sphere{
  PVector pos;
  Sphere(){
    pos = new PVector(400,447,-200);
  }
  
  void HandleKeyPressed()
  {
    if ( key == 'l' ) pos.x += 1;
    if ( key == 'j' ) pos.x -= 1;
    if ( key == 'i' ) pos.y -= 1;
    if ( key == 'k' ) pos.y += 1;
    if ( key == 'o' ) pos.z += 1;
    if ( key == 'u' ) pos.z -= 1;
  }
  
  void display(){
    pushMatrix();
    lights();
    translate(pos.x,pos.y,pos.z);
    noStroke();
    fill(0,0,255);
    sphere(sphereR);
    noLights();
    popMatrix();
  }
}
