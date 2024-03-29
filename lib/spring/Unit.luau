local Module = require('spring/Module')
local Entity = require('spring/jpa/Entity')

local case = require('core/util/string/case')
local split = require('core/util/string/split')

local Unit = {
  __type = 'Unit',
  module = nil,
  name = nil,
  entity = nil,
}

function Unit:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Unit:from(module: Module, table_name: string, children: table)
  assert(module ~= nil)
  local name = case.propToSnake(table_name)
  return Unit:new({
    module = module,
    name = name,
    entity = Entity:from(table_name, children or {}),
  })
end

function Unit:with_columns(children: table)
  self.entity:with_columns(children)
  return self
end

function Unit:unwrap_unit()
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    kebab_name = case.snakeToKebab(self.name),
  }
end

function Unit:unwrap_module(name: string)
  return {
    name = self.module.name
  }
end

function Unit:unwrap()
  return {
    project = self.module:unwrap_project(),
    module = self:unwrap_module(),
    unit = self:unwrap_unit(),
    package = self.module:unwrap_package(),
    entity = self.entity:unwrap(),
  }
end

return Unit
