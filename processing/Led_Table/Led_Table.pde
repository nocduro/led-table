import processing.net.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import java.net.*;
import java.util.Arrays;

/** Constants **/
final String tableIP = "127.0.0.1";
//final String tableIP = "192.168.0.225";
final int CONTROL_PORT = 5204; // port that web app uses to connect
final int drawFrameRate = 60;


Server tcpServer; // used to send commands to the sketch remotely
Client serialClient; // used for tcp connection to Arduino serial output
OPC opc; // open pixel control


// data arrays
int[] analogData = new int[4];

/** Initialize variables **/
int brightness = 100;
String statusMessage = "";


// Audio setup
Minim minim;
AudioInput sound; // microphone

Mode mode;
CupMode cupMode;
StringList modeList;
int currentMode = 1;
StringList cupModeList;
int currentCupMode = 1;


void setup() {
  println("Starting setup. V0.0.1a");
  
  
  /** WINDOW SETUP **/
  float mmPerPixel = 3; // changes how large the processing window will be
  float mmWidthTable = 609.6; // physical width of table
  float mmLengthTable = 2438.4; // physical length of table
  
  // initialize the table with constants used by other classes
  LEDTable.initialize(mmWidthTable, mmLengthTable, drawFrameRate, mmPerPixel);
  size(812, 203, P3D);
  
  // For some reason this code doesn't work on the Pi:
  //surface.setResizable(true);
  //surface.setSize(floor(mmLengthTable/mmPerPixel), floor(mmWidthTable/mmPerPixel)); 
  
  frameRate(drawFrameRate);
  
  println("Frame rate set to: " + drawFrameRate);
  
  /** AUDIO SETUP **/
  minim = new Minim(this);
  
  // connect to lineIn
  try {
    // this must be mono to work on the Pi
    // run: amixer set Mic Capture 16
    // to get maximum Microphone gain on Pi
    sound = minim.getLineIn(Minim.MONO, 2048, 48000.0, 16);
  } catch(Exception e) {
      statusMessage+= "Minim error: Unable to connect to LineIn";
      println("Minim error: " + e.getMessage());
  }
  
  /** NETWORK SETUP **/
  
  // server that web app connects to
  tcpServer = new Server(this, CONTROL_PORT);
  
  // tcpClient to read Arduino serial output via ser2net
  try {
    print("Trying to connect to serial server.....");
    serialClient = new Client(this, tableIP, 12500);
    println("CONNECTED");
  } catch (Exception e) {
      statusMessage += "Unable to connect to serial server"; 
      println("Unable to connect to Serial server: " + e.getMessage());
  }
 
  // Connect to the OPC server
  try {
    print("Connecting to FadeCandy Server.....");
    opc = new OPC(this, tableIP, 7890);
    
    //void ledGridRotated(int index, int stripLength, int numStrips, float x, float y, float ledSpacing, float stripSpacing, float angle, boolean zigzag)
    // Draw the main grid to the screen
    opc.ledGridRotated(0, 15, 30, height/2.0, width/2.0, 33/mmPerPixel, 33/mmPerPixel, 0.0, true);
    // Draw left 10 cup arrangement
    // void ledRing(int index, int count, float x, float y, float radius, float angle)
    opc.ledRing(450, 6, 335/mmPerPixel, 305/mmPerPixel, 31.83/mmPerPixel, 0); //0
    opc.ledRing(456, 6, 248/mmPerPixel, 255/mmPerPixel, 31.83/mmPerPixel, 0); //1
    opc.ledRing(462, 6, 248/mmPerPixel, 355/mmPerPixel, 31.83/mmPerPixel, 0); //2
    opc.ledRing(468, 6, 162/mmPerPixel, 405/mmPerPixel, 31.83/mmPerPixel, 0); //3
    opc.ledRing(474, 6, 162/mmPerPixel, 305/mmPerPixel, 31.83/mmPerPixel, 0); //4
    opc.ledRing(480, 6, 162/mmPerPixel, 205/mmPerPixel, 31.83/mmPerPixel, 0); //5
    opc.ledRing(486, 6, 75/mmPerPixel, 155/mmPerPixel, 31.83/mmPerPixel, 0); //6
    opc.ledRing(492, 6, 75/mmPerPixel, 255/mmPerPixel, 31.83/mmPerPixel, 0); //7
    opc.ledRing(498, 6, 75/mmPerPixel, 355/mmPerPixel, 31.83/mmPerPixel, 0); //8
    opc.ledRing(504, 6, 75/mmPerPixel, 455/mmPerPixel, 31.83/mmPerPixel, 0); //9
    
    
    // Draw the right 10 cup arrangement
    opc.ledRing(510, 6, width - 335/mmPerPixel, 305/mmPerPixel, 31.83/mmPerPixel, PI); //0
    opc.ledRing(516, 6, width - 248/mmPerPixel, 355/mmPerPixel, 31.83/mmPerPixel, PI); //1
    opc.ledRing(522, 6, width - 248/mmPerPixel, 255/mmPerPixel, 31.83/mmPerPixel, PI); //2
    opc.ledRing(528, 6, width - 162/mmPerPixel, 205/mmPerPixel, 31.83/mmPerPixel, PI); //3
    opc.ledRing(534, 6, width - 162/mmPerPixel, 305/mmPerPixel, 31.83/mmPerPixel, PI); //4
    opc.ledRing(540, 6, width - 162/mmPerPixel, 405/mmPerPixel, 31.83/mmPerPixel, PI); //5
    opc.ledRing(546, 6, width - 75/mmPerPixel, 455/mmPerPixel, 31.83/mmPerPixel, PI); //6
    opc.ledRing(552, 6, width - 75/mmPerPixel, 355/mmPerPixel, 31.83/mmPerPixel, PI); //7
    opc.ledRing(558, 6, width - 75/mmPerPixel, 255/mmPerPixel, 31.83/mmPerPixel, PI); //8
    opc.ledRing(564, 6, width - 75/mmPerPixel, 155/mmPerPixel, 31.83/mmPerPixel, PI); //9
    
    
    opc.connect();
  } catch(Exception e) {
      statusMessage += "Unable to connect to OPC server"; 
  }
  
  
  
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
  
  println("done setting up mode lists");

  changeBrightness(brightness);
  
  // fill colour data
  LEDTable.colours.append(unhex("FF0000AA"));
  LEDTable.colours.append(unhex("FFAA0000"));
  LEDTable.colours.append(unhex("FF00AA00"));
  LEDTable.colours.append(unhex("FFAA22AA"));
  LEDTable.colours.append(unhex("FFCCBBAA"));
  
  // set the startup mode
  changeMode("BUBBLES");
  changeCupMode("SOLIDCOLOURTRANSPARENT");
  println("Default modes set");
  
  println("========= SETUP COMPLETE ========="); 
  println();
}


void draw() {
  // read commands from Arduino, and web app
  checkForCommands();  

  mode.update();
  mode.display();
  cupMode.display();
}


void serialMessage(String serialData)
{
  // each line of data is sent seperately for now. The data type, data pin, and value are seperated by spaces
  // here we separate that info. example: "SERIAL IR 3 ON" means that IR detector #3 is now on sent via serial port
  // format is "SERIAL DATA_TYPE DATA_NUMBER VALUE"
  String[] data = split(serialData, ' ');
  int dataType = 0;
  
  // can't figure out how to use enums, so convert to int for the switch
  // try to fix this in the future
  
  if (data[1].equals("IR")) {
   dataType = 1; 
  } else if (data[1].equals("ANALOG")) {
   dataType = 2; 
  } else if (data[1].equals("BUTTON")) {
   dataType = 3; 
  } else if (data[1].equals("INFO")) {
   dataType = 4; 
  } else if (data[1].equals("BRIGHTNESS")) {
    //debug testing
    //changeBrightness(int(data[2].trim()));
  }

  switch(dataType)
  {
    case 1:
      if (data[3].trim().equals("ON")) {
        LEDTable.irData[int(data[2])] = true;
      } else if (data[3].trim().equals("OFF")) {
        LEDTable.irData[int(data[2])] = false;
      }    
      break;
    case 2:
      analogData[int(data[2])] = int(data[3]);
      break;
    case 3:
      if (data[3].trim().equals("PRESSED")) {
        buttonPressed(int(data[2]));
      } else if (data[3].trim().equals("HELD")) {
        buttonHeld(int(data[2]));
      } 
      break;
    case 4:
      println(serialData);
      break;
    default:
      break;   
  } 
}




void receiveMessage(String message)
{
  print("Received message: " + message);
  
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
  
  
  if (command.equals("BRIGHTNESS") && data.length == 2) {
   changeBrightness( int( trim(data[1]) ) );
   sendMessage("You set the brightness to " + brightness);
   
  } else if ( command.equals("SERIAL") ) {
    serialMessage(message);    
  } else if (command.equals("MODE") && data.length > 1) {
    changeMode(data[1].trim().toUpperCase());
  } else if (message.trim().equals("FIRSTCONNECT")) {
    if (statusMessage.equals("")){
      statusMessage = "No startup errors; "; 
    }
    statusMessage += "brightness: " + brightness + "; mode ";
    sendMessage(statusMessage);
  } else if (command.equals("SHUTDOWN") && data.length == 1) {
    try { shutdownPi(); } catch (Exception e) { println("Error shutting down Pi"); }
  } else if (command.equals("COLOUR") || command.equals("COLOR")) {
    changeColour(int(data[1].trim()), data[2].trim().toUpperCase());
  }

} // end receive message



void sendMessage(String message) {
  // for some reason I can only get the server to send strings
  // so send the length of the message as a string of the first four characters
  
  int messageLength = message.length();
  String messageLengthString = "";
  if (messageLength == 0) {
    return;
  } else if (messageLength < 10) {
    messageLengthString = "000" + str(messageLength);
  } else if (messageLength < 100) {
    messageLengthString = "00" + str(messageLength); 
  } else if (messageLength < 1000) {
    messageLengthString = "0" + str(messageLength); 
  } else if (messageLength < 10000) {
    messageLengthString = str(messageLength); 
  }

  String messageToSend = messageLengthString + message;

  try {
    tcpServer.write(messageToSend);
    println("Sent network message: " + messageToSend);
  } catch (Exception e) {
      println("Failed to send network message: " + messageToSend + e.getMessage());    
  }

  
} // end send message



void changeBrightness(int b) {
  opc.setColorCorrection(2.5, b/100f, b/100f, b/100f);  
  brightness = b;
  println("Color correction: " + opc.colorCorrection);
}





void checkForCommands() {
  // network stuff
  try {
    Client client = tcpServer.available();
    if (client != null) {
      String whatClientSaid = client.readString();
      if(whatClientSaid != null) {
        // receive command from app     
        receiveMessage(whatClientSaid); 
      }
    } 
  } catch(Exception e) {
    println(e.getMessage());
  }
  
  
  if (serialClient.available() > 0 ) {
    String networkSerial = serialClient.readStringUntil('\n');
    if(networkSerial != null) {
      receiveMessage("SERIAL " + networkSerial);
    }
  }
  
} // end checkForCommands





void changeColour(int colourToChange, String c) {
  if (colourToChange > 4 || colourToChange < 0) {
    return;
  }
  c = "FF" + c; // make sure alpha channel is opaque
  LEDTable.colours.set(colourToChange, unhex(c));
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
  println("currentMode:", currentMode);
  switch(currentMode) {
    case 0: // OFF
      mode = new SolidColour(0);
      break;
    case 1: // SOLIDCOLOUR
      mode = new SolidColour();
      break;
    case 2: // RAINBOW
      mode = new Rainbow();
      break;
    case 3:
      mode = new RotatingCube();
      break;
    case 4:
      mode = new SoundBall(sound);
      break;
    case 5:
      // Bubbles(count, size, lifespan);
      mode = new Bubbles(30, 85, 100);
      break;
    case 6:
      mode = new Bubbles(30,85,100, LEDTable.colours.get(0));
      break;
    case 7: // 'stars' using bubbles
      mode = new Bubbles(30, 15, 100);
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
  println("currentCupMode:", currentCupMode);
  cupMode = new CupTransparent();
  switch(currentCupMode) {
    case 0: // No cup rendering
      cupMode = new CupTransparent();
      break;
    case 1: // SOLIDCOLOUR
      cupMode = new CupSolidColour();
      break;
    case 2: // SOLIDCOLOUR TRANSPARENT
      cupMode = new CupSolidColour(true, true);
      break;
    default:
      cupMode = new CupTransparent();
      break;
  }
}



void shutdownPi() throws IOException {
  // turn pixels off
  for (int i = 0; i < opc.pixelLocations.length; i++) {
    opc.setPixel(i, 0);
  }
  opc.writePixels();
  
  // gracefully shutdown the Pi via:
  // http://stackoverflow.com/questions/25637/shutting-down-a-computer
  Runtime.getRuntime().exec("shutdown -h now");
  System.exit(0);  
}