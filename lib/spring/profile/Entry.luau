local Entry = {
  __type = 'Entry',
  name = nil,
  config = nil,
}

function Entry:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Entry:from(name: string, config: table)
  return Entry:new({
    name = name,
    config = config,
  })
end

function Entry:copy()
  return Entry:new({
    name = self.name,
    config = OBJECT.deep_copy(self.config),
  })
end

function Entry:unwrap()
  return {
    name = self.name,
    config = self.config,
  }
end

return Entry
