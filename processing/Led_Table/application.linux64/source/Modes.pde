public class Modes
{
  int modeCounter;
  int drawFrameRate;
  float mmPerPixel;
  
  Modes(PApplet parent, int drawFrameRate, float mmPerPixel)
  {
    this.modeCounter = 0;
    this.drawFrameRate = drawFrameRate;  
    this.mmPerPixel = mmPerPixel;  
  }
  
  
  void off()
  {
    background(0);    
  }
  
  
  void rotateCube(color c)
  {
    int framesForCompleteRotation = 5 * drawFrameRate;
    float radPerStep = (2*PI) / framesForCompleteRotation;
    
    background(0);
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
  
  void solidColour(color colour)
  {
    background(colour);
  }
  

  
} // end of main class
