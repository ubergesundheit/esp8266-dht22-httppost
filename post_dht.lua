-- post_dht.lua
pin = 3
port = 80
host_ip = '54.225.217.107'
hostname = 'requestb.in'
path = '/t524f5t5'
json_tpl = "{\"collection\":\"tmps_in2\",\"timestamp\":\"0000-00-00T00:00:00+00:00\",\"data\":{\"temp\":%.1f,\"hum\":%.1f, \"heap\":%u}}"
-- json_tpl = "{\"collection\":\"tmps_in2\",\"data\":{\"temp\":%.1f,\"hum\":%.1f}}"
delay = 20000

function postData(pin)
  -- get dht values
  status,temp,humi = dht.read(pin)
  if( status == dht.OK ) then
    print("establishing connection to ".. hostname .." (".. host_ip ..":".. port ..")")
    json = string.format(json_tpl, temp, humi, node.heap())

    conn=net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload) print(payload) end)
    conn:connect(port, host_ip)
    conn:send("POST ".. path .." HTTP/1.1\r\n")
    conn:send("Host: ".. hostname .."\r\n")
    conn:send("Content-Type: application/json\r\n")
    conn:send("Connection: close\r\n")
    conn:send("Content-Length: ")
    conn:send(string.len(json))
    conn:send("\r\n")
    conn:send("\r\n")
    conn:send(json)
    conn:send("\r\n")
    conn:on("sent", function(conn)
      print("Closing connection")
      conn:close()
    end)
    conn:on("disconnection", function(conn)
      print("disconnected..")
    end)
  elseif( status == dht.ERROR_CHECKSUM ) then
    print( "DHT Checksum error." );
  elseif( status == dht.ERROR_TIMEOUT ) then
    print( "DHT Time out." );
  end

end

-- run function once at start..
postData(pin)

-- send data every once in a while
tmr.alarm(2, delay, 1, function()
  postData(pin)
end )
