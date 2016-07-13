public class LEDTable
{
  boolean[] irData = new boolean[20];
  float[] analogData = new float[4];
  float[] cupX = new float[20];
  float[] cupY = new float[20];
  int drawFrameRate, tableWidth, tableLength;
  float mmPerPixel;
  int cupDiameter, brightness;
  
  Mode mode;
  CupMode cupMode;
  StringList modeList;
  int currentMode = 1;
  StringList cupModeList;
  int currentCupMode = 1;
  
  // set the colour
  IntList colours = new IntList();
  
  LEDTable(float tableWidthMM, float tableLengthMM, int drawFrameRate, float mmPerPixel) {
    this.drawFrameRate = drawFrameRate;
    this.cupDiameter = ceil(75/mmPerPixel)+2;
    this.tableWidth = floor(tableWidthMM/mmPerPixel);
    this.tableLength = floor(tableLengthMM/mmPerPixel);
    this.mmPerPixel = mmPerPixel;
    this.brightness = 100;
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
    table.brightness = b;
    println("Color correction: " + opc.colorCorrection);
  }
  
  
  void changeColour(int colourToChange, String c) {
    if (colourToChange > 4 || colourToChange < 0) {
      return;
    }
    c = "FF" + c; // make sure alpha channel is opaque
    table.colours.set(colourToChange, unhex(c));
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
    if (table.modeList.hasValue(s) == true) {
      for (int i = 0; i < table.modeList.size(); i++) {
        if (table.modeList.get(i).equals(s) ) {
          table.currentMode = i;
          break;
        }
      }
    } else {
      // mode not found, or we are just incrementing to the next mode
      if (table.currentMode < table.modeList.size() -1) {
        table.currentMode +=1;
      } else {
        table.currentMode = 0;
      }
    }
    println("currentMode:", table.currentMode, table.modeList.get(table.currentMode));
    switch(table.currentMode) {
      case 0: // OFF
        table.mode = new SolidColour(0);
        break;
      case 1: // SOLIDCOLOUR
        table.mode = new SolidColour(table);
        break;
      case 2: // RAINBOW
        table.mode = new Rainbow(table);
        break;
      case 3:
        table.mode = new RotatingCube(table);
        break;
      case 4:
        table.mode = new SoundBall(table, sound);
        break;
      case 5:
        // Bubbles(count, size, lifespan);
        table.mode = new Bubbles(table, 30, 85, 100);
        break;
      case 6:
        table.mode = new Bubbles(table, 30,85,100, table.colours.get(0));
        break;
      case 7: // 'stars' using bubbles
        table.mode = new Bubbles(table, 30, 15, 100);
        break;
      default:
        table.mode = new SolidColour(0);
        break;
    }
  }
  
  
  void changeCupMode(String s) {
    s = s.trim().toUpperCase();
    println("Trying to change cupMode to", s);
    
    // try to match the input string to a mode number:
    if (table.cupModeList.hasValue(s) == true) {
      for (int i = 0; i < table.cupModeList.size(); i++) {
        if (table.cupModeList.get(i).equals(s) ) {
          table.currentCupMode = i;
          break;
        }
      }
    } else {
      // mode not found, or we are just incrementing to the next mode
      if (table.currentCupMode < table.cupModeList.size() -1) {
        table.currentCupMode +=1;
      } else {
        table.currentCupMode = 0;
      }
    }
    
    println("currentCupMode:", table.currentCupMode, table.cupModeList.get(table.currentCupMode));
    table.cupMode = new CupTransparent();
    switch(table.currentCupMode) {
      case 0: // No cup rendering
        table.cupMode = new CupTransparent();
        break;
      case 1: // SOLIDCOLOUR
        table.cupMode = new CupSolidColour(table);
        break;
      case 2: // SOLIDCOLOUR TRANSPARENT
        table.cupMode = new CupSolidColour(table, true, true);
        break;
      default:
        table.cupMode = new CupTransparent();
        break;
    }
  }
  
}