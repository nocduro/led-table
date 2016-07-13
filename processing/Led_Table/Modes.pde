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

class SolidColour implements Mode {
  
  color c1;
  
  SolidColour(LEDTable t) {
    c1 = t.colours.get(0);
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
  
  Rainbow(LEDTable t) {
    hueVal = 0;
    maxVal = t.drawFrameRate * cycleTime;
    println("LEDTable.drawFrameRate", t.drawFrameRate);
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
  LEDTable table;
  
  // set the time for one rotation in seconds
  private void setTimeForRotation(int time) {
    framesForRotation = time * table.drawFrameRate;
    radPerFrame = (2*PI) / framesForRotation;
  }
  
  // default constructor
  RotatingCube(LEDTable t) {
    table = t;
    setTimeForRotation(5);
    colorMode(RGB, 255);
  }
  
  
  void update() {
    fill( table.colours.get(0) );

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
    box(300/table.mmPerPixel);
    popMatrix();
  }
  
  void setAttribute(String atr, int val) {
    
  }
  
}


class SoundBall implements Mode {
  AudioInput mic;
  FFT fft;
  BeatDetect beat;
  LEDTable table;
  
  float alpha,a;
  int numBars;
  float[] prevBars, currentBars;
  int barMultiplier; // changes the size of the 'ball'
  
  // constructor for audioInput
  SoundBall(LEDTable t, AudioInput s) {
    table = t;
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
    fft.forward(mic.left);
    beat.detect(mic.left);
    
    for (int i = 0; i < numBars; i++) {
      float val = fft.getAvg(i) * barMultiplier * (i*i+1); 
      if (val > prevBars[i] ) {
        currentBars[i] = prevBars[i] + ( (val- prevBars[i]) * 0.08 ); // fade up to new value
      } else {
        currentBars[i] = prevBars[i] * 0.95;  // fade down to old value
      }
      this.prevBars[i] = currentBars[i];
      
    }
    
    
    a = map(alpha, 25, 150, 180, 255); 
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



class Bubbles implements Mode {
  ArrayList<Particle> particles;
  PVector origin;
  PImage dot;
  LEDTable table;
  
  
  
  // default constructor
  Bubbles(LEDTable t) {   
    table = t;
    particles = new ArrayList<Particle>();
    dot = loadImage("dot.png");
    for (int i = 0; i < 50; i++) {
      //Particle (size, lifespan)
      particles.add(new Particle(table.colours.get(0), 15, 250));
    }
  }
  
  Bubbles(LEDTable t, int count) {    
    table = t;
    particles = new ArrayList<Particle>();
    dot = loadImage("dot.png");
    for (int i = 0; i < count; i++) {
      //Particle (size, lifespan)
      particles.add(new Particle(table.colours.get(0)));
    }
  }
  
  Bubbles(LEDTable t, int count, int size, int lifespan) {
    table = t;
    particles = new ArrayList<Particle>();
    dot = loadImage("dot.png");
    for (int i = 0; i < count; i++) {
      //Particle (size, lifespan)
      particles.add(new Particle(color(random(255),random(255),random(255)), size, lifespan));
    }
  }
  
  Bubbles(LEDTable t, int count, int size, int lifespan, color c) {
    table = t;
    particles = new ArrayList<Particle>();
    dot = loadImage("dot.png");
    for (int i = 0; i < count; i++) {
      //Particle (size, lifespan)
      particles.add(new Particle(c, size, lifespan));
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