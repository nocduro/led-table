# LED Beer pong table - Arduino sketch

This sketch reads 20 analog signals from IR detectors, reads potentiometers and buttons which is then sent to a raspberry pi over serial.

* 1 Shift register to control MUX chips
* 1 Bi-directional Level shifter
* 3 MUX chips to read analog IR data, and potentiometers

## Issues:
The current IR detectors used are operating on the extreme end of their detecting range and therefore their signals are a little noisy. I've tried to compensate for this by averaging values and so on, but ideally all of the boards on the table would be replaced with detectors that have an appropriate range (~5mm).

Another bug is when red is displayed on the leds around the detectors, the detectors behave sporadically. I think this is caused by the colour red's wavelength being too close to the detectors wavelength and maybe in part due to the averaging as stated previously.


## License
See LICENSE.md in the root directory of this project. (MIT)
