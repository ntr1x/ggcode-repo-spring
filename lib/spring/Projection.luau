local Meta = require('core/Meta')
local Override = require('spring/resource/Override')

local Projection = {
  __type = 'Projection',

  Override = Override,

  name = nil,
  actions = nil,
  context = nil,
  overrides = nil,
}

function Projection:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Projection:from(name: string, children: table)
  return Projection
    :new({
      name = name,
      actions = Meta:array {},
      context = Meta:array {},
      overrides = Meta:array {},
    })
    :with_rules(children)
end

function Projection:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Action' then
      self.actions[#self.actions + 1] = child
    elseif child.__type == 'Auth' then
      self.context[#self.context + 1] = child
    elseif child.__type == 'Override' then
      self.overrides[#self.overrides + 1] = child
    end
  end

  return self
end

function Projection:unwrap_actions()
  local by_method = {}
  local array = {}

  for i, item in self.actions do
    local unwrapped = item:unwrap()
    array[i] = unwrapped
    by_method[item.method] = unwrapped
  end

  return {
    by_method = by_method,
    array = array
  }
end

function Projection:unwrap_context()
  local by_name = {}
  local array = {}

  for i, item in self.context do
    local unwrapped = item:unwrap()
    array[i] = unwrapped
    by_name[item.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array
  }
end

function Projection:unwrap()
  return {
    name = self.name,
    actions = self:unwrap_actions(),
    context = self:unwrap_context(),
  }
end

return Projection
