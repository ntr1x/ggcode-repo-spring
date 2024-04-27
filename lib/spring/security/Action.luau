local Meta = require('core/Meta')
local Override = require('spring/resource/Override')
local Role = require('spring/security/action/Role')
local Filter = require('spring/resource/Filter')

local Action = {
  __type = 'Action',

  Override = Override,
  Role = Role,
  Filter = Filter,

  method = nil,
  role = nil,
  route = nil,
  overrides = nil,
  filters = nil,
}

function Action:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Action:from(method: string, role: string)
  return Action:new({
    method = method,
    role = role,
    overrides = Meta:array {},
    filters = Meta:array {},
  })
end


function Action:create(role: string)
  return Action:from('create', role)
end

function Action:remove(role: string)
  return Action:from('remove', role)
end

function Action:delete(role: string)
  return Action:from('delete', role)
end

function Action:update(role: string)
  return Action:from('update', role)
end

function Action:upsert(role: string)
  return Action:from('upsert', role)
end

function Action:replace(role: string)
  return Action:from('replace', role)
end

function Action:get(role: string)
  return Action:from('get', role)
end

function Action:select(role: string)
  return Action:from('select', role)
end

function Action:find(role: string)
  return Action:from('find', role)
end

function Action:with_route(route: string)
  self.route = route
  return self
end

function Action:with_rules(children: table)
  children = children or Meta:array({})

  for _, child in children do
    if child.__type == 'Role' then
      self.role = child.expression
    elseif child.__type == 'Override' then
      self.overrides[#self.overrides + 1] = child
    elseif child.__type == 'Filter' then
      self.filters[#self.filters + 1] = child
    end
  end

  return self
end

function Action:unwrap()
  return {
    method = self.method,
    role = self.role,
    route = self.route,
  }
end

return Action
