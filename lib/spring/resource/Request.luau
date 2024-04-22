local Meta = require('core/Meta')
local Unit = require('spring/Unit')

local Request = {
  __type = 'Request',
  name = nil,
  unit = nil,
  filters = Meta:array {},
  overrides = Meta:array {},
}

function Request:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Request:from(name: string, unit: Unit)
  return Request:new({
    name = name,
    unit = unit,
    filters = Meta:array {},
    overrides = Meta:array {},
  })
end

function Request:create(unit: Unit)
  return Request:from('create', unit)
end

function Request:update(unit: Unit)
  return Request:from('update', unit)
end

function Request:remove(unit: Unit)
  return Request:from('remove', unit)
end

function Request:select(unit: Unit)
  return Request:from('select', unit)
end

function Request:put(unit: Unit)
  return Request:from('put', unit)
end

function Request:with_rules(children: table)
  children = children or Meta:array({})

  for _, child in children do
    if child.__type == 'Filter' then
      self.filters[#self.filters + 1] = child
    elseif child.__type == 'Override' then
      self.overrides[#self.overrides + 1] = child
    end
  end

  return self
end

function Request:with_overrides(overrides: table)
  return with_rules(overrides)
end

function Request:with_filters(filters: table)
  return with_rules(filters)
end

function Request:unwrap_overrides(parent_resource: table)
  local overrides = Meta:table {}

  for _, item in parent_resource.projection.overrides do
    local unwrapped = item:unwrap()
    overrides[unwrapped.name] = unwrapped
  end

  for _, action in parent_resource.projection.actions do
    if action.method == self.name then
      for _, item in action.overrides do
        local unwrapped = item:unwrap()
        overrides[unwrapped.name] = unwrapped
      end
    end
  end

  for _, item in parent_resource.overrides do
    local unwrapped = item:unwrap()
    overrides[unwrapped.name] = unwrapped
  end

  for _, item in self.overrides do
    local unwrapped = item:unwrap()
    overrides[unwrapped.name] = unwrapped
  end

  return overrides
end

function unwrap_children(children: table, overrides: table)
  local by_name = Meta:table {}
  local array = Meta:array {}

  for _, column in children do
    local override = overrides[column.name]
    column.override = override

    by_name[column.name] = column
    array[#array + 1] = column
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Request:unwrap_keys(overrides: table)
  local columns = self.unit.entity:unwrap_keys()
  return unwrap_children(columns.array, overrides)
end

function Request:unwrap_columns(overrides: table)
  local columns = self.unit.entity:unwrap_columns()
  return unwrap_children(columns.array, overrides)
end

function Request:unwrap_refs(overrides: table)
  local columns = self.unit.entity:unwrap_refs()
  return unwrap_children(columns.array, overrides)
end

function Request:unwrap(parent_resource: table)
  local overrides = self:unwrap_overrides(parent_resource)

  return {
    name = self.name,
    keys = self:unwrap_keys(overrides),
    columns = self:unwrap_columns(overrides),
    refs = self:unwrap_refs(overrides),
    overrides = overrides,
  }
end

return Request
