local case = require('core/util/string/case')

local Resource = {
  __type = 'Resource',
  unit = nil,
  name = nil,
  actions = {}
}

function Resource:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Resource:from(unit: Unit, name: string)
  return Resource:new({
    unit = unit,
    name = name,
    actions = {},
  })
end

function Resource:setup(children: table)
  for i, item in children do
  end
  return self
end

function Resource:unwrap()
  return {
    unit = self.unit,
    resource = {
      name = name,
      snake_name = name,
      camel_name = case.snakeToCamel(name),
      pascal_name = case.snakeToPascal(name),
      kebab_name = case.snakeToKebab(name),
    }
  }
end

return Resource
