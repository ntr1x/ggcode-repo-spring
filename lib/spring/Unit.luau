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

function Unit:from(module: Module, name: string)
  return Unit:new({
    module = module,
    name = name,
    entity = nil,
  })
end

function Unit:setup_entity(table_name: string)
  local unit = self
  return function (children: table)
    unit.entity = Entity:from(table_name, children)
  end
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
