local Meta = require('core/Meta')
local case = require('core/util/string/case')
local split = require('core/util/string/split')

local Arg = {
  __type = 'Arg',
  path = nil,
  value = nil,
  expression = nil,
}

function Arg:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Arg:from_path(path: string)
  return Arg:new({
    path = path,
  })
end

function Arg:from_value(value: string)
  return Arg:new({
    value = value,
  })
end

function Arg:from_expression(epression: string)
  return Arg:new({
    epression = epression,
  })
end

function Arg:unwrap_path()
  if self.path ~= nil then
    local array = Meta:array {}
    local segments = split.split(self.path, split.EXPR_DOT)
    for _, name in segments do
      local segment = {
        name = name,
        snake_name = name,
        camel_name = case.snakeToCamel(name),
        pascal_name = case.snakeToPascal(name),
        kebab_name = case.snakeToKebab(name),
      }
      array[#array + 1] = segment
    end
    return array
  end
  return nil
end

function Arg:unwrap()
  return {
    path = self:unwrap_path(),
    expression = self.expression,
  }
end

return Arg
