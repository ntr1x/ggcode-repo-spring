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

  local keys = {}
  local columns = {}
  local refs = {}

  children = children or {}

  for _, child in children do
    if child.__type == 'PK' then
      keys[#keys + 1] = child
    elseif child.__type == 'Prop' then
      columns[#columns + 1] = child
    elseif child.__type == 'Ref' then
      refs[#refs + 1] = child
    end
  end

  return Entity:new({
    schema = schema,
    table = table,
    keys = keys,
    columns = columns,
    refs = refs,
  })
end

function Entity:unwrap_keys()
  local keys = {}
  for i, key in self.keys do
    keys[i] = key:unwrap()
  end
  return keys
end

function Entity:unwrap_columns()
  local columns = {}
  for i, column in self.columns do
    columns[i] = column:unwrap()
  end
  return columns
end

function Entity:unwrap_refs()
  local refs = {}
  for i, ref in self.refs do
    refs[i] = ref:unwrap()
  end
  return refs
end

function Entity:unwrap()
  local pk = (if #self.keys > 0 then self.keys[1] else nil)

  return {
    pk = pk,
    schema = self.schema,
    table = self.table,
    keys = self:unwrap_keys(),
    columns = self:unwrap_columns(),
    refs = self:unwrap_refs(),
  }
end

-- local function entity (table_name: string)
--   local schema, name = table_name:match("([^.]+).([^.]+)")
--   return function (children: table)

--     local keys = {}
--     local columns = {}
--     local refs = {}

--     for _, child in children do
--       local item = if type(child) == 'function' then child() else child
--       if item.type == 'pk' then
--         keys[#keys + 1] = item
--       elseif item.type == 'prop' then
--         columns[#columns + 1] = item
--       elseif item.type == 'ref' then
--         refs[#refs + 1] = item
--       end
--     end

--     local pk = (if #keys > 0 then keys[1] else nil)

--     local res = {
--       pk = pk,
--       schema = schema,
--       name = case.snakeToPascal(name),
--       camel_name = case.snakeToCamel(name),
--       pascal_name = case.snakeToPascal(name),
--       snake_name = name,
--       table = name,
--       keys = keys,
--       columns = columns,
--       refs = refs,
--     }

--     return res
--   end
-- end

return Entity
