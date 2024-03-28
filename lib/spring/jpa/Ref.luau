local object = require('core/util/object')
local split = require('core/util/string/split')
local case = require('core/util/string/case')

local case = require('core/util/string/case')

local Ref = {
  __type = 'Ref',
  name = nil,
  unit = nil,
  column = nil,
}

function Ref:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Ref:from(name: string, unit: Unit, column: string)
  return Ref:new({
    name = name,
    unit = unit,
    column = column,
  })
end

function Ref:setup(overrides: table)
  for k,v in overrides do
    self[k] = v
  end
end

function Ref:unwrap()
  return {
    unit = {
      package = self.unit.module:unwrap_package(),
      camel_name = case.snakeToCamel(self.unit.name),
      kebab_name = case.snakeToKebab(self.unit.name),
      pascal_name = case.snakeToPascal(self.unit.name),
    },
    column = self.column,
    name = self.name,
    camel_name = case.snakeToCamel(self.name),
    kebab_name = case.snakeToKebab(self.name),
    pascal_name = case.snakeToPascal(self.name),
  }
end

return Ref
