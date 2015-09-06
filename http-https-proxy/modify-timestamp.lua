local cjson = require "cjson"

if ngx.req.get_method() == "POST" then
  ngx.req.read_body()

  local oldbody = ngx.req.get_body_data()
  local json_body = cjson.decode(oldbody)
  json_body["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S%z")
  
  ngx.req.set_body_data(cjson.encode(json_body))
  return
end
