local case = require('core/util/string/case')

local Resource = {
  __type = 'Resource',
  projection = nil,
  unit = nil,
  actions = {},
  context = {},
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
    context = {},
  })
end

function Resource:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Action' then
      self.actions[#self.actions + 1] = child
    elseif child.__type == 'Auth' then
      self.context[#self.context + 1] = child
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
    actions = self:unwrap_actions_map(),
    context = self:unwrap_context(),
  }
end

function Resource:unwrap_actions_map()
  local actions = {}

  for i, a in self.projection:unwrap_actions() do
    actions[a.method] = {
      role = a.role
    }
  end

  for i, a in self.actions do
    actions[a.method] = {
      role = a.role
    }
  end
  return actions
end

function Resource:unwrap_context()
  local context = self.projection:unwrap_context()
  for i, item in self.context do
    context[#context + 1] = item:unwrap()
  end
  return context
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
