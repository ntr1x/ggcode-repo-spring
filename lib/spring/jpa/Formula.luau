local case = require('core/util/string/case')

local Formula = {
  __type = 'Formula',
  name = nil,
  java_type = nil,
  db_type = nil,
  user_type = nil,
  is_lob = nil,
  formula = nil,
}

function Formula:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Formula:uuid(name: string, formula: string)
  return Formula:new({
    name = name,
    java_type = "java.util.UUID",
    db_type = "uuid",
    formula = formula
  })
end

function Formula:text(name: string, formula: string)
  return Formula:new({
    name = name,
    java_type = "java.lang.String",
    db_type = "text",
    formula = formula
  })
end

function Formula:decimal(name: string, formula: string)
  return Formula:new({
    name = name,
    java_type = "java.math.BigDecimal",
    db_type = "numeric(38,2)",
    formula = formula
  })
end

function Formula:int(name: string, formula: string)
  return Formula:new({
    name = name,
    java_type = "java.lang.Integer",
    db_type = "int4",
    formula = formula
  })
end

function Formula:long(name: string, formula: string)
  return Formula:new({
    name = name,
    java_type = "java.lang.Long",
    db_type = "int8",
    formula = formula
  })
end

function Formula:boolean(name: string, formula: string)
  return Formula:new({
    name = name,
    java_type = "java.lang.Boolean",
    db_type = "boolean",
    formula = formula
  })
end

function Formula:datetime(name: string, formula: string)
  return Formula:new({
    name = name,
    java_type = "java.time.LocalDateTime",
    db_type = "timestamp(6)",
    formula = formula
  })
end

function Formula:datetime_tz(name: string, formula: string)
  return Formula:new({
    name = name,
    java_type = "java.time.ZonedDateTime",
    db_type = "timestamp(6) with time zone",
    formula = formula
  })
end

function Formula:json(name: string, formula: string)
  return Formula:new({
    name = name,
    java_type = "com.fasterxml.jackson.databind.JsonNode",
    db_type = "json",
    formula = formula
  })
end

function Formula:jsonb(name: string, formula: string)
  return Formula:new({
    name = name,
    java_type = "com.fasterxml.jackson.databind.JsonNode",
    db_type = "jsonb",
    formula = formula
  })
end

function Formula:setup(overrides: table)
  for k,v in overrides do
    self[k] = v
  end
end

function Formula:with_column_definition(column_definition: string)
  self.column_definition = column_definition
  return self
end

function Formula:with_user_type(user_type: string)
  self.user_type = user_type
  return self
end

function Formula:with_lob(is_lob: boolean)
  if is_lob == nil then
    is_lob = true
  end
  self.is_lob = is_lob
  return self
end

function Formula:unwrap()
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    formula = self.formula,
    java_type = self.java_type,
    db_type = self.db_type,
    user_type = self.user_type,
    is_lob = self.is_lob,
  }
end

return Formula