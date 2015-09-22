/****************************************************
This sketch reads 20 analog signals from IR
detectors, reads potentiometers and buttons which 
is then sent to a raspberry pi over serial

1 Shift register to control MUX chips
1 Level shifter
3 MUX chips to read analog IR data, and pots


Written by: Mackenzie Hauck
http://nocduro.ca
Summer 2015
*****************************************************/


// Shift register info from: http://www.arduino.cc/en/Tutorial/ShftOut21
// The shift register controls the select lines on the 3 mux chips
//Pin connected to ST_CP (12) of 74HC595 
int latchPin = 10;
//Pin connected to SH_CP (11) of 74HC595
int clockPin = 12;
//Pin connected to DS (14) of 74HC595
int dataPin = 11;


// Mux pins
int mux1 = 0;
int mux2 = 1;
int mux3 = 2;
int s0mux3 = 5; // we need 9 lines to control 3 mux's so we use 8 from the shift reg and 1 digital out

// Controls which pins of the shift register are high to select the input on the mux's. First read the 1st input 
// of each mux and work up to the last input of each mux
int mux[8] = {B00000000, B00100100, B01001001, B01101101, B10010010, B10110110, B11011011, B11111111};
                

int muxData[24];
int prevMuxData[24];
boolean triggeredMux[20];
int ambientLevel[20];
int calibrationBuffer = 17;


// buttons
int buttonData[3] = {0,0,0};
int prevButtonData[3] = {HIGH,HIGH,HIGH};
long buttonTimer[3] = {0,0,0};
int buttonPins[3] = {8,6,4}; // pins the buttons are wired to
int buttonHeldTime = 1500;  // in ms, used to see if button was held down

boolean knobChanged = false;
int prevKnob = 0;
int knobBuffer = 3;
long knobTime;


void setup() {
  Serial.begin(9600);
  Serial.println("INFO Arduino serial started");
  // Shift register
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  
  //MUX
  //pinMode(mux1, INPUT);
  //pinMode(mux2, INPUT);
  //pinMode(mux3, INPUT);
  pinMode(s0mux3, OUTPUT);
  

  // setup buttons
  for (byte i = 0; i < 3; i++){
    pinMode(buttonPins[i], INPUT_PULLUP);
  }

  delay(250);
  calibrateSensors();
  
 
  
  
}

void loop() {
  checkButtons();  
  
  
  // scan analog inputs and read values
  for (int i=0; i<8; i++){
   prevMuxData[i] = muxData[i]; 
   prevMuxData[i+8] = muxData[i+8];  
   prevMuxData[i+16] = muxData[i+16];   
    
   selectPin(i); // use shift register to control mux 
   delay(10); // after switching pins let the RC filter equalize. lower this?
   // read all 3 mux at the same time
   muxData[i] = analogRead(mux1);  
   muxData[i+8] = analogRead(mux2);
   muxData[i+16] = analogRead(mux3);
  }
  


  
  // send out IR data if it is triggered
  for (int i = 0; i < 20; i++)
  {
    if (!triggeredMux[i] && muxData[i] + calibrationBuffer < ambientLevel[i] && prevMuxData[i] + calibrationBuffer < ambientLevel[i])
    { // when input is within trigger range and this is the first time it was triggered, send the data
      triggeredMux[i] = !triggeredMux[i];
      Serial.print("IR ");
      Serial.print(i);
      Serial.println(" ON");
    }else if (triggeredMux[i] && muxData[i] + calibrationBuffer > ambientLevel[i] && prevMuxData[i] + calibrationBuffer > ambientLevel[i])
    {// when input is outside trigger range and this is the first time it was not triggered, send the data
      triggeredMux[i] = !triggeredMux[i];
      Serial.print("IR ");
      Serial.print(i);
      Serial.println(" OFF");      
    }
  }
  
  // check knob
  if ((muxData[20] > prevKnob + knobBuffer || muxData[20] < prevKnob - knobBuffer) && !knobChanged)
  {
    knobChanged = true;
  } else if (knobChanged)
  {
    if (knobTime == 0){
      knobTime = millis();
    }
    
    // when value is stable for 2 seconds send it out
    if ( (muxData[20] >= prevKnob - 1 && muxData[20] <= prevKnob + 1) && millis() - knobTime > 250)
    {    
      int knobBrightness = map(muxData[20], 0, 1023, 0, 100);
      Serial.print("BRIGHTNESS ");
      Serial.println(knobBrightness);
      knobChanged = false;
      knobTime = 0;
    }
    
    
    prevKnob = muxData[20];
  }
  
  
  

  

} // end of main loop


// Used to select the mux lines
void selectPin(int input){
 // send to shift register
 digitalWrite(latchPin, LOW);
 shiftOut(dataPin, clockPin, LSBFIRST, mux[input]);
 digitalWrite(latchPin, HIGH);
 
 if (input%2 == 0){
    digitalWrite(s0mux3, LOW); //when input is even set last control line to LOW
   }else{
     digitalWrite(s0mux3, HIGH);
   }
}



void calibrateSensors()
{
  Serial.println("INFO Calibrating sensors");
  /*
  for (int i = 0; i < 20; ++i)
  {
   selectPin(i); // use shift register to control mux 
   delay(10);
   ambientLevel[i] = analogRead(mux1);
   ambientLevel[i+8] = analogRead(mux2);
   if ( (i+8) <= 20)
   {
     ambientLevel[i+16] = analogRead(mux3);
   }   
   delay(10);
  } */
  
  
  averageSensors();
  
  Serial.println("INFO Calibration complete");
  // debug stuff
  /*
  for (int i = 0; i < 20; i++){
   Serial.print("Ambient ");
   Serial.print(i);
   Serial.print(": ");
   Serial.println(ambientLevel[i]); 
  } */
  delay(200);  
}

void averageSensors()
{
  for (byte i = 0; i < 20; i++)
  {
    ambientLevel[i] = 1023;    
  }
  int timesToAverage = 10;
  for (byte i = 0; i < timesToAverage; i++)
  {
    for (int i = 0; i < 8; ++i)
    {
     selectPin(i); // use shift register to control mux 
     delay(40);
     ambientLevel[i] += analogRead(mux1);
     ambientLevel[i+8] += analogRead(mux2);
     if ( (i+8) <= 20)
     {
       ambientLevel[i+16] += analogRead(mux3);
     }   
    }
  }
  for (byte i = 0; i < 20; i++){
    ambientLevel[i] = ambientLevel[i] / (timesToAverage + 1);
  }
}


void checkButtons()
{
  for(byte i = 0; i < 3; ++i)
  {
    buttonData[i] = digitalRead(buttonPins[i]);
    
    if (buttonData[i] == LOW && prevButtonData[i] == HIGH){ // button just pressed
      buttonTimer[i] = millis();     
    } else if (buttonData[i] == LOW && prevButtonData[i] == LOW && millis() - buttonTimer[i] >= buttonHeldTime && buttonTimer[i] != 0){ // button held down
      buttonHold(i);
      buttonTimer[i] = 0;
      
    } else if (buttonData[i] == HIGH && prevButtonData[i] == LOW && millis() - buttonTimer[i] < buttonHeldTime && (millis() - buttonTimer[i]) > 10){ // button tapped
      buttonPressed(i);
      buttonTimer[i] = 0;
    }    
    prevButtonData[i] = buttonData[i];
  }
}



void buttonHold(byte button){
 // code for what to do when a button is held down. 
 Serial.print("BUTTON ");
 Serial.print(button + 1); // which button was pressed (1,2,3)
 Serial.println(" HELD");
}

void buttonPressed(byte button){
 // code for when a button is just pressed momentarily 
 Serial.print("BUTTON ");
 Serial.print(button + 1); // which button was pressed (1,2,3)
 Serial.println(" PRESSED");
}
