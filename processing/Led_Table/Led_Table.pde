import processing.serial.*;
import processing.net.*;
import ddf.minim.analysis.*;
import ddf.minim.*;


String tableIP = "192.168.0.166";

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
byte mode = 4;
/*
0 => off
1 => test mode / startup animation
2 => solid colour
*/

color primaryColour = #000099;
color secondaryColour = #FF0000;

// fft
Minim minim;
AudioInput sound;
FFT fft;
float logMultiplier;
FloatList findMax = new FloatList();


void setup()
{
  // Setup mm to pixel multiplier
  float mmPerPixel = 1.5;
  float mmWidthTable = 609.6;
  float mmLengthTable = 2438.4;
  
  size(floor(mmLengthTable/mmPerPixel), floor(mmWidthTable/mmPerPixel), P3D);
  
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
    serialClient = new Client(this, tableIP, 12500);
    println("Connected to serial server");
  }
  catch(Exception e) {
    statusMessage += "Unable to connect to serial server"; 
    println("Can't connect to serial server");
  }
  println("TCPServer started");
  
 
  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  try
  {
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
  }
  catch(Exception e){
    statusMessage += "Unable to connect to OPC server"; 
  }

  frameRate(drawFrameRate);
  println("Frame rate set to: " + drawFrameRate);
  println("Color correction: " + opc.colorCorrection);
  
  fftUpdate();
}


void draw()
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


void modeChange(String m)
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




void serialEvent(Serial p)
{
  String serialInputData = p.readString();
  //println(serialInputData);
  
  
} // end serial event


void serialMessage(String serialData)
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
    changeBrightness(int(data[2].trim()));
  }

  switch(dataType)
  {
    case 1:
      if (data[3].trim().equals("ON")){
        modes.irData[int(data[2])] = true;
      } else if (data[3].trim().equals("OFF")){
        modes.irData[int(data[2])] = false;
      }    
      break;
    case 2:
      analogData[int(data[2])] = int(data[3]);
      break;
    case 3:
      if (data[3].trim().equals("PRESSED")){
        buttonPressed(int(data[2]));
      } else if (data[3].trim().equals("HELD")){
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
  
  
  if (command.equals("BRIGHTNESS") && data.length == 2){
   changeBrightness(int(trim(data[1])) );
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
  opc.setColorCorrection(2.5, b/100f, b/100f, b/100f);  
  brightness = b;
  println("Color correction: " + opc.colorCorrection);
}



void calibrateSensors()
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



void checkForCommands()
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







void changeColour(String colourToChange, String c)
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


void buttonPressed(int b)
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


void buttonHeld(int b)
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



void fftUpdate()
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
        if (findMax.get(k) > 0.6 * maxVal)// this only averages the values that are at least XX% of the max value which makes the higher frequenceis more responsive
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

