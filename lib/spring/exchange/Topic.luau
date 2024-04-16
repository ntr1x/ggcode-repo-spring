local case = require('core/util/string/case')

local Topic = {
  __type = 'Topic',
  name = nil,
  partitions = 1,
  replicas = 1,
  compact = nil,
}

function Topic:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Topic:from(name: string, partitions: number, replicas: number, compact: boolean)
  return Topic:new({
    name = name,
    partitions = partitions,
    replicas = replicas,
    compact = compact,
  })
end

function Topic:with_partitions(partitions: number)
  self.partitions = partitions
  return self
end

function Topic:with_replicas(replicas: number)
  self.replicas = replicas
  return self
end

function Topic:with_compact(compact: boolean)
  self.compact = compact
  return self
end

function Topic:unwrap()
    return {
      name = self.name,
      snake_name = self.name,
      camel_name = case.snakeToCamel(self.name),
      pascal_name = case.snakeToPascal(self.name),
      kebab_name = case.snakeToKebab(self.name),
      partitions = self.partitions,
      replicas = self.replicas,
      compact = self.compact,
    }
end

return Topic
