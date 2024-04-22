local case = require('core/util/string/case')

local Prop = {
  __type = 'Prop',
  name = nil,
  updatable = nil,
  java_type = nil,
  db_type = nil,
  column_definition = nil,
}

function Prop:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Prop:uuid(name: string)
  return Prop:new({
    name = name,
    java_type = "java.util.UUID",
    db_type = "uuid",
    column_definition = "uuid"
  })
end

function Prop:text(name: string)
  return Prop:new({
    name = name,
    java_type = "java.lang.String",
    db_type = "text",
    column_definition = "text"
  })
end

function Prop:decimal(name: string)
  return Prop:new({
    name = name,
    java_type = "java.math.BigDecimal",
    db_type = "numeric(38,2)"
  })
end

function Prop:int(name: string)
  return Prop:new({
    name = name,
    java_type = "java.lang.Integer",
    db_type = "int4"
  })
end

function Prop:long(name: string)
  return Prop:new({
    name = name,
    java_type = "java.lang.Long",
    db_type = "int8"
  })
end

function Prop:boolean(name: string)
  return Prop:new({
    name = name,
    java_type = "java.lang.Boolean",
    db_type = "boolean"
  })
end

function Prop:datetime(name: string)
  return Prop:new({
    name = name,
    java_type = "java.time.LocalDateTime",
    db_type = "timestamp(6)"
  })
end

function Prop:datetime_tz(name: string)
  return Prop:new({
    name = name,
    java_type = "java.time.ZonedDateTime",
    db_type = "timestamp(6) with time zone"
  })
end

function Prop:setup(overrides: table)
  for k,v in overrides do
    self[k] = v
  end
end

function Prop:unwrap()
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    updatable = self.updatable,
    java_type = self.java_type,
    db_type = self.db_type,
    column_definition = self.column_definition,
  }
end

return Prop