local case = require('core/util/string/case')
local object = require('core/util/object')

local general = function (name: string)
  return object.spread({
    type = 'pk',
    name = name,
    camel_name = case.snakeToCamel(name),
    pascal_name = case.snakeToPascal(name),
    updatable = "false",
  })
end

local function uuid(name: string)
  local proto = general(name) {
    generator_type = "random",
    java_type = "java.util.UUID",
    db_type = "uuid",
    column_definition = "uuid"
  }
  local template = object.spread(proto)
  return function (overrides)
    return template(overrides or {})
  end
end

local function text(name: string)
  local proto = general(name) {
    java_type = "java.lang.String",
    db_type = "text",
    column_definition = "text"
  }
  local template = object.spread(proto)
  return function (overrides)
    return template(overrides or {})
  end
end

local function decimal(name: string)
  local proto = general(name) {
    java_type = "java.math.BigDecimal",
    db_type = "numeric(38,2)"
  }
  local template = object.spread(proto)
  return function (overrides)
    return template(overrides or {})
  end
end

local function int(name: string)
  local proto = general(name) {
    java_type = "java.lang.Integer",
    db_type = "int4"
  }
  local template = object.spread(proto)
  return function (overrides)
    return template(overrides or {})
  end
end

local function long(name: string)
  local proto = general(name) {
    java_type = "java.lang.Long",
    db_type = "int8"
  }
  local template = object.spread(proto)
  return function (overrides)
    return template(overrides or {})
  end
end

return {
  uuid = uuid,
  text = text,
  decimal = decimal,
  int = int,
  long = long,
}
