local Owner = {
  __type = 'Owner',
  claim = nil,
  column = nil,
}

function Owner:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Owner:from(claim: string, column: string)
  return Owner:new({
    claim = claim,
    column = column,
  })
end

function Owner:sub(column: string)
  return Owner:from('sub', column)
end

function Owner:unwrap()
  return {
    claim = self.claim,
    column = self.column,
  }
end

return Owner
