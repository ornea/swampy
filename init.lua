--[[

Author: Justin Richards
Date: 28/Oct/2015

Title: Init.lua
--]]

--init.lua
print("Setting up WIFI...")
wifi.setmode(wifi.STATION)
cfg =
  {
    ip="192.168.1.51",
    netmask="255.255.255.0",
    gateway="192.168.1.254"
  }
  wifi.sta.setip(cfg)

--modify according your wireless router settings

--wifi.sta.connect()
tmr.alarm(1, 1000, 1, function() 
  wifi.sta.config("SSID","password",0)
if wifi.sta.getip()== nil then 
   
     print("IP unavaiable, Waiting...") 
else 
     tmr.stop(1)
     print("Config done, IP is "..wifi.sta.getip())
     dofile("Swampy.lua")
end 
end)
--print(wifi.sta.getmac())
--wifi.sta.connect()
