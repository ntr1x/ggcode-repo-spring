local Role = {
  __type = 'Role',
  expression = nil,
}

function Role:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Role:from(expression: string)
  return Role:new({
    expression = expression,
  })
end

function Role:unwrap()
  return {
    expression = self.expression,
  }
end

return Role
