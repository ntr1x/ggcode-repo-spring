local OBJECT = require('core/util/object')

local Profile = {
  server = { port = 8080 },
  spring = {
      datasource = {
          url = 'jdbc:postgresql://postgres:5432/demo',
          username = 'demo',
          password = 'demo'
      }
  }
}

function Profile:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Profile:copy()
  return Profile:new(OBJECT.deep_copy({
    server = self.server,
    spring = self.spring,
  }))
end

function Profile:with_datasource(url: string, username: string, password: string)
  self.spring.datasource = {
    url = url,
    username = username,
    password = password,
  }
  return self
end

function Profile:with_port(port: number)
  self.server.port = port
  return self
end

return Profile
