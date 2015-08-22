-- init.lua
print("Setting up WIFI...")
wifi.setmode(wifi.STATION)
--modify according your wireless router settings
wifi.sta.config("wifi ssid", "wifi password")
wifi.sta.connect()
tmr.alarm(3, 1000, 1, function()
  if wifi.sta.getip()== nil then
    print("IP unavaiable, Waiting...")
  else
    tmr.stop(1)

    TIME=loadfile("ntp.lua")()
    TIME:run(1,1,3600)

    print("Config done, IP is "..wifi.sta.getip())
    dofile("post_dht.lua")
  end
end)
