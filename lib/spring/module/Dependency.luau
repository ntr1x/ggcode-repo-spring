local Meta = require('core/Meta')
local case = require('core/util/string/case')
local split = require('core/util/string/split')

local Dependency = {
  __type = 'Dependency',
  group_id = nil,
  artifact_id = nil,
  version = nil,
}

function Dependency:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Dependency:from(group_id: string, artifact_id: string, version: string)
  return Dependency:new({
    group_id = group_id,
    artifact_id = artifact_id,
    version = version,
  })
end

function Dependency:unwrap()
  return {
    group_id = self.group_id,
    artifact_id = self.artifact_id,
    version = self.version,
  }
end

return Dependency
