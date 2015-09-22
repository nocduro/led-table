import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import processing.net.*; 
import java.net.*; 
import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Full_Table_Dot extends PApplet {




Serial myPort;
Server tcpServer;

OPC opc;
PImage dot;

// data arrays
boolean[] irData = new boolean[20];
boolean[] buttonData = new boolean [4];
int[] analogData = new int[4];

int brightness = 100;
boolean calibrating = false;
String statusMessage = "";

public void setup()
{
  // Setup mm to pixel multiplier
  float mmPerPixel = 2.5f;
  float mmWidthTable = 609.6f;
  float mmLengthTable = 2438.4f;
  
  size(floor(mmLengthTable/mmPerPixel), floor(mmWidthTable/mmPerPixel), P3D);
  
  // Setup serial connection
  println(myPort.list());
  
  try{
    myPort = new Serial(this, Serial.list()[0], 9600);
    myPort.bufferUntil('\n');
  }
  catch(Exception e){
    statusMessage += "Unable to bind serial port";     
  }
    
  
  // setup server
  tcpServer = new Server(this, 5204);
  
  
  dot = loadImage("dot.png");
  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  try
  {
    opc = new OPC(this, "127.0.0.1", 7890);
    
    // Draw the main grid to the screen
    opc.ledGridRotated(0, 15, 30, height/2.0f, width/2.0f, 33/mmPerPixel, 33/mmPerPixel, 0.0f, true);
    // Draw left 10 cup arrangement
    opc.ledRing(450, 6, 75/mmPerPixel, 155/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(456, 6, 75/mmPerPixel, 255/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(462, 6, 75/mmPerPixel, 355/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(468, 6, 75/mmPerPixel, 455/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(474, 6, 162/mmPerPixel, 205/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(480, 6, 162/mmPerPixel, 305/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(486, 6, 162/mmPerPixel, 405/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(492, 6, 248/mmPerPixel, 255/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(498, 6, 248/mmPerPixel, 355/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(504, 6, 335/mmPerPixel, 305/mmPerPixel, 31.83f/mmPerPixel, PI);
    // Draw the right 10 cup arrangement
    opc.ledRing(510, 6, width - 75/mmPerPixel, 155/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(516, 6, width - 75/mmPerPixel, 255/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(522, 6, width - 75/mmPerPixel, 355/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(528, 6, width - 75/mmPerPixel, 455/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(534, 6, width - 162/mmPerPixel, 205/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(540, 6, width - 162/mmPerPixel, 305/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(546, 6, width - 162/mmPerPixel, 405/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(552, 6, width - 248/mmPerPixel, 255/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(558, 6, width - 248/mmPerPixel, 355/mmPerPixel, 31.83f/mmPerPixel, PI);
    opc.ledRing(564, 6, width - 335/mmPerPixel, 305/mmPerPixel, 31.83f/mmPerPixel, PI);
  }
  catch(Exception e){
    statusMessage += "Unable to connect to OPC server"; 
  }
  

}

public void draw()
{
  // network stuff
  Client client = tcpServer.available();
  if (client != null)
  {
    String whatClientSaid = client.readString();
    if(whatClientSaid != null)
    {
      // receive command from app     
     receiveMessage(whatClientSaid); 
    }
  }
  
  
  background(0);
  
  // Change the dot size as a function of time, to make it "throb"
  float dotSize = height * 0.6f * (1.0f + 0.2f * sin(millis() * 0.01f));
  
  // Draw it centered at the mouse location
  image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
} // end of draw()


public void serialEvent(Serial p)
{
  String serialInputData = p.readString();
  //println(serialInputData);
  
  // each line of data is sent seperately for now. The data type, data pin, and value are seperated by spaces
  // here we seperate that info. example: "IR 3 ON" means that IR detector #3 is now on
  // format is "DATA_TYPE DATA_NUMBER VALUE"
  String[] data = split(serialInputData, ' ');
  int dataType = 0;
  
  if (data[0].equals("IR")){
   dataType = 1; 
  } else if (data[0].equals("ANALOG")){
   dataType = 2; 
  } else if (data[0].equals("BUTTON")){
   dataType = 3; 
  } else if (data[0].equals("INFO")){
   dataType = 4; 
  } else if (data[0].equals("COMMAND")){
   dataType = 5; 
  }
  
  
  switch(dataType)
  {
    case 1:
      if (data[2] == "ON"){
        irData[PApplet.parseInt(data[1])] = true;
      } else if (data[2] == "OFF"){
        irData[PApplet.parseInt(data[1])] = false;
      }    
      break;
    case 2:
      analogData[PApplet.parseInt(data[1])] = PApplet.parseInt(data[2]);
      break;
    case 3:
      if (data[2] == "ON"){
        buttonData[PApplet.parseInt(data[1])] = true;
      } else if (data[2] == "OFF"){
        buttonData[PApplet.parseInt(data[1])] = false;
      } 
      break;
    case 4:
      println(serialInputData);
      break;
    case 5:
      String commandMessage = "";
      for (int i = 1; i < data.length; i++){
        commandMessage += data[i];
      }
      receiveMessage(commandMessage);
    default:
      break;   
  } 
} // end serial event

public void receiveMessage(String message)
{
  println("tcpServer message: " + message);
  
  // debug stuff
  String reply = "I received this message: " + message;
  //sendMessage(reply);
  
  String[] data = split(message, ' ');
  
  if (data[0].equals("brightness") && data.length == 2){
   changeBrightness(PApplet.parseInt(trim(data[1])) );
   sendMessage("You set the brightness to " + brightness);
  } else if (data[0].equals("mode") && data.length > 1){
    // mode selection from tcp client
    if (data[1].equals("bubbles")){
      changeMode("bubbles");
    } else if (data[1].equals("soundReactive")){
      changeMode("soundReactive"); 
    }
  } else if (message.trim().equals("firstConnect")){
    if (statusMessage.equals("")){
      statusMessage = "No startup errors; "; 
    }
    statusMessage += "brightness: " + brightness + "; mode ";
    sendMessage(statusMessage);
  } else if (data[0].equals("shutdown") && data.length == 1){
    // shutdown the pi gracefully somehow
    
  } else if (data[0].equals("calibrateSensors") && data.length == 1){
    calibrateSensors(); 
  } else if (data[0].equals("Calibration") && data[1].equals("complete")){
    calibrating = false; 
  }
  

} // end receive message


public void sendMessage(String message)
{
  // for some reason I can only get the server to send strings
  // so send the length of the message as a string of the first four characters
  
  int messageLength = message.length();
  String messageLengthString = "";
  if (messageLength == 0)
  {
    return;
  }else if (messageLength < 10)
  {
    messageLengthString = "000" + str(messageLength);
  }else if (messageLength < 100)
  {
    messageLengthString = "00" + str(messageLength); 
  }else if (messageLength < 1000)
  {
    messageLengthString = "0" + str(messageLength); 
  }else if (messageLength < 10000)
  {
    messageLengthString = str(messageLength); 
  }
  

  String messageToSend = messageLengthString + message;
  
  
  
  try 
  {
    tcpServer.write(messageToSend);
    println("Sent network message: " + messageToSend);
  }
  catch(Exception e)
  {
    println("Failed to send network message: " + messageToSend);    
  }
  
  
  
} // end send message

public void changeBrightness(int b)
{
  opc.setColorCorrection(2.5f, b/100, b/100, b/100);  
  brightness = b;
}

public void calibrateSensors()
{
  // DISPLAY MESSAGE ON GRID TO REMOVE CUPS
  
  // TELL ARDUINO TO CALIBRATE
  try
  {
    myPort.write("calibrate");
    calibrating = true;
  }
  catch(Exception e)
  {
    return; 
  }

  
  // DISPLAY COUNTDOWN WHILE CALIBRATING
  
  // WAIT FOR ARDUINO TO SAY IT'S DONE
  while(calibrating){
   // blink leds red
  }
  
  // MAKE LIGHTS GREEN INSTEAD OF RED
  // RESUME PROGRAM

} // end calibrateSensors


public void changeMode(String mode)
{
  println("Mode tried to change to: " + mode);
  
}
/*
 * Simple Open Pixel Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013
 * This file is released into the public domain.
 */




public class OPC
{
  Socket socket;
  OutputStream output;
  String host;
  int port;

  int[] pixelLocations;
  byte[] packetData;
  byte firmwareConfig;
  String colorCorrection;
  boolean enableShowLocations;

  OPC(PApplet parent, String host, int port)
  {
    this.host = host;
    this.port = port;
    this.enableShowLocations = true;
    parent.registerDraw(this);
  }

  // Set the location of a single LED
  public void led(int index, int x, int y)  
  {
    // For convenience, automatically grow the pixelLocations array. We do want this to be an array,
    // instead of a HashMap, to keep draw() as fast as it can be.
    if (pixelLocations == null) {
      pixelLocations = new int[index + 1];
    } else if (index >= pixelLocations.length) {
      pixelLocations = Arrays.copyOf(pixelLocations, index + 1);
    }

    pixelLocations[index] = x + width * y;
  }
  
  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  public void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i),
        (int)(x + (i - (count-1)/2.0f) * spacing * c + 0.5f),
        (int)(y + (i - (count-1)/2.0f) * spacing * s + 0.5f));
    }
  }

  // Set the locations of a ring of LEDs. The center of the ring is at (x, y),
  // with "radius" pixels between the center and each LED. The first LED is at
  // the indicated angle, in radians, measured clockwise from +X.
  public void ledRing(int index, int count, float x, float y, float radius, float angle)
  {
    for (int i = 0; i < count; i++) {
      float a = angle + i * 2 * PI / count;
      led(index + i, (int)(x - radius * cos(a) + 0.5f),
        (int)(y - radius * sin(a) + 0.5f));
    }
  }

  // Set the location of several LEDs arranged in a grid. The first strip is
  // at 'angle', measured in radians clockwise from +X.
  // (x,y) is the center of the grid.
  public void ledGrid(int index, int stripLength, int numStrips, float x, float y,
               float ledSpacing, float stripSpacing, float angle, boolean zigzag)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(index + stripLength * i, stripLength,
        - (x + (i - (numStrips-1)/2.0f) * stripSpacing * c),
        y + (i - (numStrips-1)/2.0f) * stripSpacing * s, ledSpacing,
        angle, zigzag && (i % 2) == 1);
    }
  }
  
  public void ledGridRotated(int index, int stripLength, int numStrips, float x, float y,
               float ledSpacing, float stripSpacing, float angle, boolean zigzag)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(
        index + stripLength * i, 
        stripLength,
        y + (i - (numStrips-1)/2.0f) * stripSpacing * s,
        x + (i - (numStrips-1)/2.0f) * stripSpacing * c, 
        ledSpacing,
        angle +(3* HALF_PI), 
        zigzag && (i % 2) == 1);
    }
  }
  
  

  // Set the location of 64 LEDs arranged in a uniform 8x8 grid.
  // (x,y) is the center of the grid.
  public void ledGrid8x8(int index, float x, float y, float spacing, float angle, boolean zigzag)
  {
    ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag);
  }

  // Should the pixel sampling locations be visible? This helps with debugging.
  // Showing locations is enabled by default. You might need to disable it if our drawing
  // is interfering with your processing sketch, or if you'd simply like the screen to be
  // less cluttered.
  public void showLocations(boolean enabled)
  {
    enableShowLocations = enabled;
  }
  
  // Enable or disable dithering. Dithering avoids the "stair-stepping" artifact and increases color
  // resolution by quickly jittering between adjacent 8-bit brightness levels about 400 times a second.
  // Dithering is on by default.
  public void setDithering(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x01;
    else
      firmwareConfig |= 0x01;
    sendFirmwareConfigPacket();
  }

  // Enable or disable frame interpolation. Interpolation automatically blends between consecutive frames
  // in hardware, and it does so with 16-bit per channel resolution. Combined with dithering, this helps make
  // fades very smooth. Interpolation is on by default.
  public void setInterpolation(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x02;
    else
      firmwareConfig |= 0x02;
    sendFirmwareConfigPacket();
  }

  // Put the Fadecandy onboard LED under automatic control. It blinks any time the firmware processes a packet.
  // This is the default configuration for the LED.
  public void statusLedAuto()
  {
    firmwareConfig &= 0x0C;
    sendFirmwareConfigPacket();
  }    

  // Manually turn the Fadecandy onboard LED on or off. This disables automatic LED control.
  public void setStatusLed(boolean on)
  {
    firmwareConfig |= 0x04;   // Manual LED control
    if (on)
      firmwareConfig |= 0x08;
    else
      firmwareConfig &= ~0x08;
    sendFirmwareConfigPacket();
  } 

  // Set the color correction parameters
  public void setColorCorrection(float gamma, float red, float green, float blue)
  {
    colorCorrection = "{ \"gamma\": " + gamma + ", \"whitepoint\": [" + red + "," + green + "," + blue + "]}";
    sendColorCorrectionPacket();
  }
  
  // Set custom color correction parameters from a string
  public void setColorCorrection(String s)
  {
    colorCorrection = s;
    sendColorCorrectionPacket();
  }

  // Send a packet with the current firmware configuration settings
  public void sendFirmwareConfigPacket()
  {
    if (output == null) {
      // We'll do this when we reconnect
      return;
    }
 
    byte[] packet = new byte[9];
    packet[0] = 0;          // Channel (reserved)
    packet[1] = (byte)0xFF; // Command (System Exclusive)
    packet[2] = 0;          // Length high byte
    packet[3] = 5;          // Length low byte
    packet[4] = 0x00;       // System ID high byte
    packet[5] = 0x01;       // System ID low byte
    packet[6] = 0x00;       // Command ID high byte
    packet[7] = 0x02;       // Command ID low byte
    packet[8] = firmwareConfig;

    try {
      output.write(packet);
    } catch (Exception e) {
      dispose();
    }
  }

  // Send a packet with the current color correction settings
  public void sendColorCorrectionPacket()
  {
    if (colorCorrection == null) {
      // No color correction defined
      return;
    }
    if (output == null) {
      // We'll do this when we reconnect
      return;
    }

    byte[] content = colorCorrection.getBytes();
    int packetLen = content.length + 4;
    byte[] header = new byte[8];
    header[0] = 0;          // Channel (reserved)
    header[1] = (byte)0xFF; // Command (System Exclusive)
    header[2] = (byte)(packetLen >> 8);
    header[3] = (byte)(packetLen & 0xFF);
    header[4] = 0x00;       // System ID high byte
    header[5] = 0x01;       // System ID low byte
    header[6] = 0x00;       // Command ID high byte
    header[7] = 0x01;       // Command ID low byte

    try {
      output.write(header);
      output.write(content);
    } catch (Exception e) {
      dispose();
    }
  }

  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  public void draw()
  {
    if (pixelLocations == null) {
      // No pixels defined yet
      return;
    }
 
    if (output == null) {
      // Try to (re)connect
      connect();
    }
    if (output == null) {
      return;
    }

    int numPixels = pixelLocations.length;
    int ledAddress = 4;

    setPixelCount(numPixels);
    loadPixels();

    for (int i = 0; i < numPixels; i++) {
      int pixelLocation = pixelLocations[i];
      int pixel = pixels[pixelLocation];

      packetData[ledAddress] = (byte)(pixel >> 16);
      packetData[ledAddress + 1] = (byte)(pixel >> 8);
      packetData[ledAddress + 2] = (byte)pixel;
      ledAddress += 3;

      if (enableShowLocations) {
        pixels[pixelLocation] = 0xFFFFFF ^ pixel;
      }
    }

    writePixels();

    if (enableShowLocations) {
      updatePixels();
    }
  }
  
  // Change the number of pixels in our output packet.
  // This is normally not needed; the output packet is automatically sized
  // by draw() and by setPixel().
  public void setPixelCount(int numPixels)
  {
    int numBytes = 3 * numPixels;
    int packetLen = 4 + numBytes;
    if (packetData == null || packetData.length != packetLen) {
      // Set up our packet buffer
      packetData = new byte[packetLen];
      packetData[0] = 0;  // Channel
      packetData[1] = 0;  // Command (Set pixel colors)
      packetData[2] = (byte)(numBytes >> 8);
      packetData[3] = (byte)(numBytes & 0xFF);
    }
  }
  
  // Directly manipulate a pixel in the output buffer. This isn't needed
  // for pixels that are mapped to the screen.
  public void setPixel(int number, int c)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      setPixelCount(number + 1);
    }

    packetData[offset] = (byte) (c >> 16);
    packetData[offset + 1] = (byte) (c >> 8);
    packetData[offset + 2] = (byte) c;
  }
  
  // Read a pixel from the output buffer. If the pixel was mapped to the display,
  // this returns the value we captured on the previous frame.
  public int getPixel(int number)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      return 0;
    }
    return (packetData[offset] << 16) | (packetData[offset + 1] << 8) | packetData[offset + 2];
  }

  // Transmit our current buffer of pixel values to the OPC server. This is handled
  // automatically in draw() if any pixels are mapped to the screen, but if you haven't
  // mapped any pixels to the screen you'll want to call this directly.
  public void writePixels()
  {
    if (packetData == null || packetData.length == 0) {
      // No pixel buffer
      return;
    }
    if (output == null) {
      // Try to (re)connect
      connect();
    }
    if (output == null) {
      return;
    }

    try {
      output.write(packetData);
    } catch (Exception e) {
      dispose();
    }
  }

  public void dispose()
  {
    // Destroy the socket. Called internally when we've disconnected.
    if (output != null) {
      println("Disconnected from OPC server");
    }
    socket = null;
    output = null;
  }

  public void connect()
  {
    // Try to connect to the OPC server. This normally happens automatically in draw()
    try {
      socket = new Socket(host, port);
      socket.setTcpNoDelay(true);
      output = socket.getOutputStream();
      println("Connected to OPC server");
    } catch (ConnectException e) {
      dispose();
    } catch (IOException e) {
      dispose();
    }
    
    sendColorCorrectionPacket();
    sendFirmwareConfigPacket();
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Full_Table_Dot" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
