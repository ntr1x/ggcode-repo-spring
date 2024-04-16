local Meta = require('core/Meta')
local case = require('core/util/string/case')
local Signal = require('spring/exchange/Signal')

local Resource = {
  __type = 'Resource',
  title = nil,
  description = nil,
  projection = nil,
  signals = nil,
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
    signals = {},
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

function Resource:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Signal' then
      self.signals[#self.signals + 1] = child
    end
  end

  return self
end

function Resource:with_default_signals(topic: string)
  local signals = {
    Signal:create(topic, '#result'),
    Signal:update(topic, '#result'),
    Signal:remove(topic, '#result'),
    Signal:replace(topic, '#result'),
  }

  for _, signal in signals do
    self.signals[#self.signals + 1] = signal
  end

  return self
end

function Resource:with_expanded_signals(topic: string)
  local signals = {
    Signal:create(topic, '#result.created'),
    Signal:update(topic, '#result.updated'),
    Signal:remove(topic, '#result.removed'),
    Signal:replace(topic, '#result.removed', 'removed'),
    Signal:replace(topic, '#result.created', 'created'),
  }

  for _, signal in signals do
    self.signals[#self.signals + 1] = signal
  end

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

function Resource:unwrap_signals()
  local signals = {}
  for i, signal in self.signals do
    local array = signals[signal.action] or Meta:array({})
    array[#array + 1] = signal:unwrap()
    signals[signal.action] = array
  end
  return signals
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
    signals = self:unwrap_signals(),
  }
end

return Resource
