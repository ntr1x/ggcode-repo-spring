local Module = require('spring/Module')
local case = require('core/util/string/case')

local Listener = {
  __type = 'Listener',
  module = nil,
  name = nil,
  id = nil,
  container_factory = nil,
  topic_pattern = nil,
  group_id = nil,
  client_id_prefix = nil,
  concurrency = nil,
  batch = false,
}

function Listener:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Listener:from(module: Module, name: string, batch: boolean)
  return Listener:new({
    module = module,
    name = name,
    batch = batch,
  })
end

function Listener:with_id(id: string)
  self.id = id
  return self
end

function Listener:with_container_factory(container_factory: string)
  self.container_factory = container_factory
  return self
end

function Listener:with_topic_pattern(topic_pattern: string)
  self.topic_pattern = topic_pattern
  return self
end

function Listener:with_group_id(group_id: string)
  self.group_id = group_id
  return self
end

function Listener:with_client_id_prefix(client_id_prefix: string)
  self.client_id_prefix = client_id_prefix
  return self
end

function Listener:with_concurrency(concurrency: string)
  self.concurrency = concurrency
  return self
end

function Listener:unwrap_listener()
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    kebab_name = case.snakeToKebab(self.name),
    id = self.id,
    container_factory = self.container_factory,
    topic_pattern = self.topic_pattern or self.name,
    group_id = self.group_id or self.module.name,
    client_id_prefix = self.client_id_prefix,
    concurrency = self.concurrency,
    batch = self.batch,
  }
end

function Listener:unwrap_module()
  return {
    name = self.module.name
  }
end

function Listener:unwrap()
  return {
    project = self.module:unwrap_project(),
    module = self:unwrap_module(),
    listener = self:unwrap_listener(),
    package = self.module:unwrap_package(),
  }
end

return Listener
