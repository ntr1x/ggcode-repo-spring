local case = require('core/util/string/case')
local Project = require('spring/Project')
local POM = require('spring/POM')

local Module = {
  parent = nil,
  name = nil,
  pom = nil,
  database = nil,
  profiles = {},
}

function Module:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Module:from(parent: Project, name: string)
  return Module:new({
    parent = parent,
    name = name,
    database = nil,
    pom = nil,
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

function Module:with_pom(pom: POM)
  self.pom = pom
  return self
end

function Module:unwrap_project()
  return {
    name = self.parent.name
  }
end

function Module:unwrap_package()
  local parent_pom = self.parent:unwrap_pom()
  local package_name = parent_pom.group_id .. '.' .. case.snakeToProp(self.name)
  return {
    name = package_name,
    path = case.propToPath(package_name)
  }
end

function Module:unwrap()
  local parent_pom = self.parent:unwrap_pom()

  return {
    project = self:unwrap_project(),
    pom = {
      artifact_id = self.name,
      parent = parent_pom
    },
    package = self:unwrap_package(),
    module = {
      name = self.name,
      app_class = case.snakeToPascal(self.name)..'Application',
      suite_class = case.snakeToPascal(self.name)..'Suite',
    },
    service = {
      path = '/api/' .. self.name
    },
    database = self.database,
    profiles = self.profiles,
  }
end

return Module
