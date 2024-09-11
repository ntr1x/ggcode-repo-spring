local Meta = require('core/Meta')
local case = require('core/util/string/case')

local Override = {
  __type = 'Override',
  name = nil,
  expression = nil,
  context_value = nil,
  value = nil,
  is_hidden = false,
}

function Override:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Override:from(name: string, options: table)
  options = options or Meta:table({})
  return Override:new({
    name = name,
    expression = options.expression,
    context_value = options.context_value,
    value = options.value,
    is_hidden = options.is_hidden,
  })
end

function Override:from_context(name: string, context_value: string)
  return Override:from(name, {
    is_hidden = true,
    context_value = context_value or name
  })
end

function Override:from_value(name: string, value: string)
  return Override:from(name, {
    is_hidden = true,
    value = value
  })
end

function Override:from_expression(name: string, expression: string)
  return Override:from(name, {
    is_hidden = true,
    expression = expression
  })
end

function Override:from_hidden(name: string)
  return Override:from(name, {
    is_hidden = true,
  })
end

function Override:with_expression(expression: string)
  self.expression = expression
  return self
end

function Override:with_context_value(context_value: string)
  self.context_value = context_value
  return self
end

function Override:with_value(value: string)
  self.value = value
  return self
end

function Override:with_hidden()
  self.is_hidden = true
  return self
end

function Override:unwrap_context_value()
  if self.context_value == nil then
    return nil
  end

  local name = self.context_value

  return {
    name = name,
    snake_name = name,
    camel_name = case.snakeToCamel(name),
    pascal_name = case.snakeToPascal(name),
    kebab_name = case.snakeToKebab(name),
  }
end

function Override:unwrap()
  return {
    name = self.name,
    value = self.value,
    context_value = self:unwrap_context_value(),
    expression = self.expression,
    is_hidden = self.is_hidden,
  }
end

return Override
