import ddf.minim.*;
import ddf.minim.analysis.*;

public interface Mode 
{
  public int drawFrameRate = 60;
  
  // run the calculations for that mode
  public void update();
  
  // display the changes on the screen/matrix
  public void display();
  
  // set the colour
  public IntList colours = new IntList();  
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
  static int drawFrameRate, tableWidth, tableHeight;
  static float mmPerPixel, cupDiameter;
  
  static void initialize(float tableWidthMM, float tableHeightMM, int drawFrameRate, float mmPerPixel) {
    LEDTable.drawFrameRate = drawFrameRate;
    LEDTable.cupDiameter = 75/mmPerPixel;
    LEDTable.tableWidth = floor(tableWidthMM/mmPerPixel);
    LEDTable.tableHeight = floor(tableHeightMM/mmPerPixel);
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
    
    cupX[10] = tableWidth - 335/mmPerPixel;
    cupY[10] = 305/mmPerPixel;
    cupX[11] = tableWidth - 248/mmPerPixel;
    cupY[11] = 355/mmPerPixel;
    cupX[12] = tableWidth - 248/mmPerPixel;
    cupY[12] = 255/mmPerPixel;
    cupX[13] = tableWidth - 162/mmPerPixel;
    cupY[13] = 405/mmPerPixel;
    cupX[14] = tableWidth - 162/mmPerPixel;
    cupY[14] = 305/mmPerPixel;
    cupX[15] = tableWidth - 162/mmPerPixel;
    cupY[15] = 205/mmPerPixel;
    cupX[16] = tableWidth - 75/mmPerPixel;
    cupY[16] = 455/mmPerPixel;
    cupX[17] = tableWidth - 75/mmPerPixel;
    cupY[17] = 355/mmPerPixel;
    cupX[18] = tableWidth - 75/mmPerPixel;
    cupY[18] = 255/mmPerPixel;
    cupX[19] = tableWidth - 75/mmPerPixel;
    cupY[19] = 155/mmPerPixel;
  }
  
}

class SolidColour implements Mode {
  
  SolidColour() {
    Mode.colours.clear();
    Mode.colours.append( unhex("FF3388FF") );
  }
  
  // set the colour if a string of the colour is passed in
  // TODO: ADD ERROR CHECKING
  SolidColour(String c) {
    Mode.colours.clear();
    Mode.colours.append( unhex(c) );
  }
  
  SolidColour(color c) {
    Mode.colours.clear();
    Mode.colours.append(c);
  }
  
  void update() {
  }
  
  void display() {
    background(Mode.colours.get(0));
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
    maxVal = Mode.drawFrameRate * cycleTime;
    colorMode(HSB, maxVal);
  }
  
  void update() {
    
  }
  
  void display() {
    background(hueVal, maxVal, maxVal);
    if (hueVal == maxVal) {
      hueVal =0;
    } else {
      hueVal+=1;
    }
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
    framesForRotation = time * Mode.drawFrameRate;
    radPerFrame = (2*PI) / framesForRotation;
  }
  
  // default constructor
  RotatingCube() {
    Mode.colours.clear();
    Mode.colours.append(unhex("FF0000AA"));
    setTimeForRotation(5);
  }
  
  
  void update() {
    fill( Mode.colours.get(0) );
    rectMode(CENTER);
    translate(width/2, height/2);
    rotateZ(counter * radPerFrame);
    rotateY(counter * radPerFrame);
    rotateX(counter * radPerFrame);
    if (counter == framesForRotation) {
      counter = 0;
    } else {
      counter++;
    }
  }
  
  void display() {
    background(0);
    box(300/LEDTable.mmPerPixel);
  }
  
  void setAttribute(String atr, int val) {
    
  }
  
}


class SoundBall implements Mode {
  AudioPlayer sound;
  FFT fft;
  BeatDetect beat;
  
  float alpha,a;
  int numBars;
  float[] prevBars, currentBars;
  
  SoundBall(AudioPlayer s) {
    sound = s;
    sound.loop();
    fft = new FFT(s.bufferSize(), s.sampleRate());
    beat = new BeatDetect();
    alpha = 180;
    numBars = 3;
    prevBars = new float[this.numBars];
    currentBars = new float[this.numBars];
  }
  
  void update() {
    fft.linAverages(numBars);
    fft.forward(sound.left);
    for (int i = 0; i < numBars; i++) {
      float val = fft.getAvg(i) * 15 * (i*i+1); 
      if (val > prevBars[i] ) {
        currentBars[i] = prevBars[i] + ( (val- prevBars[i]) * 0.08 ); // fade up to new value
      } else {
        currentBars[i] = prevBars[i] * 0.95;  // fade down to old value
      }
      this.prevBars[i] = currentBars[i];
      
    }
    
    // beat detection on sound level
    beat.detect(sound.left);
    a = map(alpha, 25, 150, 180, 255); 
    if ( beat.isOnset() ) alpha = 150; 
    
    alpha *= 0.97;
    if ( alpha < 25 ) alpha = 25;
    
  }
   
  
  
  void display() {
    background(0);
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