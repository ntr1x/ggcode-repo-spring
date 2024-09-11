local Meta = require('core/Meta')
local case = require('core/util/string/case')
local Unit = require('spring/Unit')
local split = require('core/util/string/split')

local Fetch = {
  __type = 'Fetch',
  unit = nil,
  name = nil,
  value = nil,
  path = nil,
  expression = nil,
  is_optional = nil,
}

function Fetch:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Fetch:from(unit: Unit, name: string, options: table)
  options = options or Meta:table({})
  return Fetch:new({
    unit = unit,
    name = name,
    value = options.value,
    expression = options.expression,
    path = options.path,
    is_optional = options.is_optional,
  })
end

function Fetch:by_value(unit: Unit, name: string, value: string)
  return Fetch:from(unit, name, {
    value = value,
  })
end

function Fetch:by_expression(unit: Unit, name: string, expression: string)
  return Fetch:from(unit, name, {
    expression = expression,
  })
end

function Fetch:by_path(unit: Unit, name: string, path: string)
  return Fetch:from(unit, name, {
    path = path
  })
end

function Fetch:with_is_optional(is_optional: boolean)
  if is_optional == nil then
    is_optional = true
  end

  self.is_optional = is_optional
  return self
end

function Fetch:unwrap_path()
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

function Fetch:unwrap()
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    kebab_name = case.snakeToKebab(self.name),
    package = self.unit.module:unwrap_package(),
    unit = self.unit:unwrap_unit(),
    value = self.value,
    expression = self.expression,
    path = self:unwrap_path(self.path),
    is_optional = self.is_optional,
  }
end

return Fetch
