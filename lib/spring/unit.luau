local Module = require('spring/module')
local entity = require('spring/jpa/entity')
local case = require('core/util/string/case')
local split = require('core/util/string/split')

local Unit = {
  parent = nil,
  module = nil,
  project = nil,
  package = nil,
  name = nil,
  snake_name = nil,
  pascal_name = nil,
  kebab_name = nil,
  entity = nil,
}

function Unit:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Unit:from(parent: Module, name: string)
  return Unit:new({
    parent = parent,
    project = parent.project,
    module = parent.module,
    package = parent.package,
    name = name,
    snake_name = name,
    camel_name = case.snakeToCamel(name),
    pascal_name = case.snakeToPascal(name),
    kebab_name = case.snakeToKebab(name),
  })
end

function Unit:entity(table_name: string)
  return function (children: table)
    self.entity = entity.entity(table_name)(children)
  end
end

return Unit
