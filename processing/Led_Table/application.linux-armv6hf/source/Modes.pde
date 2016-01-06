public class Modes
{
  
  
  int modeCounter;
  int drawFrameRate;
  float mmPerPixel;
  PImage dot;
  boolean[] irData = new boolean[20];
  float[] xPos = new float[20];
  float[] yPos = new float[20];
  float diameter; // diameter of cup leds
  float multiplier = 2;
  
  PImage colors;
  
  // fft data
  float[] currentFFT;
  float[] prevFFT;
  float[] fftFilter;
  
  Modes(PApplet parent, int drawFrameRate, float mmPerPixel)
  {
    this.modeCounter = 0;
    this.drawFrameRate = drawFrameRate;  
    this.mmPerPixel = mmPerPixel;  
    dot = loadImage("dot.png");
    
    for (int i = 0; i < 20; i++)
    {
      irData[i] = false;
    }
    diameter = 75/mmPerPixel;
    generateCoordinates();
    
    currentFFT = new float[64];
    prevFFT = new float[64];
    fftFilter = new float[2049];
    
    colors = loadImage("colors.png");
  }
  
  
  void off()
  {
    background(0);    
  }
  
  
  void rotateCube(color c, color secondary)
  {
    int timeForRotation = 5; //seconds
    int framesForCompleteRotation = timeForRotation * drawFrameRate;
    float radPerStep = (2*PI) / framesForCompleteRotation;
    
    
    
    
    background(0);
    // cup detectors
    fill(secondary);
    for (int i = 0; i < 20; i++)
    {
      if (irData[i]){
        ellipse(xPos[i], yPos[i], diameter, diameter);
      }
    }
    fill(c);
    rectMode(CENTER);
    
    translate(width/2, height/2);
    rotateZ(modeCounter * radPerStep);
    rotateY(modeCounter * radPerStep);
    rotateX(modeCounter * radPerStep);

    box(300/mmPerPixel);

    if (modeCounter == framesForCompleteRotation)
    {
      modeCounter = 0;
    } else {
      modeCounter++; 
    } 
    
  }// end rotateCube()
  
  
  
  void solidColour(color primary, color secondary)
  {
    background(primary);
    fill(secondary);
    for (int i = 0; i < 20; i++)
    {
      if (irData[i]){
        ellipse(xPos[i], yPos[i], diameter, diameter);
      }
    }
    
  }// end solidColour
  
  
  void dot()
  {
    background(0);
    image(dot, mouseX -50, mouseY -50, 100, 100);   
    
  }
  
  
  void soundTest(color primary, color secondary)
  {
    FloatList temp = new FloatList();
    for (int i = 0; i < 10; i++){
      temp.append(currentFFT[i]); 
    }
    background(0);
    blendMode(ADD);
    
    
    float current = temp.max();
    float size = 600 * max(current, prevFFT[0] * 0.97);
    
    tint(primary);
    
    image(dot, width/2 - size/2, height/2 - size/2, size, size);
    if (current > prevFFT[0]){
      prevFFT[0] = current;
    } else {
      prevFFT[0] = prevFFT[0] * 0.97;
    }
    temp.clear();
    
    
    // secondary
    for (int i = 40; i < 64; i++)
    {
      temp.append(currentFFT[i]);
    }
    float current2 = temp.max();
    size = 650 * max(current2, prevFFT[1] * 0.97);
    tint(secondary);
    
    image(dot, width/2 - size/2, height/2 - size/2, size, size);
    if (current2 > prevFFT[1]){
      prevFFT[1] = current2;
    } else {
      prevFFT[1] = prevFFT[1] * 0.97;
    }
    temp.clear();
    
    fill(secondaryColour);
    for (int i = 0; i < 20; i++)
    {
      if (!irData[i]){
        ellipse(xPos[i], yPos[i], diameter, diameter);
      }
    }
    
    
  }
  
  
  
  
  
  
  
  
  
  ParticleSystem bubbleSystem = new ParticleSystem();
  
  void bubbles(color primaryColour)
  {
    blendMode(ADD);
    background(0);
    if (modeCounter == 0)
    {
      bubbleSystem.clearArray();
      for (int i = 0; i < 50; i++){
        bubbleSystem.addParticle(primaryColour);
      }
      modeCounter++;
    }
    bubbleSystem.run();
  }
  
  
  
  
  

  
  
  
  void generateCoordinates()
  {
    // screw side
    xPos[0] = 335/mmPerPixel;
    yPos[0] = 305/mmPerPixel;
    xPos[1] = 248/mmPerPixel;
    yPos[1] = 255/mmPerPixel;
    xPos[2] = 248/mmPerPixel;
    yPos[2] = 355/mmPerPixel;
    xPos[3] = 162/mmPerPixel;
    yPos[3] = 205/mmPerPixel;
    xPos[4] = 162/mmPerPixel;
    yPos[4] = 305/mmPerPixel;
    xPos[5] = 162/mmPerPixel;
    yPos[5] = 405/mmPerPixel;
    xPos[6] = 75/mmPerPixel;
    yPos[6] = 155/mmPerPixel;
    xPos[7] = 75/mmPerPixel;
    yPos[7] = 255/mmPerPixel;
    xPos[8] = 75/mmPerPixel;
    yPos[8] = 355/mmPerPixel;
    xPos[9] = 75/mmPerPixel;
    yPos[9] = 455/mmPerPixel;
    
    xPos[10] =  width - 335/mmPerPixel;
    yPos[10] = 305/mmPerPixel;
    xPos[11] = width - 248/mmPerPixel;
    yPos[11] = 355/mmPerPixel;
    xPos[12] = width - 248/mmPerPixel;
    yPos[12] = 255/mmPerPixel;
    xPos[13] = width - 162/mmPerPixel;
    yPos[13] = 405/mmPerPixel;
    xPos[14] = width - 162/mmPerPixel;
    yPos[14] = 305/mmPerPixel;
    xPos[15] = width - 162/mmPerPixel;
    yPos[15] = 205/mmPerPixel;
    xPos[16] = width - 75/mmPerPixel;
    yPos[16] = 455/mmPerPixel;
    xPos[17] = width - 75/mmPerPixel;
    yPos[17] = 355/mmPerPixel;
    xPos[18] = width - 75/mmPerPixel;
    yPos[18] = 255/mmPerPixel;
    xPos[19] = width - 75/mmPerPixel;
    yPos[19] = 155/mmPerPixel;
  }
  
  
  

  
} // end of main class





class Particle
{
  PImage dot;
  
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  float size = 250;
  color primaryColour;
  
  Particle(PVector p){
    acceleration = new PVector(0.01, 0);
    velocity = PVector.random2D();
    location = p.get();
    lifespan = 255.0;
  }
  Particle(color c)
  {
    acceleration = new PVector(0.01, 0);
    velocity = PVector.random2D();
    location = new PVector(random(width), random(height));
    primaryColour = c;
    dot = loadImage("dot.png");
  }
  
  void run()
  {
    update();
    display();
  }
  
  void update()
  {
    //velocity.add(acceleration);
    location.add(velocity);
    //lifespan -= 1.0;
    
    // check if they hit something
    if (location.x > width){
      // goes off right, swap x vector
      velocity.sub(velocity.x * 2, 0, 0);
    } else if (location.x < 0){
      // goes off left
      velocity.sub(velocity.x * 2, 0, 0);
    } else if (location.y > height){
      // goes off the bottom
      velocity.sub(0, velocity.y * 2, 0);
    } else if (location.y < 0){
      // goes off the top
      velocity.sub(0, velocity.y * 2, 0);
    }
    
    // check if they hit each other
    
  }
  
  void display()
  {
    //fill(255, lifespan);
    //ellipse(location.x, location.y, size, size);
    tint(primaryColour);
    image(dot, location.x - size/2, location.y - size/2, size, size);
  }
  
  boolean isDead()
  {
    if (lifespan < 0.0){
      return true;
    } else {
      return false;
    }
  }
  
  
  
}




class ParticleSystem
{
  ArrayList<Particle> particles;
  PVector origin;
  
  ParticleSystem(){
   particles = new ArrayList<Particle>(); 
  }
  
  void addParticle(color c){
    particles.add(new Particle(c));
  }
  
  void run() {
    for (int i = particles.size()-1; i >= 0; i--)
    {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()){
        particles.remove(i);
      }
    }
  }
  
  void clearArray()
  {
    particles.clear();
  }
  
}