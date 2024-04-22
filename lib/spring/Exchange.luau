local case = require('core/util/string/case')
local Meta = require('core/Meta')
local Module = require('spring/Module')

local Exchange = {
  module = nil,
  name = nil,
  topics = nil,
}

function Exchange:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Exchange:clone()
  local topics = Meta:array {}
  for i, topic in self.topics do
    topics[#topics + 1] = topic
  end

  return Exchange:new({
    module = self.module,
    name = self.name,
    topics = topics,
  })
end

function Exchange:from(module: Module, name: string)
  return Exchange:new({
    module = module,
    name = name,
    topics = {},
  })
end

function Exchange:with_module(module: Module)
  self.module = module
  return self
end

function Exchange:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Topic' then
      self.topics[#self.topics + 1] = child
    end
  end

  return self
end

function Exchange:unwrap_module()
  return {
    name = self.module.name
  }
end

function Exchange:unwrap_exchange()
  local name = self.name or self.module.name

  return {
    name = name,
    snake_name = name,
    camel_name = case.snakeToCamel(name),
    pascal_name = case.snakeToPascal(name),
    kebab_name = case.snakeToKebab(name),
  }
end

function Exchange:unwrap_topics()
  local topics = {}
  for i, topic in self.topics do
    topics[i] = topic:unwrap()
  end
  return topics
end

function Exchange:unwrap()
    return {
      project = self.module:unwrap_project(),
      module = self:unwrap_module(),
      package = self.module:unwrap_package(),
      topics = self:unwrap_topics(),
      exchange = self:unwrap_exchange(),
    }
end

return Exchange
