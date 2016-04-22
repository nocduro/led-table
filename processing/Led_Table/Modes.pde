import ddf.minim.*;
import ddf.minim.analysis.*;

public interface Mode 
{  
  // run the calculations for that mode
  public void update();
  
  // display the changes on the screen/matrix
  public void display();
  
  
  //public void setColour(int idx, String colour);
  
  // set specific settings for that mode?
  public void setAttribute(String attribute, int val);
  
  // find out what settings we can change for that mode
  //public String[] getAttributes();
  
}


public static class LEDTable
{
  static boolean[] irData = new boolean[20];
  static float[] cupX = new float[20];
  static float[] cupY = new float[20];
  static int drawFrameRate, tableWidth, tableLength;
  static float mmPerPixel, cupDiameter;
  
  // set the colour
  static IntList colours = new IntList();  
  
  static void initialize(float tableWidthMM, float tableLengthMM, int drawFrameRate, float mmPerPixel) {
    LEDTable.drawFrameRate = drawFrameRate;
    LEDTable.cupDiameter = 75/mmPerPixel;
    LEDTable.tableWidth = floor(tableWidthMM/mmPerPixel);
    LEDTable.tableLength = floor(tableLengthMM/mmPerPixel);
    LEDTable.mmPerPixel = mmPerPixel;
    // clear the irData array
    for (int i = 0; i < 20; i++) {
      irData[i] = false;
    }
    generateCupCoordinates();
  }
  
  private static void generateCupCoordinates() {
    // screw side
    cupX[0] = 335/mmPerPixel;
    cupY[0] = 305/mmPerPixel;
    cupX[1] = 248/mmPerPixel;
    cupY[1] = 255/mmPerPixel;
    cupX[2] = 248/mmPerPixel;
    cupY[2] = 355/mmPerPixel;
    cupX[3] = 162/mmPerPixel;
    cupY[3] = 205/mmPerPixel;
    cupX[4] = 162/mmPerPixel;
    cupY[4] = 305/mmPerPixel;
    cupX[5] = 162/mmPerPixel;
    cupY[5] = 405/mmPerPixel;
    cupX[6] = 75/mmPerPixel;
    cupY[6] = 155/mmPerPixel;
    cupX[7] = 75/mmPerPixel;
    cupY[7] = 255/mmPerPixel;
    cupX[8] = 75/mmPerPixel;
    cupY[8] = 355/mmPerPixel;
    cupX[9] = 75/mmPerPixel;
    cupY[9] = 455/mmPerPixel;
    
    cupX[10] = tableLength - 335/mmPerPixel;
    cupY[10] = 305/mmPerPixel;
    cupX[11] = tableLength - 248/mmPerPixel;
    cupY[11] = 355/mmPerPixel;
    cupX[12] = tableLength - 248/mmPerPixel;
    cupY[12] = 255/mmPerPixel;
    cupX[13] = tableLength - 162/mmPerPixel;
    cupY[13] = 405/mmPerPixel;
    cupX[14] = tableLength - 162/mmPerPixel;
    cupY[14] = 305/mmPerPixel;
    cupX[15] = tableLength - 162/mmPerPixel;
    cupY[15] = 205/mmPerPixel;
    cupX[16] = tableLength - 75/mmPerPixel;
    cupY[16] = 455/mmPerPixel;
    cupX[17] = tableLength - 75/mmPerPixel;
    cupY[17] = 355/mmPerPixel;
    cupX[18] = tableLength - 75/mmPerPixel;
    cupY[18] = 255/mmPerPixel;
    cupX[19] = tableLength - 75/mmPerPixel;
    cupY[19] = 155/mmPerPixel;
  }
  
}

class SolidColour implements Mode {
  
  color c1;
  
  SolidColour() {
    c1 = LEDTable.colours.get(0);
  }
  
  // set the colour if a string of the colour is passed in
  // TODO: ADD ERROR CHECKING
  SolidColour(String c) {
    c1 = unhex(c);
  }
  
  SolidColour(color c) {
    c1 = c;
  }
  
  void update() {
    // display secondary colour under cups
    
    
  }
  
  void display() {
    blendMode(BLEND);
    colorMode(RGB, 255);
    background(c1);
   }
   
   void setAttribute(String atr, int val) {
   }
}

// Draws a rainbow to the display
class Rainbow implements Mode {
  int hueVal;
  int cycleTime = 20; // time in seconds to complete
  int maxVal;
  
  Rainbow() {
    hueVal = 0;
    maxVal = LEDTable.drawFrameRate * cycleTime;
    println("LEDTable.drawFrameRate", LEDTable.drawFrameRate);
    println("rainbow maxVal", maxVal);
    colorMode(HSB, maxVal);
  }
  
  void update() {
    colorMode(HSB, maxVal);
    if (hueVal == maxVal) {
      hueVal =0;
    } else {
      hueVal+=1;
    }
  }
  
  void display() {
    background(hueVal, maxVal, maxVal);
  }
  
  void setAttribute(String atr, int val) {
  }
  
}

class RotatingCube implements Mode
{
  float radPerFrame;
  int counter, framesForRotation;
  
  // set the time for one rotation in seconds
  private void setTimeForRotation(int time) {
    framesForRotation = time * LEDTable.drawFrameRate;
    radPerFrame = (2*PI) / framesForRotation;
  }
  
  // default constructor
  RotatingCube() {
    setTimeForRotation(5);
    colorMode(RGB, 255);
  }
  
  
  void update() {
    fill( LEDTable.colours.get(0) );

    if (counter == framesForRotation) {
      counter = 0;
    } else {
      counter++;
    }
  }
  
  void display() {
    blendMode(BLEND);
    colorMode(RGB, 255);
    background(0);
    pushMatrix();
    rectMode(CENTER);
    translate(width/2, height/2);
    rotateZ(counter * radPerFrame);
    rotateY(counter * radPerFrame);
    rotateX(counter * radPerFrame);
    box(300/LEDTable.mmPerPixel);
    popMatrix();
  }
  
  void setAttribute(String atr, int val) {
    
  }
  
}


class SoundBall implements Mode {
  AudioPlayer sound;
  AudioInput mic;
  FFT fft;
  BeatDetect beat;
  
  float alpha,a;
  int numBars;
  float[] prevBars, currentBars;
  int barMultiplier; // changes the size of the 'ball'
  
  SoundBall(AudioPlayer s) {
    sound = s;
    sound.loop();
    fft = new FFT(s.bufferSize(), s.sampleRate());
    beat = new BeatDetect();
    alpha = 180;
    numBars = 3;
    prevBars = new float[this.numBars];
    currentBars = new float[this.numBars];
    barMultiplier = 20;
    colorMode(RGB, 255);
  }
  
  // constructor for audioInput
  SoundBall(AudioInput s) {
    mic = s;
    fft = new FFT(mic.bufferSize(), mic.sampleRate());
    beat = new BeatDetect();
    alpha = 180;
    numBars = 3;
    prevBars = new float[this.numBars];
    currentBars = new float[this.numBars];    
    barMultiplier = 50;
    colorMode(RGB, 255);
  }
  
  void update() {
    fft.linAverages(numBars);
    
    // use the right object to do fft on depending on how the class was created.
    // sound is used if constructed with an AudioPlayer, mic is used when constructed with AudioInput
    if (sound != null) {
      fft.forward(sound.left);
      // beat detection on sound level
      beat.detect(sound.left);
    } else if (mic != null) {
      fft.forward(mic.left);
      beat.detect(mic.left);
    }
    
    for (int i = 0; i < numBars; i++) {
      float val = fft.getAvg(i) * barMultiplier * (i*i+1); 
      if (val > prevBars[i] ) {
        currentBars[i] = prevBars[i] + ( (val- prevBars[i]) * 0.08 ); // fade up to new value
      } else {
        currentBars[i] = prevBars[i] * 0.95;  // fade down to old value
      }
      this.prevBars[i] = currentBars[i];
      
    }
    
    
    a = map(alpha, 25, 150, 130, 255); 
    if ( beat.isOnset() ) alpha = 150; 
    
    alpha *= 0.97;
    if ( alpha < 25 ) alpha = 25;
    
  }
   
  
  
  void display() {
    background(0);
    blendMode(BLEND);
    colorMode(RGB, 255);
    fill(255, 66, 00, a);
    ellipse(width/2, height/2, currentBars[2]+currentBars[0]+currentBars[1], currentBars[2] + currentBars[0] + currentBars[1]);
    
    fill(255);
    ellipse(width/2, height/2, currentBars[0]+currentBars[1], currentBars[0]+currentBars[1]);
    fill(90, 0, 120, a);
    ellipse(width/2, height/2, currentBars[1]+currentBars[0], currentBars[1]+currentBars[0]);
    
    fill(255);
    ellipse(width/2, height/2, currentBars[0], currentBars[0]);
    fill(60, 255, 0, a);
    ellipse(width/2, height/2, currentBars[0], currentBars[0]);
    
  }
   

  void setAttribute(String atr, int val) {
  }
}




public interface CupMode 
{  
  // display the changes on the screen/matrix
  public void display();
  
  // set the colour
  //public IntList colours = new IntList();
  //public void setColour(int idx, String colour);
  
  // set specific settings for that mode?
  public void setAttribute(String attribute, int val);
  
  // find out what settings we can change for that mode
  //public String[] getAttributes();
  
}


class CupSolidColour implements CupMode
{
  boolean differentColours;
  boolean transparent;
  
  // default constructor
  CupSolidColour() {
    colorMode(RGB, 255);
    this.differentColours = true;
    this.transparent = true;
    
    println("cup solid");
    
  }
  
  CupSolidColour(boolean twoSides, boolean transparent) {
    colorMode(RGB, 255);
    this.differentColours = true;
    this.transparent = true;
  }
  
  void display() {  
    colorMode(RGB, 255);
    blendMode(BLEND);
    for (int i = 0; i< LEDTable.irData.length; i++) {
      if (LEDTable.irData[i]) {
        if (differentColours && i>=10) {
          fill(LEDTable.colours.get(3));
        } else {fill(LEDTable.colours.get(2)); }
        
        ellipse(LEDTable.cupX[i], LEDTable.cupY[i], LEDTable.cupDiameter, LEDTable.cupDiameter);
      } else {
        fill(0);
        if (!transparent) { 
          ellipse(LEDTable.cupX[i], LEDTable.cupY[i], LEDTable.cupDiameter, LEDTable.cupDiameter); 
        }
      }
    }
  }
  
  void setAttribute(String atr, int val) {
    
  }
  
}


class CupTransparent implements CupMode
{
  boolean differentColours;
  // default constructor
  CupTransparent() {    
  }
  
  void display() {  
  }
  
  void setAttribute(String atr, int val) {
    
  }
  
}



class Bubbles implements Mode {
  ArrayList<Particle> particles;
  PVector origin;
  PImage dot;
  
  
  
  // default constructor
  Bubbles() {    
    particles = new ArrayList<Particle>();
    dot = loadImage("dot.png");
    for (int i = 0; i < 50; i++) {
      //Particle (size, lifespan)
      particles.add(new Particle(LEDTable.colours.get(0), 15, 250));
    }
  }
  
  Bubbles(int count) {    
    particles = new ArrayList<Particle>();
    dot = loadImage("dot.png");
    for (int i = 0; i < count; i++) {
      //Particle (size, lifespan)
      particles.add(new Particle(LEDTable.colours.get(0)));
    }
  }
  
  Bubbles(int count, int size, int lifespan) {
    particles = new ArrayList<Particle>();
    dot = loadImage("dot.png");
    for (int i = 0; i < count; i++) {
      //Particle (size, lifespan)
      particles.add(new Particle(color(random(255),random(255),random(255)), size, lifespan));
    }
  }
  
  
  
  void update() {
    blendMode(ADD);
    background(0);
    colorMode(RGB, 255);
    
    for (int i = particles.size()-1; i>=0; i--) {
      // load each particle
      Particle p = particles.get(i);
      
      // update particle
       // decrease lifespan
       // change location by adding velocity
      p.update();
      
      // get its location and display it
      //tint(LEDTable.colours.get(0));
      tint(p.colour);
      image(dot, p.location.x - p.size/2, p.location.y - p.size/2, p.size, p.size);
      
      // delete particle if it's dead
      if (p.isDead()) {
        particles.remove(i);
      }
      
    }
    
  }
  
  void display() {  
  }
  
  void setAttribute(String atr, int val) {
  }
}


class Particle {
  PImage dot;
  
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  float size = 250;
  color colour;
  
  Particle(PVector p) {
    acceleration = new PVector(0.01, 0);
    velocity = PVector.random2D();
    location = p;
    lifespan = 255.0;
  }
  Particle(color c) {
    acceleration = new PVector(0.01, 0);
    velocity = PVector.random2D();
    location = new PVector(random(width), random(height));
    this.colour = c;
    dot = loadImage("dot.png");
  }
  
  Particle(color c, int size, int lifespan) {
    this.size = size;
    this.colour = c;
    this.lifespan = lifespan;
    acceleration = new PVector(0.01, 0);
    velocity = PVector.random2D();
    location = new PVector(random(width), random(height));
  }
  
  void update() {
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
  
  boolean isDead() {
    if (lifespan < 0.0){
      return true;
    } else { return false; }
  }
}