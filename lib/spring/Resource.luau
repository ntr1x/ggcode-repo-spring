local case = require('core/util/string/case')

local Resource = {
  __type = 'Resource',
  projection = nil,
  unit = nil,
  actions = {}
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
    actions = {},
  })
end

function Resource:with_actions(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Action' then
      self.actions[#self.actions + 1] = child
    end
  end

  return self
end

function Resource:unwrap_resource()
  local name = self.projection.name .. '_' .. self.unit.name
  return {
    name = name,
    snake_name = name,
    camel_name = case.snakeToCamel(name),
    pascal_name = case.snakeToPascal(name),
    kebab_name = case.snakeToKebab(name),
  }
end

function Resource:unwrap_actions()
  local actions = {}
  for i, a in self.actions do
    actions[a.method] = {
      role = a.role
    }
  end
  return actions
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
    actions = self:unwrap_actions(),
  }
end

return Resource
