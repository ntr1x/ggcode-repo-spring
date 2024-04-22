local Meta = require('core/Meta')

local View = {
  __type = 'View',
  name = nil,
  columns = Meta:array {},
}

function View:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function View:from(name: string, columns: table)
  return View:new({
    name = name,
    columns = columns or Meta:array {},
  })
end

function View:kafka(columns: table)
  return View:from('Kafka', columns)
end

function View:create(columns: table)
  return View:from('Create', columns)
end

function View:update(columns: table)
  return View:from('Update', columns)
end

function View:remove(columns: table)
  return View:from('Remove', columns)
end

function View:select(columns: table)
  return View:from('Select', columns)
end

function View:unwrap()
  return {
    name = self.name,
    columns = self.columns,
  }
end

return View
