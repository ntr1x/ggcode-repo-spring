local POM = require('spring/POM')

local Project = {
  __type = 'Project',
  name = nil,
  pom = nil,
  modules = {}
}

function Project:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Project:from(name: string, pom: POM)
  assert(name ~= null)
  return Project:new({
    name = name,
    pom = pom,
  })
end

function Project:with_pom(pom: POM)
  self.pom = pom
  return self
end

function Project:unwrap_pom()
  local pom = self.pom or POM:from(name, name)
  return pom:unwrap()
end

function Project:unwrap()
  return {
    project = { name = self.name },
    pom = self:unwrap_pom(),
  }
end

return Project
