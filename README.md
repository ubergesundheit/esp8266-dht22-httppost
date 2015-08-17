# ESP8266 with DHT22

## Setup

You need an ESP8266 with [nodemcu firmware](https://github.com/nodemcu/nodemcu-firmware) >= 0.9.6 . For programming your ESP8266 you need either an Arduino, RaspberryPi or other USB-to-serial adapter.

I'm using [luatool](https://github.com/4refr0nt/luatool) to program the LUA scripts onto the ESP8266 memory. Baud rate is 9600. You can debug using minicom with `sudo minicom -b 9600 -o -D /dev/ttyACM0`

## Connection Diagram

Connect the ESP8266 with the DHT11.

Connect the Arduino to the ESP8266 for programming the device. The Arduino can be removed after programming the device and if you are using an external power supply or battery.

ESP8266 PIN | device
----------- | -------
GND         | GND
GPIO2       | -
GPIO0       | DHT22 data (2nd from left) & 3.3V VCC w/ 10kΩ resistor
URXD        | Arduino 0 (RX), for programming
UTXD        | Arduino 1 (TX), for programming
CH_PD       | 3.3V VCC
RST         | -
VCC         | 3.3V VCC

See also at [Adafruit: "Connecting to a DHTxx Sensor"](https://learn.adafruit.com/dht/connecting-to-a-dhtxx-sensor)

![Circuit](circuit.png)
Fritzing Parts: [DHT11](https://github.com/adafruit/Fritzing-Library/blob/master/parts/DHT11%20Humitidy%20and%20Temperature%20Sensor.fzpz), [ESP8266](https://github.com/ydonnelly/ESP8266_fritzing)

## The script

Since the newer versions of nodemcu support DHT sensors natively, the code is very trivial. The rest of the code is taken from chk1. See the [README](https://github.com/chk1/esp8266-dht11-opensensemap/blob/master/README.md) of the base fork for more information.

Configure your wifi SSID and password in `init.lua`.

Save both `init.lua` & `dht11.lua` on your device, then restart it.
