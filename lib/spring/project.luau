local Project = {
  project = nil,
  pom = nil,
}

function Project:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Project:from(name: string, group_id: string, artifact_id: string, modules: table)
  return Project:new({
    project = { name = name },
    pom = {
      group_id = group_id,
      artifact_id = artifact_id,
      modules = modules or {}
    }
  })
end

function Project:with_module(module: string)
  self.pom.modules[#self.pom.modules + 1] = module
  return self
end

return Project
