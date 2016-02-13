import processing.net.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import java.net.*;
import java.util.Arrays;

String tableIP = "127.0.0.1";


Server tcpServer; // used to send commands to the sketch remotely
Client serialClient; //used for tcp connection to Arduino serial output
OPC opc; // open pixel control
Mode mode;
StringList modeList;

int drawFrameRate = 60;

// data arrays
int[] analogData = new int[4];

int brightness = 100;
String statusMessage = "";
int currentMode = 1;
/*
0 => off
1 => test mode / startup animation
2 => solid colour
*/

color primaryColour = #000099;
color secondaryColour = #FF0000;

// Audio setup
Minim minim;
AudioInput sound; // microphone
AudioPlayer song; // plays locally stored songs


void setup() {
  println("Starting setup.");
  // Setup mm to pixel multiplier
  float mmPerPixel = 3; // changes how large the processing window will be
  float mmWidthTable = 609.6; // physical width of table
  float mmLengthTable = 2438.4; // physical length of table
  
  // initialize the table with constants used by other classes
  LEDTable.initialize(mmWidthTable, mmLengthTable, drawFrameRate, mmPerPixel);
  size(812, 203, P3D);
  
  // For some reason this code doesn't work on the Pi:
  //surface.setResizable(true);
  //surface.setSize(floor(mmLengthTable/mmPerPixel), floor(mmWidthTable/mmPerPixel)); 
  
  
  // Audio setup
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
  
  // load a local file for testing purposes
  try {
    song = minim.loadFile("HoldOn.mp3", 2048);
  } catch (Exception e) {
      statusMessage+= "Minim error: Unable to load song";
      println("Minim error: " + e.getMessage());
  }
  
  /// NETWORK SETUP
  
  // setup remote control server
  tcpServer = new Server(this, 5204);
  try {
    print("Trying to connect to serial server.....");
    serialClient = new Client(this, tableIP, 12500);
    println("CONNECTED");
  } catch (Exception e) {
      statusMessage += "Unable to connect to serial server"; 
      println("Unable to connect to Serial server: " + e.getMessage());
  }

 
  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
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
  
  
  /// DRAW SETUP
  
  frameRate(drawFrameRate);
  changeBrightness(brightness);
  println("Frame rate set to: " + drawFrameRate);
  
  
  /// MODES SETUP
  modeList = new StringList();
  modeList.append("OFF");
  modeList.append("SOLIDCOLOUR");
  modeList.append("RAINBOW");
  modeList.append("ROTATINGCUBE");
  modeList.append("SOUNDBALL");
  
  // set the startup mode
  changeMode("SOUNDBALL");
  //mode = new SoundBall(sound);

  println("SETUP COMPLETE.");
  println("   _____      __                 ______                      __     __    "); 
  println("  / ___/___  / /___  ______     / ____/___  ____ ___  ____  / /__  / /____ ");
  println("  \\__ \\/ _ \\/ __/ / / / __ \\   / /   / __ \\/ __ `__ \\/ __ \\/ / _ \\/ __/ _ \\");
  println(" ___/ /  __/ /_/ /_/ / /_/ /  / /___/ /_/ / / / / / / /_/ / /  __/ /_/  __/");
  println("/____/\\___/\\__/\\__,_/ .___/   \\____/\\____/_/ /_/ /_/ .___/_/\\___/\\__/\\___/ ");
  println("                   /_/                            /_/                      ");        

}


void draw() {
  checkForCommands();

  mode.update();
  mode.display();
}


void serialMessage(String serialData)
{
  // each line of data is sent seperately for now. The data type, data pin, and value are seperated by spaces
  // here we seperate that info. example: "SERIAL IR 3 ON" means that IR detector #3 is now on sent via serial port
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
    // shutdown the pi gracefully somehow
  } else if (command.equals("COLOUR") || command.equals("COLOR")) {
    changeColour(data[1].trim().toUpperCase(), data[2].trim().toUpperCase());
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







void changeColour(String colourToChange, String c) {
  c = "FF" + c; // make sure alpha channel is opaque
  if (colourToChange.equals("PRIMARY") && c.length() == 8) {
    primaryColour = unhex(c);
    println("Colour changed to: " + c);
    sendMessage("Primary colour changed to: " + c);
  } else if (colourToChange.equals("SECONDARY") && c.length() == 8) {
    secondaryColour = unhex(c);
    println("Colour changed to: " + c);
    sendMessage("Secondary colour changed to: " + c);
  }
}


void buttonPressed(int b) {
  switch (b) {
    case 1:
      changeMode("TOGGLE");
      break;
    case 2:
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

void changeMode(String s)
{  
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
      mode = new SolidColour(primaryColour);
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
    default:
      mode = new SolidColour(0);
      break;
  }
}