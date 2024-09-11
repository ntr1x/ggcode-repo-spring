local Meta = require('core/Meta')
local ARRAY = require('core/util/array')
local OBJECT = require('core/util/object')
local Wrapper = require('core/Wrapper')
local Datasource = require('spring/profile/Datasource')
local Entry = require('spring/profile/Entry')
local MinioClient = require('spring/profile/MinioClient')
local OpenIdClient = require('spring/profile/OpenIdClient')
local Server = require('spring/profile/Server')

local Profile = {
  __type = 'Profile',

  Entry = Entry,
  Datasource = Datasource,
  MinioClient = MinioClient,
  OpenIdClient = OpenIdClient,
  Server = Server,

  name = nil,
  server = nil,
  spring_datasource = nil,
  app_minio_client = nil,
  app_openid_client = nil,
  app_entries = nil,
  trace_sql = false
}

function Profile:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Profile:from(name: string)
  assert(name ~= nil)
  return Profile:new({
    name = name,
    app_entries = Meta:table {},
  })
end

function Profile:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Entry' then
      self.app_entries[#self.app_entries + 1] = child
    elseif child.__type == 'Datasource' then
      self.spring_datasource = child
    elseif child.__type == 'MinioClient' then
      self.app_minio_client = child
    elseif child.__type == 'OpenIdClient' then
      self.app_openid_client = child
    elseif child.__type == 'Server' then
      self.server = child
    end
  end

  return self
end

function Profile:with_server_port(port: number)
  if self.server == nil then
    self.server = Server:from(port)
  else
    self.server:with_port(port)
  end
  return self
end

function Profile:with_spring_datasource(datasource: table)
  self.spring_datasource = Datasource:from_config(datasource)
  return self
end

function Profile:with_app_openid_client(openid_client: table)
  self.app_openid_client = OpenIdClient:from_config(openid_client)
  return self
end

function Profile:with_app_minio_client(minio_client: table)
  self.app_minio_client = MinioClient:from_config(minio_client)
  return self
end

function Profile:with_app_entry(name: string, config: table)
  self.app_entries[#self.app_entries + 1] = Entry:from(name, config)
  return self
end

function Profile:with_trace_sql()
  self.trace_sql = true
  return self
end
function Profile:unwrap_spring_jpa()
  if self.trace_sql == true then
    return {
      ['show-sql'] = true,
      properties = {
        hibernate = {
          format_sql = true
        }
      }
    }
  end
  return nil
end

function Profile:unwrap_spring()
  return {
    jpa = self:unwrap_spring_jpa(),
    datasource = self.spring_datasource and self.spring_datasource:unwrap() or nil,
  }
end

function Profile:unwrap_app()
  local config = {
    minio = self.app_minio_client ~= nil and self.app_minio_client:unwrap() or nil,
    openid = self.app_openid_client ~= nil and self.app_openid_client:unwrap() or nil,
  }
  for _, entry in self.app_entries do
    config[entry.name] = entry.config
  end
  return OBJECT.is_empty(config) ~= true and config or nil
end

function Profile:copy()
  return Profile:new({
    name = self.name,
    server = self.server ~= nil and self.server:copy() or nil,
    spring_datasource = self.spring_datasource ~= nil and self.spring_datasource:copy() or nil,
    app_minio_client = self.app_minio_client ~= nil and self.app_minio_client:copy() or nil,
    app_openid_client = self.app_openid_client ~= nil and self.app_openid_client:copy() or nil,
    app_entries = ARRAY.copy(self.app_entries),
    trace_sql = self.trace_sql,
  })
end

function Profile:unwrap()
  return {
    server = self.server:unwrap(),
    spring = self:unwrap_spring(),
    app = self:unwrap_app(),
  }
end

return Profile
