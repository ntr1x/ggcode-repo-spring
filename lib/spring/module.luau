local case = require('core/util/string/case')

local Project = require('spring/project')

local Module = {
  name = nil,
  parent = nil,
  project = nil,
  pom = nil,
  package = nil,
  module = nil,
  service = nil,
  database = nil,
  profiles = {},
}

function Module:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Module:from(parent: Project, name: string, artifact_id: string)
  local package_name = parent.pom.group_id .. '.' .. case.snakeToProp(name)
  return Module:new({
    name = name,
    parent = project,
    project = parent.project,
    pom = {
        artifact_id = name,
        parent = parent.pom
    },
    package = {
      name = package_name,
      path = case.propToPath(package_name)
    },
    module = {
        name = name,
        app_class = case.snakeToPascal(name)..'Application',
        suite_class = case.snakeToPascal(name)..'Suite',
    },
    service = {
      path = '/api/'..name
    },
    database = {},
    profiles = {},
  })
end

function Module:with_database(url: string, username: string, password: string)
  self.database = {
    url = url,
    username = username,
    password = password,
  }
  return self
end

function Module:with_profile(name: string, profile: table)
  self.profiles[name] = profile
  return self
end

return Module
