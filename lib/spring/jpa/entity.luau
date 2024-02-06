local case = require('core/util/string/case')

local function entity (table_name: string)
  local schema, name = table_name:match("([^.]+).([^.]+)")
  return function (children: table)

    local keys = {}
    local columns = {}
    local refs = {}

    for _, child in children do
      local item = if type(child) == 'function' then child() else child
      if item.type == 'pk' then
        keys[#keys + 1] = item
      elseif item.type == 'prop' then
        columns[#columns + 1] = item
      elseif item.type == 'ref' then
        refs[#refs + 1] = item
      end
    end

    local pk = (if #keys > 0 then keys[1] else nil)

    local res = {
      pk = pk,
      schema = schema,
      name = case.snakeToPascal(name),
      camel_name = case.snakeToCamel(name),
      pascal_name = case.snakeToPascal(name),
      snake_name = name,
      table = name,
      keys = keys,
      columns = columns,
      refs = refs,
    }

    return res
  end
end

return {
  entity = entity,
}
