public class LEDTable
{
  boolean[] irData = new boolean[20];
  float[] analogData = new float[4];
  float[] cupX = new float[20];
  float[] cupY = new float[20];
  int drawFrameRate, tableWidth, tableLength;
  float mmPerPixel;
  int cupDiameter, brightness;
  int topLeftGridX, topLeftGridY;
  boolean scoreEnabled;
  
  Mode mode;
  CupMode cupMode;
  StringList modeList;
  int currentMode = 1;
  StringList cupModeList;
  int currentCupMode = 1;
  
  AudioReactor audio;
  
  // set the colour
  IntList colours = new IntList();
  
  LEDTable(float tableWidthMM, float tableLengthMM, int drawFrameRate, float mmPerPixel) {
    this.drawFrameRate = drawFrameRate;
    this.cupDiameter = ceil(75/mmPerPixel)+2;
    this.tableWidth = floor(tableWidthMM/mmPerPixel);
    this.tableLength = floor(tableLengthMM/mmPerPixel);
    this.mmPerPixel = mmPerPixel;
    this.brightness = 100;
    this.scoreEnabled = false;

    // clear the irData array
    for (int i = 0; i < 20; i++) {
      irData[i] = false;
    }
    generateCupCoordinates();
    
    /** MODE SETUP **/
    modeList = new StringList();
    modeList.append("OFF");
    modeList.append("SOLIDCOLOUR");
    modeList.append("RAINBOW");
    modeList.append("ROTATINGCUBE");
    modeList.append("SOUNDBALL");
    modeList.append("BUBBLESRAINBOW");
    modeList.append("BUBBLES");
    modeList.append("STARS");
    modeList.append("TEXT");
    
    cupModeList = new StringList();
    cupModeList.append("CUPTRANSPARENT");
    cupModeList.append("SOLIDCOLOUR");
    cupModeList.append("SOLIDCOLOURTRANSPARENT");
    
      // fill default colour data
    colours.append(unhex("FF0000AA"));
    colours.append(unhex("FFAA0000"));
    colours.append(unhex("FF00AA00"));
    colours.append(unhex("FFAA22AA"));
    colours.append(unhex("FFCCBBAA"));
    
    
  }
  
  private void generateCupCoordinates() {
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
  
  void changeBrightness(OPC opc, int b) {
    opc.setColorCorrection(2.5, b/100f, b/100f, b/100f);  
    brightness = b;
    println("Color correction: " + opc.colorCorrection);
  }
  
  
  void changeColour(int colourToChange, String c) {
    if (colourToChange > 4 || colourToChange < 0) {
      return;
    }
    c = "FF" + c; // make sure alpha channel is opaque
    colours.set(colourToChange, unhex(c));
    println("Colour num",colourToChange, "changed to ", c);
  }
  
  
  void buttonPressed(int b) {
    switch (b) {
      case 1:
        changeMode("TOGGLE");
        break;
      case 2:
        changeCupMode("TOGGLE");
        break;
      case 3:
        scoreEnabled = !scoreEnabled;
        break;
      default:
        println("Unrecognized button press");
    }
  }
  
  void buttonHeld(int b) {
    switch (b) {
      case 1:
        changeMode("OFF");
        break;
      case 2:
        break;
      case 3:
        break;
      default:
        println("Unrecognized button press");
    }
  }
  
  
  void changeMode(String s) {  
    s = s.trim().toUpperCase();
    println("Trying to change to", s);
    
    // try to match the input string to a mode number:
    if (modeList.hasValue(s) == true) {
      for (int i = 0; i < modeList.size(); i++) {
        if (modeList.get(i).equals(s) ) {
          currentMode = i;
          break;
        }
      }
    } else {
      // mode not found, or we are just incrementing to the next mode
      if (currentMode < modeList.size() -1) {
        currentMode +=1;
      } else {
        currentMode = 0;
      }
    }
    println("currentMode:", currentMode, modeList.get(currentMode));
    switch(currentMode) {
      case 0: // OFF
        mode = new SolidColour(0);
        break;
      case 1: // SOLIDCOLOUR
        mode = new SolidColour(this);
        break;
      case 2: // RAINBOW
        mode = new Rainbow(this);
        break;
      case 3:
        mode = new RotatingCube(this);
        break;
      case 4:
        //mode = new SoundBall(this, sound);
        mode = new SoundBall(this, audio);
        break;
      case 5:
        // Bubbles(count, size, lifespan);
        mode = new Bubbles(this, 30, 85, 100);
        break;
      case 6:
        mode = new Bubbles(this, 30,85,100, this.colours.get(0));
        break;
      case 7: // 'stars' using bubbles
        mode = new Bubbles(this, 30, 15, 100);
        break;
      case 8: // 'TEXT'
        mode = new Text(this, "HI");
        break;
      default:
        mode = new SolidColour(0);
        break;
    }
  }
  
  
  void changeCupMode(String s) {
    s = s.trim().toUpperCase();
    println("Trying to change cupMode to", s);
    
    // try to match the input string to a mode number:
    if (cupModeList.hasValue(s) == true) {
      for (int i = 0; i < cupModeList.size(); i++) {
        if (cupModeList.get(i).equals(s) ) {
          currentCupMode = i;
          break;
        }
      }
    } else {
      // mode not found, or we are just incrementing to the next mode
      if (currentCupMode < cupModeList.size() -1) {
        currentCupMode +=1;
      } else {
        currentCupMode = 0;
      }
    }
    
    println("currentCupMode:", currentCupMode, cupModeList.get(currentCupMode));
    cupMode = new CupTransparent();
    switch(currentCupMode) {
      case 0: // No cup rendering
        cupMode = new CupTransparent();
        break;
      case 1: // SOLIDCOLOUR
        cupMode = new CupSolidColour(this);
        break;
      case 2: // SOLIDCOLOUR TRANSPARENT
        cupMode = new CupSolidColour(this, true, true);
        break;
      default:
        cupMode = new CupTransparent();
        break;
    }
  }
  
}