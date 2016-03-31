-- function postData(data)
--   print(data)
--   local jwt = createJwt(data,DEVICE_SECRET)
--   print(jwt)
--   http.post(POST_URL,
--     'Content-Type: application/json; charset=utf-8\r\n',
--     jwt,
--     function(code, data)
--       if (code < 0) then
--         print("HTTP request failed")
--       else
--         print(code, data)
--
--       end
--     end)
-- end

function postData(data)
  http.post(POST_URL,
    'Content-Type: application/json; charset=utf-8\r\n',
    data,
    function(code, data)
      if (code < 0) then
        print("HTTP request failed")
      else
        print(code, data)

      end
    end)
end

function publishStatus()
  status,temp,humi = dht.read(DHT_PIN)
  if status == dht.OK then
    getTimestamp(function(ts)
      local json = {
        collection=COLLECTION,
        timestamp=ts,
        data={
          temp=temp,
          hum=humi,
          heap=node.heap()
        }
      }
      postData(cjson.encode(json))
    end,
    function()end)
  elseif status == dht.ERROR_CHECKSUM then
    print("dht checksum error")
  elseif status == dht.ERROR_TIMEOUT then
    print("dht timeout")
  end
end

function createJwt(payload,secret)
  -- local header = crypto.toBase64('{"alg":"HS256","typ":"JWT"}')
  local header = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
  local b64payload = crypto.toBase64(payload)
  -- strip padding, as jwt requires the padding to be stripped..
  -- also make urlsafe
  b64payload = b64payload:gsub("%p", b64replace)

  local signature = crypto.toBase64(crypto.hmac('SHA256', string.format("%s.%s", header, b64payload), secret))
  -- also strip padding from signature and make urlsafe
  signature = signature:gsub("%p", b64replace)

  local jwt = string.format("%s.%s.%s", header, b64payload, signature)
  return jwt
end

function b64replace(char)
  if char == "=" then
    return ""
  elseif char == "+" then
    return "-"
  elseif char == "/" then
    return "_"
  else
    return char
  end
end

-- License for the code below. Adapted from Minix 3 'Minix/lib/ansi/gmtime.c'
--
-- Copyright (c) 1987, 1997, 2006, Vrije Universiteit, Amsterdam,
-- The Netherlands All rights reserved. Redistribution and use of the MINIX 3
-- operating system in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are
-- met:
--
--     * Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--
--     * Redistributions in binary form must reproduce the above copyright
--     notice, this list of conditions and the following disclaimer in the
--     documentation and/or other materials provided with the distribution.
--
--     * Neither the name of the Vrije Universiteit nor the names of the
--     software authors or contributors may be used to endorse or promote
--     products derived from this software without specific prior written
--     permission.
--
--     * Any deviations from these conditions require written permission
--     from the copyright holder in advance
--
--
-- Disclaimer
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS, AUTHORS, AND
--  CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
--  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
--  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
--  NO EVENT SHALL PRENTICE HALL OR ANY AUTHORS OR CONTRIBUTORS BE LIABLE
--  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
--  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
--  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
--  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
--  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
--  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
--  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--
-- Aggregated Software
--
-- In addition to MINIX 3 itself, the distribution CD-ROM and this Website
-- contain additional software that is not part of MINIX 3 and is not
-- covered by this license. The licensing conditions for this additional
-- software are stated in the various packages. In particular, some of the
-- additional software falls under the GPL, and you must take care to
-- observe the conditions of the GPL with respect to this software. As
-- clearly stated in Article 2 of the GPL, when GPL and nonGPL software are
-- distributed together on the same medium, this aggregation does not cause
-- the license of either part to apply to the other part.
--
--
-- Acknowledgements
--
-- This product includes software developed by the University of
-- California, Berkeley and its contributors.
--
-- This product includes software developed by Softweyr LLC, the
-- University of California, Berkeley, and its contributors.


function YEARSIZE(year)
  if year % 4 == 0 and ((year % 100 == 0) or not(year % 400 == 0)) then
    return 366
  else
    return 365
  end
end

_ytab = {}
_ytab[365]= {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
_ytab[366]= {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

function getTimestamp(callback,errorCallback)
  sntp.sync(NTP_IP,
    function(unixtime,usec,server)
      rtctime.set(unixtime,usec)
      -- adapted from Minix/lib/ansi/gmtime.c
      local year = 1970
      local dayclock = unixtime % 86400
      local day = unixtime / 86400

      local sec = dayclock % 60

      local min = (dayclock % 3600) / 60

      local hour = dayclock / 3600

      local yearsize = YEARSIZE(year)
      while (day >= yearsize) do
        day = day - yearsize
        year = year + 1
        yearsize = YEARSIZE(year)
      end

      local month = 1
      while day >= _ytab[yearsize][month] do
        day = day - _ytab[yearsize][month]
        month = month + 1
      end
      day = day + 1

      callback(string.format("%04u-%02u-%02uT%02u:%02u:%02uZ",year,month,day,hour,min,sec))
    end,
    errorCallback
  )
end
