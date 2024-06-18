local Meta = require('core/Meta')
local case = require('core/util/string/case')

local Entity = {
  __type = 'Entity',
  table = nil,
  schema = nil,
  keys = {},
  columns = {},
  refs = {},
}

function Entity:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Entity:from(name: string, children: table)
  local schema, table = name:match("([^.]+).([^.]+)")

  return Entity
    :new({
      schema = schema,
      table = table,
      keys = {},
      columns = {},
      refs = {}
    })
    :with_columns(children)
end

function Entity:with_columns(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'PK' then
      self.keys[#self.keys + 1] = child
    elseif child.__type == 'Prop' then
      self.columns[#self.columns + 1] = child
    elseif child.__type == 'Ref' then
      self.refs[#self.refs + 1] = child
    end
  end

  return self
end

function Entity:unwrap_keys()
  local by_name = Meta:table {}
  local array = Meta:array {}

  for i, key in self.keys do
    local unwrapped = key:unwrap()
    array[#array + 1] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Entity:unwrap_columns()
  local by_name = Meta:table {}
  local array = Meta:array {}

  for i, column in self.columns do
    local unwrapped = column:unwrap()
    array[#array + 1] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Entity:unwrap_refs()
  local by_name = Meta:table {}
  local array = Meta:array {}

  for i, ref in self.refs do
    local unwrapped = ref:unwrap()
    array[#array + 1] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Entity:unwrap()
  local pk = (if #self.keys > 0 then self.keys[1] else nil)

  return {
    pk = pk:unwrap(),
    schema = self.schema,
    table = self.table,
    keys = self:unwrap_keys(),
    columns = self:unwrap_columns(),
    refs = self:unwrap_refs(),
  }
end

return Entity
