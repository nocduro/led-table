*This documentation is incomplete...*
# A webapp that controls an LED Beerpong Table

## Description
This webapp provides a UI to control an LED beerpong table from a web browser. The site includes options to change the current mode of the table, colours, microphone gain, etc. When a user makes a change to one of these options the server sends a TCP message to the application responsible for drawing to the LED matrix which then makes the change. In this project that is handled by a Processing sketch which runs 2 Fadecandy boards.

The server is built with Python3 using Flask.
## Installation Instructions
#### Uses the following python modules:

- Flask  

Install Flask with pip on linux with: `sudo pip install flask`  
On windows open a command prompt and type: `pip install flask`  

#### Other useful things to install (optional):
To allow us to connect the the Raspberry Pi using hostname.local we need to install avahi-daemon on the Pi with: `sudo apt-get install avahi-daemon`

To access .local addresses from Windows we will also need to install [Bonjour Services](http://support.apple.com/kb/DL999) on the Windows machine.

## Running the Program
The app can be started by running: `python app.py`  
The app can be stopped by pressing `ctrl-BREAK` / `ctrl-PAUSE`

## License

## References
http://mattrichardson.com/Raspberry-Pi-Flask/

The Raspberry Pi organization has a nice getting started guide for using Flask on the Pi here: https://www.raspberrypi.org/learning/python-web-server-with-flask/

http://blog.miguelgrinberg.com/post/easy-websockets-with-flask-and-gevent  
http://socket.io/get-started/chat/  
http://brennaobrien.com/blog/2014/05/style-input-type-range-in-every-browser.html
