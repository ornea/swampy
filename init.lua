--[[

Author: Justin Richards
Date: 28/Oct/2015

Title: Init.lua
--]]


--init.lua
print("Setting up WIFI...")
wifi.setmode(wifi.STATION)
--modify according your wireless router settings

--wifi.sta.connect()
tmr.alarm(1, 1000, 1, function() 
if wifi.sta.getip()== nil then 
     wifi.sta.config("test","test")
     print("IP unavaiable, Waiting...") 
else 
     tmr.stop(1)
     print("Config done, IP is "..wifi.sta.getip())
     dofile("Swampy.lua")
end 
end)
