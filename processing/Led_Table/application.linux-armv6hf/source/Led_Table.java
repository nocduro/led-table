import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import processing.net.*; 
import ddf.minim.analysis.*; 
import ddf.minim.*; 
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

public class Led_Table extends PApplet {







//String tableIP = "192.168.0.166";
String tableIP = "127.0.0.1";

//TEMP
PImage dot;


//Serial myPort;
Server tcpServer;
Client serialClient;
OPC opc;
Modes modes;

int drawFrameRate = 60;

// data arrays
int[] analogData = new int[4];

int brightness = 100;
boolean calibrating = false;
boolean activeMode = false;
String statusMessage = "";
byte mode = 3;
/*
0 => off
1 => test mode / startup animation
2 => solid colour
*/

int primaryColour = 0xff000099;
int secondaryColour = 0xffFF0000;

// fft
Minim minim;
AudioInput sound;
FFT fft;
float logMultiplier;
FloatList findMax = new FloatList();


public void setup()
{
  println("Starting setup.");
  // Setup mm to pixel multiplier
  float mmPerPixel = 1.5f; // changes how large the processing window will be
  float mmWidthTable = 609.6f; // physical width of table
  float mmLengthTable = 2438.4f; // physical length of table
  
  
  
  // Throws an error when this is enabled
  //surface.setResizable(true);
  surface.setSize(floor(mmLengthTable/mmPerPixel), floor(mmWidthTable/mmPerPixel)); 
  
  modes = new Modes(this, drawFrameRate, mmPerPixel);
  
  // Audio setup
  minim = new Minim(this);
  sound = minim.getLineIn(Minim.STEREO, 2048);
  fft = new FFT(sound.bufferSize(), sound.sampleRate());
  logMultiplier = fft.specSize() / (64*(log(64) - 1));

  
  /* DISABLE SERIAL FOR NOW
  // Setup serial connection
  println(myPort.list());
  
  try
  {
    myPort = new Serial(this, Serial.list()[0], 9600);
    myPort.bufferUntil('\n');
    println("Serial connection established on " + Serial.list()[0]);
  }
  catch(Exception e){
    statusMessage += "Unable to bind serial port";     
  }
    
  */
  // setup server
  tcpServer = new Server(this, 5204);
  try
  {
    print("Trying to connect to serial server.....");
    serialClient = new Client(this, tableIP, 12500);
    println("CONNECTED");
  }
  catch(Exception e) {
    statusMessage += "Unable to connect to serial server"; 
    println("Can't connect to serial server");
  }

 
  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  try
  {
    print("Connecting to FadeCandy Server.....");
    opc = new OPC(this, tableIP, 7890);
    
    //void ledGridRotated(int index, int stripLength, int numStrips, float x, float y, float ledSpacing, float stripSpacing, float angle, boolean zigzag)
    // Draw the main grid to the screen
    opc.ledGridRotated(0, 15, 30, height/2.0f, width/2.0f, 33/mmPerPixel, 33/mmPerPixel, 0.0f, true);
    // Draw left 10 cup arrangement
    // void ledRing(int index, int count, float x, float y, float radius, float angle)
    opc.ledRing(450, 6, 335/mmPerPixel, 305/mmPerPixel, 31.83f/mmPerPixel, 0); //0
    opc.ledRing(456, 6, 248/mmPerPixel, 255/mmPerPixel, 31.83f/mmPerPixel, 0); //1
    opc.ledRing(462, 6, 248/mmPerPixel, 355/mmPerPixel, 31.83f/mmPerPixel, 0); //2
    opc.ledRing(468, 6, 162/mmPerPixel, 405/mmPerPixel, 31.83f/mmPerPixel, 0); //3
    opc.ledRing(474, 6, 162/mmPerPixel, 305/mmPerPixel, 31.83f/mmPerPixel, 0); //4
    opc.ledRing(480, 6, 162/mmPerPixel, 205/mmPerPixel, 31.83f/mmPerPixel, 0); //5
    opc.ledRing(486, 6, 75/mmPerPixel, 155/mmPerPixel, 31.83f/mmPerPixel, 0); //6
    opc.ledRing(492, 6, 75/mmPerPixel, 255/mmPerPixel, 31.83f/mmPerPixel, 0); //7
    opc.ledRing(498, 6, 75/mmPerPixel, 355/mmPerPixel, 31.83f/mmPerPixel, 0); //8
    opc.ledRing(504, 6, 75/mmPerPixel, 455/mmPerPixel, 31.83f/mmPerPixel, 0); //9
    
    
    // Draw the right 10 cup arrangement
    opc.ledRing(510, 6, width - 335/mmPerPixel, 305/mmPerPixel, 31.83f/mmPerPixel, PI); //0
    opc.ledRing(516, 6, width - 248/mmPerPixel, 355/mmPerPixel, 31.83f/mmPerPixel, PI); //1
    opc.ledRing(522, 6, width - 248/mmPerPixel, 255/mmPerPixel, 31.83f/mmPerPixel, PI); //2
    opc.ledRing(528, 6, width - 162/mmPerPixel, 205/mmPerPixel, 31.83f/mmPerPixel, PI); //3
    opc.ledRing(534, 6, width - 162/mmPerPixel, 305/mmPerPixel, 31.83f/mmPerPixel, PI); //4
    opc.ledRing(540, 6, width - 162/mmPerPixel, 405/mmPerPixel, 31.83f/mmPerPixel, PI); //5
    opc.ledRing(546, 6, width - 75/mmPerPixel, 455/mmPerPixel, 31.83f/mmPerPixel, PI); //6
    opc.ledRing(552, 6, width - 75/mmPerPixel, 355/mmPerPixel, 31.83f/mmPerPixel, PI); //7
    opc.ledRing(558, 6, width - 75/mmPerPixel, 255/mmPerPixel, 31.83f/mmPerPixel, PI); //8
    opc.ledRing(564, 6, width - 75/mmPerPixel, 155/mmPerPixel, 31.83f/mmPerPixel, PI); //9
    
    
    opc.connect();
  }
  catch(Exception e){
    statusMessage += "Unable to connect to OPC server"; 
  }

  frameRate(drawFrameRate);
  println("Frame rate set to: " + drawFrameRate);
  println("Color correction: " + opc.colorCorrection);
  
  fftUpdate();
  println("SETUP COMPLETE.");
}


public void draw()
{
  // Animation testing
  checkForCommands();

  // mode selection
  switch (mode)
  {
    case 0:
      modes.off();
      break;
    case 1:
      modes.rotateCube(primaryColour, secondaryColour);
      //modes.dot();
      break;
    case 2:
      modes.solidColour(primaryColour, secondaryColour);
      break;
    case 3:
      fftUpdate();
      modes.soundTest(primaryColour, secondaryColour);
      break;
    case 4:
      modes.bubbles(primaryColour);
      break;
      
      
    default:
      modes.off();
      break;   
      
  } // end of switch
}


public void modeChange(String m)
{
  if (m.equals("TOGGLE")){
    if (mode == 4){
      mode = 0;
    } else {
      mode++;
    }
  } else if (m.equals("OFF")){
    mode = 0;
  } else if (m.equals("ROTATECUBE")){
    mode = 1;
  } else if (m.equals("SOLIDCOLOUR")){
    mode = 2;
  } else if (m.equals("SOUNDTEST")){
    mode = 3;
  } else if (m.equals("BUBBLES")){
    mode = 4;
  }
    
   
  println("Mode changed to: " + m);
  //sendMessage("Mode changed to " +m);
  modes.modeCounter = 0;
}




public void serialEvent(Serial p)
{
  String serialInputData = p.readString();
  //println(serialInputData);
  
  
} // end serial event


public void serialMessage(String serialData)
{
  // each line of data is sent seperately for now. The data type, data pin, and value are seperated by spaces
  // here we seperate that info. example: "SERIAL IR 3 ON" means that IR detector #3 is now on sent via serial port
  // format is "SERIAL DATA_TYPE DATA_NUMBER VALUE"
  String[] data = split(serialData, ' ');
  int dataType = 0;
  
  // can't figure out how to use enums, so convert to int for the switch
  // try to fix this in the future
  
  if (data[1].equals("IR")){
   dataType = 1; 
  } else if (data[1].equals("ANALOG")){
   dataType = 2; 
  } else if (data[1].equals("BUTTON")){
   dataType = 3; 
  } else if (data[1].equals("INFO")){
   dataType = 4; 
  } else if (data[1].equals("BRIGHTNESS")){
    //debug testing
    //changeBrightness(int(data[2].trim()));
  }

  switch(dataType)
  {
    case 1:
      if (data[3].trim().equals("ON")){
        modes.irData[PApplet.parseInt(data[2])] = true;
      } else if (data[3].trim().equals("OFF")){
        modes.irData[PApplet.parseInt(data[2])] = false;
      }    
      break;
    case 2:
      analogData[PApplet.parseInt(data[2])] = PApplet.parseInt(data[3]);
      break;
    case 3:
      if (data[3].trim().equals("PRESSED")){
        buttonPressed(PApplet.parseInt(data[2]));
      } else if (data[3].trim().equals("HELD")){
        buttonHeld(PApplet.parseInt(data[2]));
      } 
      break;
    case 4:
      println(serialData);
      break;
    default:
      break;   
  } 
}






public void receiveMessage(String message)
{
  println("Received message: " + message);
  
  // debug stuff
  //String reply = "I received this message: " + message;
  //sendMessage(reply);
  
  /* Incoming messages are formatted as:
   * COMMAND DATA1 DATA2
   * command and data are seperated by spaces
   */
  
  // seperate the command and the data
  String[] data = split(message, ' ');
  String command = data[0].trim().toUpperCase();
  
  
  if (command.equals("BRIGHTNESS") && data.length == 2){
   
   changeBrightness(PApplet.parseInt(trim(data[1])) );
   sendMessage("You set the brightness to " + brightness);
   
  } else if (command.equals("SERIAL")){
    serialMessage(message);    
  } else if (command.equals("MODE") && data.length > 1){
    modeChange(data[1].trim().toUpperCase());
  } else if (message.trim().equals("firstConnect")){
    if (statusMessage.equals("")){
      statusMessage = "No startup errors; "; 
    }
    statusMessage += "brightness: " + brightness + "; mode ";
    sendMessage(statusMessage);
  } else if (command.equals("SHUTDOWN") && data.length == 1){
    // shutdown the pi gracefully somehow
    
  } else if (command.equals("CALIBRATESENSORS") && data.length == 1){
    calibrateSensors(); 
  } else if (command.equals("CALIBRATION") && data[1].trim().toUpperCase().equals("COMPLETE")){
    calibrating = false; 
  } else if (command.equals("COLOUR") || command.equals("COLOR")){
    changeColour(data[1].trim().toUpperCase(), data[2].trim().toUpperCase());
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
  opc.setColorCorrection(2.5f, b/100f, b/100f, b/100f);  
  brightness = b;
  println("Color correction: " + opc.colorCorrection);
}



public void calibrateSensors()
{
  // DISPLAY MESSAGE ON GRID TO REMOVE CUPS
  
  // TELL ARDUINO TO CALIBRATE
  try
  {
    
  }
  catch(Exception e)
  {
    println("Unable to send calibrate command to arduino");
    return; 
  }
  
  // DISPLAY COUNTDOWN WHILE CALIBRATING
  
  // WAIT FOR ARDUINO TO SAY IT'S DONE
  while(calibrating){
   // blink leds red
  }
  
  // MAKE LIGHTS GREEN INSTEAD OF RED
  // RESUME PREVIOUS MODE

} // end calibrateSensors



public void checkForCommands()
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
  
  if (serialClient.available() > 0 )
  {
    String networkSerial = serialClient.readStringUntil('\n');
    if(networkSerial != null)
    {
      receiveMessage("SERIAL " + networkSerial);
    }
  }
  
  
  
} // end checkForCommands







public void changeColour(String colourToChange, String c)
{
  c = "FF" + c; // make sure alpha channel is opaque
  if (colourToChange.equals("PRIMARY") && c.length() == 8)
  {
    primaryColour = unhex(c);
    println("Colour changed to: " + c);
    sendMessage("Primary colour changed to: " + c);
  } else if (colourToChange.equals("SECONDARY") && c.length() == 8)
  {
    secondaryColour = unhex(c);
    println("Colour changed to: " + c);
    sendMessage("Secondary colour changed to: " + c);
  }
}


public void buttonPressed(int b)
{
  switch (b)
  {
    case 1:
      modeChange("TOGGLE");
      break;
    case 2:
      break;
    case 3:
      break;
    default:
      println("Unrecognized button press");
  }
  
}


public void buttonHeld(int b)
{
  switch (b)
  {
    case 1:
      modeChange("OFF");
      break;
    case 2:
      break;
    case 3:
      break;
    default:
      println("Unrecognized button press");
  }
  
}



public void fftUpdate()
{
  fft.forward(sound.mix);
  int freqCount = 0; // what frequency are we on?
  int startingFreq = 20; // frequency in Hz to start at
  
  for (int i = 1; i <= 64; i++)
  {
    //modes.prevFFT[i-1] = modes.currentFFT[i-1];
    float average = 0;
    float maxVal = 0;
    int frequenciesAveraged = 0;
    int numberOfFreqToAvg = round(logMultiplier*log(i)); // determines how many frequencies in each of the 64 bars with more freq included for higher frequencies
    
    for (int j = startingFreq + freqCount; j < numberOfFreqToAvg + freqCount + startingFreq; j++) // add all the frequencies for a bar to a floatList which lets us easily find the max (highest amplitude of those frequencies)
    {
      findMax.append(fft.getFreq(j));
      
    }
    if (findMax.size() > 0)
    {
      maxVal = findMax.max();
      for (int k = 0; k < findMax.size(); k++)
      {
        if (findMax.get(k) > 0.6f * maxVal)// this only averages the values that are at least XX% of the max value which makes the higher frequenceis more responsive
        {
          average += findMax.get(k);
          frequenciesAveraged++;
        }
      }
    }
    
    float val = norm( (average / frequenciesAveraged), 0, 125); // normalize to betweeen 0 and 1 and make sure it doesn't exceed those values
    if (val > 1){
      val = 1;
    }
    if (val < 0){
      val = 0;
    }
    
    float testVal = average/frequenciesAveraged;
    
    modes.currentFFT[i-1] = val;
    freqCount += numberOfFreqToAvg;
    findMax.clear();     
  }
  
}
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
  
  
  public void off()
  {
    background(0);    
  }
  
  
  public void rotateCube(int c, int secondary)
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
  
  
  
  public void solidColour(int primary, int secondary)
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
  
  
  public void dot()
  {
    background(0);
    image(dot, mouseX -50, mouseY -50, 100, 100);   
    
  }
  
  
  public void soundTest(int primary, int secondary)
  {
    FloatList temp = new FloatList();
    for (int i = 0; i < 10; i++){
      temp.append(currentFFT[i]); 
    }
    background(0);
    blendMode(ADD);
    
    
    float current = temp.max();
    float size = 600 * max(current, prevFFT[0] * 0.97f);
    
    tint(primary);
    
    image(dot, width/2 - size/2, height/2 - size/2, size, size);
    if (current > prevFFT[0]){
      prevFFT[0] = current;
    } else {
      prevFFT[0] = prevFFT[0] * 0.97f;
    }
    temp.clear();
    
    
    // secondary
    for (int i = 40; i < 64; i++)
    {
      temp.append(currentFFT[i]);
    }
    float current2 = temp.max();
    size = 650 * max(current2, prevFFT[1] * 0.97f);
    tint(secondary);
    
    image(dot, width/2 - size/2, height/2 - size/2, size, size);
    if (current2 > prevFFT[1]){
      prevFFT[1] = current2;
    } else {
      prevFFT[1] = prevFFT[1] * 0.97f;
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
  
  public void bubbles(int primaryColour)
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
  
  
  
  
  

  
  
  
  public void generateCoordinates()
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
  int primaryColour;
  
  Particle(PVector p){
    acceleration = new PVector(0.01f, 0);
    velocity = PVector.random2D();
    location = p.get();
    lifespan = 255.0f;
  }
  Particle(int c)
  {
    acceleration = new PVector(0.01f, 0);
    velocity = PVector.random2D();
    location = new PVector(random(width), random(height));
    primaryColour = c;
    dot = loadImage("dot.png");
  }
  
  public void run()
  {
    update();
    display();
  }
  
  public void update()
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
  
  public void display()
  {
    //fill(255, lifespan);
    //ellipse(location.x, location.y, size, size);
    tint(primaryColour);
    image(dot, location.x - size/2, location.y - size/2, size, size);
  }
  
  public boolean isDead()
  {
    if (lifespan < 0.0f){
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
  
  public void addParticle(int c){
    particles.add(new Particle(c));
  }
  
  public void run() {
    for (int i = particles.size()-1; i >= 0; i--)
    {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()){
        particles.remove(i);
      }
    }
  }
  
  public void clearArray()
  {
    particles.clear();
  }
  
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
  public boolean firstConnect = false;
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
    parent.registerMethod("draw", this);
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
      firstConnect = true;
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
  public void settings() {  size(200, 200, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Led_Table" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
