import processing.net.*;

final int PORT = 12500;
final float mmPerPixel = 3;
final float tableLength = 2438.4;
final float tableWidth = 609.6;
final int cupDiameter = ceil(75/mmPerPixel);

boolean[] irData = new boolean[20];
float[] cupX = new float[20];
float[] cupY = new float[20];
float[] buttonX = new float[3];
int buttonY;

Server server;
Client currClient;

void settings() {
  size(floor(tableLength/mmPerPixel), floor(tableWidth/mmPerPixel));
}


void setup() {
  
  try {
    server = new Server(this, PORT);
  } catch(Exception e) {
    println("Unable to create server on port", PORT);
  }
  background(180);
  textSize(24);
  fill(255,0,0);
  text("Cup Simulator - Server", 10, 30);
  
  buttonY = height - 30;
  
  // draw all cups off
  generateCupCoordinates();
  fill(80);
  for (int i=0; i<20; i++) {
    irData[i] = false;
    ellipse(cupX[i], cupY[i], cupDiameter, cupDiameter);
  }
  buttonX[0] = width/2 - 2*cupDiameter;
  buttonX[1] = width/2;
  buttonX[2] = width/2 + 2*cupDiameter;
  for (int i = 0; i < 3; i++) {
    ellipse(buttonX[i], buttonY, cupDiameter, cupDiameter);
  }
  
}


void draw() {
  checkForMessage();
  
}


void checkForMessage() {
  if (currClient == null || !currClient.active()) {
    currClient = server.available();
  }
  
  if (currClient == null) { return; }
  
  if (currClient.available() > 0) {
    String message = currClient.readString();
    if (message != null) {
      receiveMessage(message);
    }
  }
}

void receiveMessage(String s) {
  println(s);
}

void mousePressed() {
  int x = mouseX;
  int y = mouseY;
  
  // check if mouse was pressed within a circle by computing
  // the euclidean distance and comparing to circle diameter
  for (int i = 0; i < 20; i++) {
    float dist = sqrt( sq(cupX[i]-x) + sq(cupY[i]-y) );
    if (dist < cupDiameter/2) {
      irData[i] = !irData[i];
      if (irData[i]) {
        // on
        fill(0, 50, 180);
        //println("IR", i, "ON");
        sendMessage("IR " +i+ " ON\n");
      } else {
        // off
        fill(80);
        //println("IR", i, "OFF");
        sendMessage("IR " +i+ " OFF\n");
      }
      ellipse(cupX[i], cupY[i], cupDiameter, cupDiameter);
      return;
    }
  }
  
  for (int i=0; i<3; i++) {
    float dist = sqrt( sq(buttonX[i]-x) + sq(buttonY-y) );
    if (dist < cupDiameter/2) {
      sendMessage("BUTTON " + (i+1) + " PRESSED\n");
    }
  }
  
}

void sendMessage(String message) {
  //println("Sending:", message);
  server.write(message);

}


void generateCupCoordinates() {
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
  
  cupX[10] = width - 335/mmPerPixel;
  cupY[10] = 305/mmPerPixel;
  cupX[11] = width - 248/mmPerPixel;
  cupY[11] = 355/mmPerPixel;
  cupX[12] = width - 248/mmPerPixel;
  cupY[12] = 255/mmPerPixel;
  cupX[13] = width - 162/mmPerPixel;
  cupY[13] = 405/mmPerPixel;
  cupX[14] = width - 162/mmPerPixel;
  cupY[14] = 305/mmPerPixel;
  cupX[15] = width - 162/mmPerPixel;
  cupY[15] = 205/mmPerPixel;
  cupX[16] = width - 75/mmPerPixel;
  cupY[16] = 455/mmPerPixel;
  cupX[17] = width - 75/mmPerPixel;
  cupY[17] = 355/mmPerPixel;
  cupX[18] = width - 75/mmPerPixel;
  cupY[18] = 255/mmPerPixel;
  cupX[19] = width - 75/mmPerPixel;
  cupY[19] = 155/mmPerPixel;
}