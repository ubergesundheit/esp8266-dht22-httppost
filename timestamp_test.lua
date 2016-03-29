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

function getTimestamp(unixtime)
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

  return string.format("%04u-%02u-%02uT%02u:%02u:%02uZ",year,month,day,hour,min,sec)
end

tests = 0
errors = 0

function test(rfc, unix)
  tests = tests + 1
  local converted = getTimestamp(unix)

  if rfc == converted then
  else
    errors = errors + 1
    print("!!! not correct")
    print(unix)
    print(rfc)
    print(converted)
    print("!!!")
  end
end

test("2016-08-09T00:03:14Z",1470700994)
test("2016-08-21T00:41:50Z",1471740110)
test("2016-09-07T00:42:51Z",1473208971)
test("2016-09-12T01:06:59Z",1473642419)
test("2016-10-11T01:07:14Z",1476148034)
test("2016-11-10T01:28:16Z",1478741296)
test("2017-01-24T01:33:51Z",1485221631)
test("2017-02-14T01:43:47Z",1487036627)
test("2017-03-04T01:45:31Z",1488591931)
test("2017-03-10T02:30:30Z",1489113030)
test("2017-05-05T02:33:13Z",1493951593)
test("2018-01-13T03:22:07Z",1515813727)
test("2018-05-05T03:26:42Z",1525490802)
test("2018-08-30T03:27:32Z",1535599652)
test("2018-10-20T03:34:12Z",1540006452)
test("2019-01-01T03:40:29Z",1546314029)
test("2019-04-09T03:48:39Z",1554781719)
test("2019-06-13T04:08:22Z",1560398902)
test("2019-06-19T04:15:22Z",1560917722)
test("2019-07-07T04:43:20Z",1562474600)
test("2020-01-16T04:59:06Z",1579150746)
test("2020-04-03T05:10:57Z",1585890657)
test("2020-05-27T05:15:17Z",1590556517)
test("2020-09-27T05:16:14Z",1601183774)
test("2020-12-13T05:17:44Z",1607836664)
test("2016-01-04T05:44:13Z",1451886253)
test("2016-01-19T05:49:26Z",1453182566)
test("2016-01-31T05:57:31Z",1454219851)
test("2016-05-18T06:23:06Z",1463552586)
test("2016-05-24T06:59:54Z",1464073194)
test("2016-06-30T07:02:16Z",1467270136)
test("2016-12-09T07:10:19Z",1481267419)
test("2017-04-19T07:13:42Z",1492586022)
test("2017-08-13T07:18:30Z",1502608710)
test("2017-09-24T07:23:08Z",1506237788)
test("2017-09-28T08:04:09Z",1506585849)
test("2017-11-07T08:22:10Z",1510042930)
test("2018-01-01T09:14:45Z",1514798085)
test("2018-01-10T09:27:51Z",1515576471)
test("2018-02-01T09:41:18Z",1517478078)
test("2018-02-20T10:21:54Z",1519122114)
test("2018-07-18T11:27:01Z",1531913221)
test("2018-07-28T11:36:47Z",1532777807)
test("2019-02-14T11:55:16Z",1550145316)
test("2019-04-05T12:04:43Z",1554465883)
test("2019-08-10T12:11:14Z",1565439074)
test("2019-08-28T12:13:07Z",1566994387)
test("2020-02-04T12:45:51Z",1580820351)
test("2020-04-23T12:48:14Z",1587646094)
test("2020-07-11T12:58:53Z",1594472333)
test("2016-01-13T13:01:05Z",1452690065)
test("2016-05-23T13:18:51Z",1464009531)
test("2016-07-21T13:55:55Z",1469109355)
test("2016-09-04T14:05:16Z",1472997916)
test("2016-10-18T14:07:27Z",1476799647)
test("2017-01-22T14:08:31Z",1485094111)
test("2017-04-01T14:15:06Z",1491056106)
test("2017-05-25T14:29:13Z",1495722553)
test("2017-05-29T14:31:52Z",1496068312)
test("2017-06-08T14:49:44Z",1496933384)
test("2017-08-17T14:52:17Z",1502981537)
test("2017-11-17T15:00:58Z",1510930858)
test("2018-03-22T15:06:30Z",1521731190)
test("2018-04-06T15:10:42Z",1523027442)
test("2018-05-05T15:49:47Z",1525535387)
test("2018-05-12T15:52:50Z",1526140370)
test("2018-08-18T16:14:12Z",1534608852)
test("2018-09-30T16:18:47Z",1538324327)
test("2018-12-02T16:31:25Z",1543768285)
test("2019-01-12T16:43:50Z",1547311430)
test("2019-08-02T16:48:26Z",1564764506)
test("2019-11-03T16:56:30Z",1572800190)
test("2020-04-15T17:01:28Z",1586970088)
test("2020-09-23T17:04:24Z",1600880664)
test("2020-10-05T17:08:41Z",1601917721)
test("2016-02-03T17:25:53Z",1454520353)
test("2016-02-07T17:29:45Z",1454866185)
test("2016-05-06T17:38:32Z",1462556312)
test("2016-06-05T18:07:14Z",1465150034)
test("2016-12-01T18:15:56Z",1480616156)
test("2017-01-16T18:16:29Z",1484590589)
test("2017-01-31T18:46:03Z",1485888363)
test("2017-02-24T18:54:33Z",1487962473)
test("2017-04-12T18:59:05Z",1492023545)
test("2017-11-05T19:13:56Z",1509909236)
test("2018-09-07T19:43:20Z",1536349400)
test("2018-12-03T20:17:42Z",1543868262)
test("2019-02-15T21:03:36Z",1550264616)
test("2019-06-29T21:04:21Z",1561842261)
test("2019-07-07T21:24:27Z",1562534667)
test("2019-08-06T21:47:39Z",1565128059)
test("2019-09-24T21:53:29Z",1569362009)
test("2019-11-05T22:20:10Z",1572992410)
test("2019-11-28T22:33:09Z",1574980389)
test("2020-01-24T22:41:39Z",1579905699)
test("2020-04-12T23:03:42Z",1586732622)
test("2020-05-06T23:18:52Z",1588807132)
test("2020-07-25T23:21:56Z",1595719316)
test("2020-11-02T23:26:40Z",1604359600)
test("2020-11-14T23:29:27Z",1605396567)

print(string.format("%i of %i tests failed", errors, tests))
