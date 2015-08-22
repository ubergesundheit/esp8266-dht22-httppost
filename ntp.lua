-- ntp.lua adapted from github.com/annejan/nodemcu-lua-watch
-- -----------------------------------------------------------------------------------
-- for a continuous run:
-- TIME=loadfile("ntp.lua")()
-- TIME:run(1,1,3600)
-- print(TIME:get_iso_stamp())
-- TIME:run(timer,updateinterval,syncinterval,[ntp-server])
-- TIME.hour TIME.minute TIME.second are updated every 'updateinterval'-seconds
-- NTP-server is queried every 'syncinterval'-seconds
--
-- a one-time run:
-- loadfile("ntp.lua")():sync(function(T) print(T:show_time()) end)
--
-- config:
-- choose a timer for udptimer
-- choose a timeout for udptimeout
--    timer-function to close connection is needed - memory leaks on unanswered sends :(
-- set tz according to your timezone
-- choose a NTP-server near you and don't stress them with a low syncinterval :)
-- -----------------------------------------------------------------------------------

return({
  hour=0,
  minute=0,
  second=0,
  year=1969,
  month=1,
  day=0,
  lastsync=0,
  ustamp=0,
  tz=0,
  udptimer=2,
  udptimeout=1000,
  ntpserver="192.53.103.108",
  sk=nil,
  sync=function(self,callback)
    -- request string blindly taken from http://arduino.cc/en/Tutorial/UdpNTPClient ;)
    local request=string.char(227,0,6,236,0,0,0,0,0,0,0,0,49,78,49,52,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    self.sk=net.createConnection(net.UDP, 0)
    self.sk:on("receive",function(sck,payload)
      sck:close()
      self.lastsync=self:calc_stamp(payload:sub(41,44))
      self:set_time()
      if callback and type(callback) == "function" then
        callback(self)
      end
      collectgarbage() collectgarbage()
    end)
    self.sk:connect(123,self.ntpserver)
    tmr.alarm(self.udptimer,self.udptimeout,0,function() self.sk:close() end)
    self.sk:send(request)
  end,
  calc_stamp=function(self,bytes)
    local highw,loww,ntpstamp
    highw = bytes:byte(1) * 256 + bytes:byte(2)
    loww = bytes:byte(3) * 256 + bytes:byte(4)
    ntpstamp=( highw * 65536 + loww ) + ( self.tz * 3600)  -- NTP-stamp, seconds since 1.1.1900
    self.ustamp=ntpstamp - 1104494400 - 1104494400 -- UNIX-timestamp, seconds since 1.1.1970
    return(self.ustamp)
  end,
  year_to_days=function(self,y)
    return ((y)*365 + (y)/4 - (y)/100 + (y)/400)
  end,
  set_time=function(self)
    -- adapted from http://stackoverflow.com/questions/1274964/how-to-decompose-unix-time-in-c
    local stamp
    stamp = self.ustamp

    self.month = 1
    self.year = 1969

    self.second = stamp % 60
    stamp = stamp / 60

    self.minute = stamp % 60
    stamp = stamp / 60

    self.hour = stamp % 24
    stamp = stamp / 24

    stamp = stamp + 719499

    -- while stamp > ((self.year + 1)*365 + (self.year + 1)/4 - (self.year + 1)/100 + (self.year + 1)/400) + 30 do
    while stamp > self:year_to_days(self.year + 1) + 30 do
      self.year = self.year + 1
    end

    stamp = stamp - self:year_to_days(self.year)

    while self.month < 12 and stamp > (367*(self.month+1)/12) do
      self.month = self.month + 1
    end

    stamp = stamp - (367 * self.month / 12);

    self.month = self.month + 2

    if self.month > 12 then
      self.month = self.month - 12
      self.year = self.year + 1
    end

    self.day = stamp
  end,
  get_iso_stamp=function(self)
    return(string.format("%04u-%02u-%02uT%02u:%02u:%02u+00:00",self.year,self.month,self.day,self.hour,self.minute,self.second))
  end,
  run=function(self,t,uinterval,sinterval,server)
    if server then self.ntpserver = server end
    self.lastsync = sinterval * 2 * -1  -- force sync on first run
    tmr.alarm(t,uinterval * 1000,1,function()
      self.ustamp = self.ustamp + uinterval
      self:set_time()
      if self.lastsync + sinterval < self.ustamp then
        self:sync()
      end
    end)
  end
})

