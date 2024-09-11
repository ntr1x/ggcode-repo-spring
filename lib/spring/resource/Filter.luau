local Meta = require('core/Meta')
local case = require('core/util/string/case')
local split = require('core/util/string/split')

local Filter = {
  __type = 'Filter',
  name = nil,
  value = nil,
  expression = nil,
  path = nil,
  is_optional = nil,
}

function Filter:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Filter:from(name: string, options: table)
  options = options or Meta:table({})
  return Filter:new({
    name = name,
    value = options.value,
    expression = options.expression,
    path = options.path,
    is_optional = options.is_optional,
  })
end

-- function Filter:from_context(name: string, context_value: string)
--   return Filter:from(name, {
--     context_value = context_value or name
--   })
-- end

-- function Filter:from_request(name: string, request_value: string)
--   return Filter:from(name, {
--     request_value = request_value or name
--   })
-- end

function Filter:from_value(name: string, value: string)
  return Filter:from(name, {
    value = value
  })
end

function Filter:from_expression(name: string, expression: string)
  return Filter:from(name, {
    expression = expression
  })
end

function Filter:from_path(name: string, path: string)
  return Filter:from(name, {
    path = path
  })
end

function Filter:with_is_optional(is_optional: boolean)
  if is_optional == nil then
    is_optional = true
  end

  self.is_optional = is_optional
  return self
end

function Filter:unwrap_path()
  if self.path ~= nil then
    local array = Meta:array {}
    local segments = split.split(self.path, split.EXPR_DOT)
    for _, name in segments do
      local segment = {
        name = name,
        snake_name = name,
        camel_name = case.snakeToCamel(name),
        pascal_name = case.snakeToPascal(name),
        kebab_name = case.snakeToKebab(name),
      }
      array[#array + 1] = segment
    end
    return array
  end
  return nil
end

function Filter:unwrap()
  return {
    name = self.name,
    snake_name = name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    kebab_name = case.snakeToKebab(self.name),
    value = self.value,
    expression = self.expression,
    path = self:unwrap_path(),
    is_optional = self.is_optional,
  }
end

return Filter
