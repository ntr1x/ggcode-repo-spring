local Datasource = {
  __type = 'Datasource',
  url = nil,
  username = nil,
  password = nil,
}

function Datasource:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Datasource:from_config(config: table)
  return Datasource:new({
    url = config.url,
    username = config.username,
    password = config.password,
  })
end

function Datasource:copy()
  return Datasource:new({
    url = self.url,
    username = self.username,
    password = self.password,
  })
end

function Datasource:unwrap()
  return {
    url = self.url,
    username = self.username,
    password = self.password,
  }
end

return Datasource
