local case = require('core/util/string/case')

local Resource = {
  __type = 'Resource',
  title = nil,
  description = nil,
  projection = nil,
  unit = nil,
}

function Resource:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Resource:from(projection: Projection, unit: Unit)
  return Resource:new({
    projection = projection,
    unit = unit,
  })
end

function Resource:with_title(title: string)
  self.title = title
  return self
end

function Resource:with_description(description: string)
  self.description = description
  return self
end

function Resource:unwrap_resource()
  local name = self.projection.name .. '_' .. self.unit.name
  local pascal_name = case.snakeToPascal(name)
  return {
    name = name,
    snake_name = name,
    camel_name = case.snakeToCamel(name),
    pascal_name = pascal_name,
    kebab_name = case.snakeToKebab(name),
    title = self.title or pascal_name,
    description = self.description,
  }
end

function Resource:unwrap()
  return {
    project = self.unit.module:unwrap_project(),
    module = self.unit:unwrap_module(),
    unit = self.unit:unwrap_unit(),
    package = self.unit.module:unwrap_package(),
    entity = self.unit.entity:unwrap(),
    projection = self.projection:unwrap(),
    resource = self:unwrap_resource(),
  }
end

return Resource
