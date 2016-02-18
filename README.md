# LED Beer Pong Table
A beer pong table with a 15x30 grid of LEDs in the center, with LEDs and ir detectors under each cup. More information on hardware, and progress pictures on http://nocduro.ca/finished-projects

## Description
WS2812b LEDs make up the grid and are controlled by two Fadecandy boards which are connected over USB to a Raspberry Pi 2. The infra red reflective sensors are multiplexed by an Adafruit Pro Trinket (Arduino) which also reads four buttons and a potentiometer. The Trinket sends this data to the Pi over a serial connection through a level shifter. The Raspberry Pi connects to a Wi-Fi network and hosts a small website to expose options to change the table's mode, colours, etc. A microphone is also connected to the Pi through a USB soundcard.


## Technologies Used
* Processing.org - Generates the visuals to be displayed
* Python/Flask - Runs the web interface to send commands to led matrix


Web interface address: http://led-table.local:5000/ on the local network.  
Fadecandy server can be accessed at http://led-table.local:7890/ on the local network.

To access .local addresses from Windows we will also need to install [Bonjour Services](http://support.apple.com/kb/DL999) on the Windows machine.

Note: Now that the website is completed the Windows Phone app will not be maintained.

## License
See LICENSE.md (MIT)
