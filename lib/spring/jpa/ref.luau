local object = require('core/util/object')
local split = require('core/util/string/split')
local case = require('core/util/string/case')

local function one(name: string)
  return function (options: table)
    options = options or {}
    assert(options.column ~= nil)
    assert(options.unit ~= nil)
    local template = object.spread({
      type = 'ref',
      unit = options.unit,
      column = options.column,
      name = name,
      camel_name = case.snakeToCamel(name),
      kebab_name = case.snakeToKebab(name),
      pascal_name = case.snakeToPascal(name),
    })
    return function (overrides)
      return template(overrides or {})
    end
  end
end

local function many(name: string)
  -- return function (source_column, target_column)
  --   local template = object.spread({ type = 'ref:many', name = name, source = nil, java_type = nil })
  --   return function (overrides: table)
  --     return template(overrides or {})
  --   end
  -- end
end

return {
  one = one,
  many = many,
}
