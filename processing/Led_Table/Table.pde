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
  
}