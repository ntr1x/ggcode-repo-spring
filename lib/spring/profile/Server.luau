local Server = {
  __type = 'Server',
  port = nil,
}

function Server:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Server:from(port: number)
  return Server:new({
    port = port,
  })
end

function Server:with_port(port: number)
  self.port = port
end

function Server:copy()
  return Server:new({
    port = self.port,
  })
end

function Server:unwrap()
  return {
    port = self.port,
  }
end

return Server
