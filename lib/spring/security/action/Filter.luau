local Filter = {
  __type = 'Filter',
  name = nil,
  expression = nil,
}

function Filter:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Filter:from(name: string, expression: string)
  return Filter:new({
    name = name,
    expression = expression,
  })
end

function Filter:unwrap()
  return {
    name = self.name,
    expression = self.expression,
  }
end

return Filter
