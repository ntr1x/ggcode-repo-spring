local Meta = require('core/Meta')
local case = require('core/util/string/case')
local split = require('core/util/string/split')

local Link = {
  __type = 'Link',
  name = nil,
  resource = nil,
}

function Link:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Link:from_resource(name: string, resource: Resource)
  assert(name ~= nil)
  assert(resource ~= nil)
  return Link:new({
    name = name,
    resource = resource,
  })
end

function Link:unwrap_link()
  return {
    name = self.name,
    snake_name = name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    kebab_name = case.snakeToKebab(self.name),
  }
end

function Link:unwrap()
  return {
    link = self:unwrap_link(),
    unit = self.resource.unit:unwrap_unit(),
    package = self.resource.unit.module:unwrap_package(),
    projection = self.resource.projection:unwrap(),
    requests = self.resource:unwrap_requests(),
    resource = self.resource:unwrap_resource(),
  }
end

return Link
