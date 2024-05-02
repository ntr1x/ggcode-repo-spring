local Meta = require('core/Meta')
local ARRAY = require('core/util/array')
local case = require('core/util/string/case')
local Signal = require('spring/resource/Signal')
local View = require('spring/resource/View')
local Request = require('spring/resource/Request')
local Override = require('spring/resource/Override')
local Filter = require('spring/resource/Filter')
local Fetch = require('spring/resource/Fetch')
local Validate = require('spring/resource/Validate')

local Resource = {
  __type = 'Resource',

  Signal = Signal,
  View = View,
  Request = Request,
  Override = Override,
  Filter = Filter,
  Fetch = Fetch,
  Validate = Validate,

  title = nil,
  description = nil,
  projection = nil,
  unit = nil,
  signals = nil,
  views = nil,
  requests = nil,
  overrides = nil,
  filters = nil,
  fetches = nil,
  validations = nil,
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
    signals = Meta:array {},
    views = Meta:array {},
    requests = Meta:array {},
    overrides = Meta:array {},
    filters = Meta:array {},
    fetches = Meta:array {},
    validations = Meta:array {},
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
    elseif child.__type == 'View' then
      self.views[#self.views + 1] = child
    elseif child.__type == 'Request' then
      self.requests[#self.requests + 1] = child
    elseif child.__type == 'Override' then
      self.overrides[#self.overrides + 1] = child
    elseif child.__type == 'Filter' then
      self.filters[#self.filters + 1] = child
    elseif child.__type == 'Fetch' then
      self.fetches[#self.fetches + 1] = child
    elseif child.__type == 'Validation' then
      self.validations[#self.validations + 1] = child
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
    Signal:upsert(topic, '#result.updated'),
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

function Resource:unwrap_requests()
  local by_name = {}

  for i, request in self.requests do
    by_name[request.name] = request:unwrap(self)
  end

  for i, request_name in { 'create', 'replace', 'update', 'upsert', 'select', 'get', 'remove', 'find' } do
    if not by_name[request_name] then
      local request = Request:from(request_name, self.unit)
      by_name[request_name] = request:unwrap(self)
    end
  end

  return by_name
end

function Resource:unwrap_views()
  local by_view = Meta:table {}
  local by_column = Meta:table {}

  for _, child in self.views do
    local unwrapped = child:unwrap()

    local columns = by_view[child.name] or Meta:array({})

    for i, c in child.columns do
      columns[#columns + 1] = c

      local views = by_column[c] or Meta:array({})
      views[#views + 1] = child.name
      by_column[c] = views
    end

    by_view[child.name] = columns
  end

  return {
    by_view = by_view,
    by_column = by_column,
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
    signals = self:unwrap_signals(),
    views = self:unwrap_views(),
    requests = self:unwrap_requests(),
  }
end

return Resource
