local object = require('core/util/object')
local split = require('core/util/string/split')
local case = require('core/util/string/case')

local case = require('core/util/string/case')

local Ref = {
  __type = 'Ref',
  variant = nil,
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

function Ref:one(options: table)
  return Ref:new({
    variant = 'one',
    name = options.name,
    unit = options.unit,
    column = options.column,
  })
end

function Ref:many(options: table)
  return Ref:new({
    variant = 'many',
    name = options.name,
    unit = options.unit,
    column = options.column,
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
    variant = self.variant,
    column = self.column,
    name = self.name,
    camel_name = case.snakeToCamel(self.name),
    kebab_name = case.snakeToKebab(self.name),
    pascal_name = case.snakeToPascal(self.name),
  }
end

return Ref
