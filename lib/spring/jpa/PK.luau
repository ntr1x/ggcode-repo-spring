local case = require('core/util/string/case')

local PK = {
  __type = 'PK',
  name = nil,
  updatable = "false",
  generator_type = nil,
  java_type = nil,
  db_type = nil,
  column_definition = nil,
}

function PK:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function PK:uuid(name: string)
  return PK:new({
    name = name,
    generator_type = "random",
    java_type = "java.util.UUID",
    db_type = "uuid",
    column_definition = "uuid"
  })
end

function PK:text(name: string)
  return PK:new({
    name = name,
    java_type = "java.lang.String",
    db_type = "text",
    column_definition = "text"
  })
end

function PK:decimal(name: string)
  return PK:new({
    name = name,
    java_type = "java.math.BigDecimal",
    db_type = "numeric(38,2)"
  })
end

function PK:int(name: string)
  return PK:new({
    name = name,
    java_type = "java.lang.Integer",
    db_type = "int4"
  })
end

function PK:long(name: string)
  return PK:new({
    name = name,
    java_type = "java.lang.Long",
    db_type = "int8"
  })
end

function PK:setup(overrides: table)
  for k,v in overrides do
    self[k] = v
  end
end

function PK:unwrap()
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    updatable = self.updatable,
    generator_type = self.generator_type,
    java_type = self.java_type,
    db_type = self.db_type,
    column_definition = self.column_definition,
  }
end

return PK
