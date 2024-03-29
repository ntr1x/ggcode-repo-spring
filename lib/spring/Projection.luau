local Projection = {
  __type = 'Projection',
  name = nil,
  resources = {}
}

function Projection:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Projection:from(name: string)
  return Projection:new({
    name = name,
    resources = {}
  })
end

function Projection:with_resource(resource)
  self.resources[#self.resources + 1] = resource
  return self
end

function Projection:unwrap()
  return {
    name = self.name,
  }
end

return Projection
