local POM = {
  __type = 'POM',
  group_id = nil,
  artifact_id = nil,
  version = '1.0-SNAPSHOT',
  parent = nil,
  modules = {},
}

function POM:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function POM:from(group_id: string, artifact_id: string, modules: table)
  return POM:new({
    group_id = group_id,
    artifact_id = artifact_id,
    parent = nil,
    modules = modules or {},
  })
end

function POM:with_group_id(group_id: string)
  self.group_id = group_id
  return self
end

function POM:with_artifact_id(artifact_id: string)
  self.artifact_id = artifact_id
  return self
end

function POM:with_version(version: string)
  self.version = version
  return self
end

function POM:with_parent(parent: POM)
  self.parent = parent
  return self
end

function POM:with_module(module: string)
  self.modules[#self.modules + 1] = module
  return self
end

function POM:unwrap()
  return {
    parent = self.parent and self.parent:unwrap(),
    group_id = self.group_id,
    artifact_id = self.artifact_id,
    version = self.version,
    modules = self.modules,
  }
end

return POM
