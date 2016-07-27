// based off the sketch from: 
// http://www.openprocessing.org/sketch/101123
// by Joelle Snaith

// also based on minim example from:
// http://code.compartmental.net/minim/fft_method_linaverages.html

import ddf.minim.*;
import ddf.minim.analysis.*;

public class AudioReactor {
  Minim minim;
  AudioInput sound;
  FFT fft;
  
  int sampleRate, bufferSize;
  int minOctaveWidth, bandsPerOctave;
  float fadeVal; // controls how fast to transition to new value
  float gain; // used to scale normalized values
  
  float[] prevData;
  float[] data;
  float[] scaleFactor;
  
  AudioReactor(Minim m) {
    // default constructor, uses 9 buckets
    sampleRate = 44100;
    bufferSize = 512;
    minOctaveWidth = 75; // hertz
    bandsPerOctave = 1;
    fadeVal = 4;
    gain = 1;
    
    minim = m;
    sound = minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
    
    fft = new FFT(bufferSize, sampleRate);
    fft.logAverages(minOctaveWidth, bandsPerOctave);
    fft.window(FFT.HAMMING);
    
    scaleFactor = new float[fft.avgSize()];
    prevData = new float[fft.avgSize()];
    data = new float[fft.avgSize()];
    
    scaleFactor[0] = 82;
    scaleFactor[1] = 63;
    scaleFactor[2] = 45;
    scaleFactor[3] = 24;
    scaleFactor[4] = 12;
    scaleFactor[5] = 8;
    scaleFactor[6] = 6;
    scaleFactor[7] = 3.5;
    scaleFactor[8] = 0.8;
  }
  
  void update() {
    fft.forward(sound.left);
    
    for (int i = 0; i < fft.avgSize(); i++) {
      // use scaleFactor[i] to normalize/map values between 0 and 1
      data[i] = (fft.getAvg(i) / scaleFactor[i]) * gain;
      if (data[i] > 1) {
        data[i] = 1;
      }
      
      // fade the values up or down to make smooth (ish) transitions
      if (data[i] < prevData[i]) {
        data[i] = prevData[i] - ( (prevData[i] - data[i])/fadeVal );
        //data[i] = 0.97 * prevData[i];
      } else if (data[i] > prevData[i]) {
        // fade up twice as fast as fading down
        data[i] = prevData[i] + ( (data[i] - prevData[i])/(fadeVal*2) );
      }
      prevData[i] = data[i];   
    }
    
     
  }
  
  
}