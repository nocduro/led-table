import processing.serial.*;
import processing.net.*;

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

void setup()
{
  // Setup mm to pixel multiplier
  float mmPerPixel = 2.5;
  float mmWidthTable = 609.6;
  float mmLengthTable = 2438.4;
  
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
    opc.ledGridRotated(0, 15, 30, height/2.0, width/2.0, 33/mmPerPixel, 33/mmPerPixel, 0.0, true);
    // Draw left 10 cup arrangement
    opc.ledRing(450, 6, 75/mmPerPixel, 155/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(456, 6, 75/mmPerPixel, 255/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(462, 6, 75/mmPerPixel, 355/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(468, 6, 75/mmPerPixel, 455/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(474, 6, 162/mmPerPixel, 205/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(480, 6, 162/mmPerPixel, 305/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(486, 6, 162/mmPerPixel, 405/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(492, 6, 248/mmPerPixel, 255/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(498, 6, 248/mmPerPixel, 355/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(504, 6, 335/mmPerPixel, 305/mmPerPixel, 31.83/mmPerPixel, PI);
    // Draw the right 10 cup arrangement
    opc.ledRing(510, 6, width - 75/mmPerPixel, 155/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(516, 6, width - 75/mmPerPixel, 255/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(522, 6, width - 75/mmPerPixel, 355/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(528, 6, width - 75/mmPerPixel, 455/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(534, 6, width - 162/mmPerPixel, 205/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(540, 6, width - 162/mmPerPixel, 305/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(546, 6, width - 162/mmPerPixel, 405/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(552, 6, width - 248/mmPerPixel, 255/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(558, 6, width - 248/mmPerPixel, 355/mmPerPixel, 31.83/mmPerPixel, PI);
    opc.ledRing(564, 6, width - 335/mmPerPixel, 305/mmPerPixel, 31.83/mmPerPixel, PI);
  }
  catch(Exception e){
    statusMessage += "Unable to connect to OPC server"; 
  }
  

}

void draw()
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
  float dotSize = height * 0.6 * (1.0 + 0.2 * sin(millis() * 0.01));
  
  // Draw it centered at the mouse location
  image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
} // end of draw()


void serialEvent(Serial p)
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
        irData[int(data[1])] = true;
      } else if (data[2] == "OFF"){
        irData[int(data[1])] = false;
      }    
      break;
    case 2:
      analogData[int(data[1])] = int(data[2]);
      break;
    case 3:
      if (data[2] == "ON"){
        buttonData[int(data[1])] = true;
      } else if (data[2] == "OFF"){
        buttonData[int(data[1])] = false;
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

void receiveMessage(String message)
{
  println("tcpServer message: " + message);
  
  // debug stuff
  String reply = "I received this message: " + message;
  //sendMessage(reply);
  
  String[] data = split(message, ' ');
  
  if (data[0].equals("brightness") && data.length == 2){
   changeBrightness(int(trim(data[1])) );
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


void sendMessage(String message)
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

void changeBrightness(int b)
{
  opc.setColorCorrection(2.5, b/100, b/100, b/100);  
  brightness = b;
}

void calibrateSensors()
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


void changeMode(String mode)
{
  println("Mode tried to change to: " + mode);
  
}
