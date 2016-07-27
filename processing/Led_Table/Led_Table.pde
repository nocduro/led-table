import processing.net.*;
import ddf.minim.*;
import java.net.*;
import java.util.Arrays;

/** Constants **/
final String tableIP = "127.0.0.1";
//final String tableIP = "192.168.0.225";
final int CONTROL_PORT = 5204; // port that web app uses to connect
final int drawFrameRate = 60;
final float tableWidth = 609.6; // physical width of table in mm
final float tableLength = 2438.4; // physical length of table in mm
final float mmPerPixel = 3; // scaling factor for Processing window size

/** Network **/
Server tcpServer; // used to send commands to the sketch remotely
Client serialClient; // used to connect to ser2net that hosts Arduino serial port
OPC opc; // open pixel control


/** Initialize variables **/
String statusMessage = "";


/** Audio **/
Minim minim;

LEDTable table;
MatrixText text;

void settings() {
  // setup window size depending on scaling factor mmPerPixel (how many
  // millimetres a single pixel represents)
  size(floor(tableLength/mmPerPixel), floor(tableWidth/mmPerPixel), P3D);
}

void setup() {
  println("Starting setup. V0.0.1a");
  table = new LEDTable(tableWidth, tableLength, drawFrameRate, mmPerPixel);
  //size(812, 203, P3D);
  frameRate(drawFrameRate);
  println("Frame rate set to: " + drawFrameRate);
  
  text = new MatrixText(table);
  minim = new Minim(this);
  table.audio = new AudioReactor(minim);
  
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
 
  // Connect to the OPC server (FadeCandy)
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
  
  // get the x and y coordinates of the main grid
  // used for drawing text to the grid
  table.topLeftGridY = floor(opc.pixelLocations[14] / width);
  table.topLeftGridX = opc.pixelLocations[14] - (table.topLeftGridY * width);
  
  // set the startup mode
  table.changeMode("SOUNDBALL");
  table.changeCupMode("SOLIDCOLOURTRANSPARENT");
  
  println("========= SETUP COMPLETE ========="); 
  println();
  
  startupAnimation();
  
}


void draw() {
  // read commands from Arduino, and web app
  checkForCommands();  

  table.mode.update();
  table.mode.display();
  table.cupMode.display();  
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
        table.irData[int(data[2])] = true;
      } else if (data[3].trim().equals("OFF")) {
        table.irData[int(data[2])] = false;
      }    
      break;
    case 2:
      table.analogData[int(data[2])] = int(data[3]);
      break;
    case 3:
      if (data[3].trim().equals("PRESSED")) {
        table.buttonPressed(int(data[2]));
      } else if (data[3].trim().equals("HELD")) {
        table.buttonHeld(int(data[2]));
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
   table.changeBrightness(opc, int( trim(data[1]) ) );
   sendMessage("You set the brightness to " + table.brightness);
   
  } else if ( command.equals("SERIAL") ) {
    serialMessage(message);    
  } else if (command.equals("MODE") && data.length > 1) {
    table.changeMode(data[1].trim().toUpperCase());
  } else if (message.trim().equals("FIRSTCONNECT")) {
    if (statusMessage.equals("")){
      statusMessage = "No startup errors; "; 
    }
    statusMessage += "brightness: " + table.brightness + "; mode ";
    sendMessage(statusMessage);
  } else if (command.equals("SHUTDOWN") && data.length == 1) {
    try { shutdownPi(); } catch (Exception e) { println("Error shutting down Pi"); }
  } else if (command.equals("COLOUR") || command.equals("COLOR")) {
    table.changeColour(int(data[1].trim()), data[2].trim().toUpperCase());
  } else if (command.equals("GAIN") ) {
    table.audio.gain = float(data[1].trim());
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


void startupAnimation() {
  
  
  
}