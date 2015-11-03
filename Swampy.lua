--[[

Author: Justin Richards
Date: 28/Oct/2015

Title: Swampy Controller v0.1

Description: Runs as webserver and webclient to control
and monitor Celair Evaporative Airconditioner (aka Swampy) by directly
interfacing to the LEDS and Button contacts on the remote controller.
The remote controller is connect to the main Control Box TEKELEK TEK632 v8
via 4 wires. +5V,+5 Return,Comms,Gnd
webserver provides status of 2 LEDS and control of 2 buttons
webclient regularly sends status via get method to log status

Runs on a $4 ESP8266MOD AI-Thinker attached to IO breakout carrier board
Initial Boot Normal Mode connected at 9600 outputs 
>>[Vendor:www.ai-thinker.com Version:0.9.2.4]
>>
>>ready
Initial Boot in Flashing Mode connected at 74880 outputs
>> ets Jan  8 2013,rst cause:1, boot mode:(1,4)

ReFlashed with NODEMCU FIRMWARE PROGRAMMER with these settings
Config 
     - INTERNAL://NODEMCU  0x00000
     - INTERNAL://BLANK    0x7E000
     - INTERNAL://DEFAULT  0x7C000
 Advanced
     -Baudrate 9600
     -Flash Size 4MByte
     -Flash speed 40MHz   
     -SPI Mode DIO
Launched via ESP8266Flasher.exe on WinXP

After Flashing, Boot in Normal Mode Connected at 9600 outputs
>>Restore init data.
>>
>>NodeMCU 0.9.5 build 20150318  powered by Lua 5.1.4
>>lua: cannot open init.lua

These scripts init.lua and Swampy.lua are then uploaded to the
ESP8266 using java based ESPlorer v0.1 build 206 by 4refr0nt
using the "Save to ESP" button.  Then the ESP is reset which 
begins running init.lua

Launched via ESPlorer.jar on WinXP

IO index     ESP8266 pin
0 [*]     GPIO16
1    GPIO5  swFAN Output
2    GPIO4  swCOOL Output
3    GPIO0  
4    GPIO2  
5    GPIO14 ledFAN Input
6    GPIO12 ledCOOL Input
7    GPIO13
8    GPIO15
9    GPIO3
10   GPIO1
11   GPIO9
12   GPIO10

Normal Mode (script runs and can be updated with Esplorer)
Float GPIO2
Float GPIO0
On Carrier IO breakout
CH-PD -> 10K -> Vcc
GPIO15 -> 10 -> Gnd

Flashing Mode (NODEMCU FIRMWARE PROGRAMMMER) 
GPIO2 -> 3.3
GPIO0 -> GND
--]]

swFAN = 1
swCOOL = 2
ledFAN = 5
ledCOOL = 6

gpio.write(swFAN, gpio.HIGH)
gpio.write(swCOOL, gpio.HIGH)

gpio.mode(swFAN, gpio.OUTPUT)
gpio.mode(swCOOL, gpio.OUTPUT)
gpio.mode(ledFAN, gpio.INPUT)
gpio.mode(ledCOOL, gpio.INPUT)

print ("FAN:" .. gpio.read(ledFAN))
print ("COOL:" .. gpio.read(ledCOOL))
print(wifi.sta.getip())

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<title>Swampy</title><h1> Justin's ESP8266 Swampy Controller </h1>";
                 
        if (gpio.read(ledFAN)==0) then
                 buf = buf.."<p>GPI14 FAN LED is ON   ->  <a href=\"?pin=toggleFAN\"><button> Press for FAN mode OFF </button></a></p>";
        else
                 buf = buf.."<p>GPI14 FAN LED is OFF  ->  <a href=\"?pin=toggleFAN\"><button> Press for FAN mode ON  </button></a></p>";
        end
        if (gpio.read(ledCOOL)==0) then
                 buf = buf.."<p>GPI12 COOL LED is ON  ->  <a href=\"?pin=toggleCOOL\"><button>Press for COOL mode OFF</button></a></p>";
        else
                 buf = buf.."<p>GPI12 COOL LED is OFF ->  <a href=\"?pin=toggleCOOL\"><button>Press for COOL mode ON </button></a></p>";
        end
        --y = -4E-05x2 + 0.1079x - 4.9662
        -- Function produced from excel trendline polynomial formula. Data obtained by attaching
        -- thermistor to thermocouple. ADC/thermistor plotted against thermocouple readings
        -- auto logged values as temperature was slowly varied from 70deg to 16 deg
        -- this version of nodemcu only supports integer math so calcs below approximate
        -- Used TL431 to provide vRef of 2.5v across 10k thermistor in series with 1k5 res
        -- ADC value read using python script response = urllib2.urlopen('http://172.16.1.242/?pin=ADC')
        x = adc.read(0)
        a = x * x
        a = x / -25000
        b = x / 9
        c = 7
        y = a + b 
        y = y - c
        a = nil
        b = nil
        c = nil
   
        buf = buf .. "<p>ADC is ->  " .. x .. " Deg C is -> " .. y .. " <a href=\"?pin=ADC\"><button>ADC </button></a></p>"
        y = nil
        x = nil
          --adc.read(0)
        local _on,_off = "",""
        if(_GET.pin == "toggleFAN")then
              gpio.write(swFAN, gpio.LOW);
              tmr.delay(100000) --100000 us to counter the switch debounce circuit 10000us for debug
              gpio.write(swFAN, gpio.HIGH);
              print ("GPIO5 swFAN pulsed LOW");
               buf = buf..[[<meta http-equiv="refresh" content="0; url=http://192.168.1.51/" />]]
        elseif(_GET.pin == "toggleCOOL")then
              gpio.write(swCOOL, gpio.LOW);
              tmr.delay(100000) --100000 us to counter the switch debounce circuit 10000us for debug
              gpio.write(swCOOL, gpio.HIGH);
              print ("GPIO4 swCOOL pulsed LOW");
               buf = buf..[[<meta http-equiv="refresh" content="0; url=http://192.168.1.51/" />]]
        elseif(_GET.pin == "ADC")then
               buf = adc.read(0)
              print ("ADC Request");
               --buf = buf..[[<meta http-equiv="refresh" content="0; url=http://172.16.1.242/" />]]
        
        end
        print ("Web Server Accessed");
       
        print(wifi.sta.getip());
        client:send(buf);
        client:close();
       -- collectgarbage();
    end)
end)


tmr.alarm(0,30000, 1, function() 
     
    conn=net.createConnection(net.TCP,0)
		conn:on("receive",function(conn,payload) 
			print("payload: ") 
			print(payload) 
			print("end Payload")
			conn:close() end)
  
		conn:connect(80,"192.168.1.215")
			print("FAN: " .. gpio.read(ledFAN))
			print("COOL: " .. gpio.read(ledCOOL))
			print(wifi.sta.getip())

		conn:send("GET /cgi-bin/logesp.pl?FAN=" .. gpio.read(ledFAN) ..
			"&COOL=" .. gpio.read(ledCOOL) .. 
			"&tmr_now=" .. tmr.now()/1000000 .. 
			"&MEM=" .. node.heap() ..
			"&ADC=" .. adc.read(0) .. 
			" HTTP/1.1\r\nHost: 192.168.1.215\r\n Connection: keep-alive\r\nAccept: */*\r\n\r\n")
--		conn:close()	
	print("MEM: "..node.heap())
    --collectgarbage();
end)
