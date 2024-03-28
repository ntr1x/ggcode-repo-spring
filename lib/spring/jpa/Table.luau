local case = require('core/util/string/case')

local Table = {
  __type = 'Table',
  table = nil,
  schema = nil,
}

function Table:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Table:from(name: string)
  local schema, table = self.name:match("([^.]+).([^.]+)")
  return Table:new({
    table = table,
    schema = schema,
  })
end

function Table:unwrap()
  return {
    table = self.table,
    schema = self.schema,
  }
end

return Table
