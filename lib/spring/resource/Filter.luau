local Meta = require('core/Meta')
local case = require('core/util/string/case')

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

function Filter:from(name: string, options: table)
  options = options or Meta:table {}
  return Filter:new({
    name = name,
    expression = options.expression,
  })
end

function Filter:with_expression(expression: string)
  self.expression = expression
  return self
end

function Filter:unwrap()
  return {
    name = self.name,
    expression = self.expression,
  }
end

return Filter
