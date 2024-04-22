local Meta = require('core/Meta')
local Filter = require('spring/security/action/Filter')
local Override = require('spring/resource/Override')
local Role = require('spring/security/action/Role')

local Action = {
  __type = 'Action',

  Filter = Filter,
  Override = Override,
  Role = Role,

  method = nil,
  role = nil,
  overrides = nil,
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

function Action:replace(role: string)
  return Action:from('replace', role)
end

function Action:get(role: string)
  return Action:from('get', role)
end

function Action:select(role: string)
  return Action:from('select', role)
end

function Action:with_rules(children: table)
  children = children or Meta:array({})

  for _, child in children do
    if child.__type == 'Role' then
      self.role = child.expression
    elseif child.__type == 'Override' then
      self.overrides[#self.overrides + 1] = child
    end
  end

  return self
end

function Action:unwrap()
  return {
    method = self.method,
    role = self.role,
  }
end

return Action
