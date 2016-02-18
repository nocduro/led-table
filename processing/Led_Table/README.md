# LED Beer pong table - Processing Sketch

A Processing3 sketch is used to control the Fadecandy boards, and in turn display visualizations on the led grid and under the cups. The sketch takes in data from IR detectors, buttons, and a website to control the different modes, brightness, etc.

## Data collection
Data from an Arduino is read in by connecting to a TCP server run by ser2net. Ser2net takes the serial port of the Raspberry Pi and makes it accessible over TCP. This was done so that if a PC other than the Pi is running the Processing sketch, it would still have access to the serial port of the Arduino.

The Processing sketch also runs its own TCP server on port 5204 which clients can connect to in order the change the mode of the table, brightness, etc. Currently this is accomplished with a small website.

## Testing on a PC
I usually test the sketch on another PC to test different animations, and things like the TCP server. To do this we have to run the Fadecandy server locally. The sketch will throw an error saying it can't connect to the TCP server that connects to the Arduino, but this is alright for testing general animations.

## Installing
We will export the sketch to linux-armv6hf from Processing. This can be done in the Processing desktop application by going to File -> Export Application, or what I do: copy the 3 source files (Led_Table.pde, OPC.pde, Modes.pde) to the Pi and then run a script that exports them by using the Processing command line tools.

## Running on the Pi
Follow the steps below which allow us to render stuff to a virtual screen when we don't have a display connected to the Pi:

### Running an exported Processing 3 sketch on a headless Raspberry Pi

Follow directions from processing to run without a display here:

 https://github.com/processing/processing/wiki/Running-without-a-Display

Here are the important things summarized:

`sudo apt-get install xvfb libxrender1 libxtst6 libxi6`

`sudo Xvfb :1 -screen 1920x1080x24`

`export DISPLAY=":1"`

We'll use java jdk-8 on the Pi to run the sketch

Make sure we are using the correct version by running:

`sudo update-alternatives --config java`

Export the Application from Processing if not already done so:
`File -> Export Application`
Check the linux box, then export.
Copy files within the generated application.linux-armv6hf folder to Raspberry Pi (I used ftp)
Make the file executable on the pi by:
`chmod +x [filename]`

Now our Processing sketch that we exported can be run by:
`xinit ./[filename]`

Source for last part: https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=86352
