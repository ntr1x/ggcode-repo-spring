local Action = {
  __type = 'Action',
  method = nil,
  role = nil,
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
  })
end


function Action:create(role: string)
  return Action:from('create', role)
end

function Action:remove(role: string)
  return Action:from('remove', role)
end

function Action:update(role: string)
  return Action:from('update', role)
end

function Action:get(role: string)
  return Action:from('get', role)
end

function Action:list(role: string)
  return Action:from('list', role)
end

function Action:unwrap()
  return {
    method = self.method,
    role = self.role,
  }
end

return Action
