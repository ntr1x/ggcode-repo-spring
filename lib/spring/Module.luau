local Meta = require('core/Meta')
local case = require('core/util/string/case')
local Project = require('spring/Project')
local POM = require('spring/POM')

local Module = {
  parent = nil,
  name = nil,
  pom = nil,
  database = nil,
  profiles = nil,
  plugins = nil,
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
    profiles = Meta:array {},
    plugins = Meta:array {},
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

function Module:with_plugins(plugins: table)
  plugins = plugins or Meta:table {}
  for _, name in plugins do
    self.plugins[#self.plugins + 1] = name
  end
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

function Module:unwrap_profiles()
  local profiles = Meta:table {}
  for _, profile in self.profiles do
    profiles[profile.name] = profile:unwrap()
  end
  return profiles
end

function Module:unwrap()
  local parent_pom = self.parent:unwrap_pom()

  local pascal_name = case.snakeToPascal(self.name)
  local camel_name = case.snakeToCamel(self.name)

  return {
    project = self:unwrap_project(),
    pom = {
      artifact_id = self.name,
      parent = parent_pom
    },
    package = self:unwrap_package(),
    module = {
      name = self.name,
      pascal_name = pascal_name,
      camel_name = camel_name,
      app_class = pascal_name .. 'Application',
      suite_class = pascal_name .. 'Suite',
    },
    service = {
      path = '/api/' .. self.name
    },
    database = self.database,
    profiles = self:unwrap_profiles(),
    plugins = self.plugins
  }
end

return Module
