public interface CupMode 
{  
  // display the changes on the screen/matrix
  public void display();
  
  // set specific settings for that mode?
  public void setAttribute(String attribute, int val);
  
  // find out what settings we can change for that mode
  //public String[] getAttributes();
  
}


class CupSolidColour implements CupMode
{
  LEDTable table;
  boolean differentColours;
  boolean transparent;
  
  // default constructor
  CupSolidColour(LEDTable t) {
    table = t;
    colorMode(RGB, 255);
    this.differentColours = false;
    this.transparent = false;    
  }
  
  CupSolidColour(LEDTable t, boolean twoSides, boolean transpar) {
    table = t;
    colorMode(RGB, 255);
    this.differentColours = twoSides;
    this.transparent = transpar;
  }
  
  void display() {  
    colorMode(RGB, 255);
    blendMode(BLEND);
    for (int i = 0; i< table.irData.length; i++) {
      if (table.irData[i]) {
        if (differentColours && i>=10) {
          fill(table.colours.get(3));
        } else {fill(table.colours.get(2)); }
        
        ellipse(table.cupX[i], table.cupY[i], table.cupDiameter, table.cupDiameter);
      } else {
        fill(0);
        if (!transparent) { 
          ellipse(table.cupX[i], table.cupY[i], table.cupDiameter, table.cupDiameter); 
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