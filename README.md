# DEPRECATED. USE https://github.com/ubergesundheit/esp8266-temploggers




# ESP8266 with DHT22

## Setup

You need an ESP8266 with [nodemcu firmware](https://github.com/nodemcu/nodemcu-firmware) like described below. For programming your ESP8266 you need either an Arduino, RaspberryPi or other USB-to-serial adapter.

```
NodeMCU custom build by frightanic.com
        branch: dev
        commit: 09269a64526b42963ad64cb62e332b1d1fd9eb1d
        SSL: true
        modules: cjson,crypto,dht,file,http,net,node,rtctime,sntp,tmr,wifi
 build  built on: 2016-03-17 16:47
 powered by Lua 5.1.4 on SDK 1.5.1(e67da894)
```


## Connection Diagram

Connect the ESP8266 with the DHT22.

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

Data will be transferred as signed Json Web Token with HS256 algorithm.

Since the newer versions of nodemcu support DHT sensors natively, the code is very trivial. The rest of the code is taken from chk1. See the [README](https://github.com/chk1/esp8266-dht11-opensensemap/blob/master/README.md) of the base fork for more information.

Configuration goes in `init.lua`.

Save both `init.lua` & `util.lua` on your device, then restart it.

You can use docker-compose like so: (don't forget do modify the docker-compose.yml)
```
docker-compose run --rm nodemcutool upload --optimize --compile utils.lua
docker-compose run --rm nodemcutool upload --optimize  init.lua
docker-compose run --rm nodemcutool
```
