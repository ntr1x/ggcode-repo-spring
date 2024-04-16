local case = require('core/util/string/case')

local Producer = {
  __type = 'Producer',
  action = nil,
  topic = nil,
}

function Producer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Producer:from(action: string, name: string)
  return Producer:new({
    action = action,
  })
end

function Producer:unwrap()
  return {
    action = self.action,
  }
end

return Producer
