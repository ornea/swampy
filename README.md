ESP8266 IoT based Swampy Controller
See https://hackaday.io/project/8268-swampy-iot-controller for Hardware

ESP-12 (ESP8266) based  webserver and webclient to control
and monitor Celair Evaporative Airconditioner (aka Swampy) by directly
interfacing to the LEDS and Button contacts on the remote controller.
The remote controller is connect to the main Control Box TEKELEK TEK632 v8
via 4 wires. +5V,+5 Return,Comms,Gnd
webserver provides status of 2 LEDS and control of 2 buttons
webclient regularly sends status via get method to log status
