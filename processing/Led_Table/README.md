##Run an exported Processing 3 sketch on a headless Raspberry Pi

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

