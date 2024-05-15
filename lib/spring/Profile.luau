local Meta = require('core/Meta')
local OBJECT = require('core/util/object')

local Profile = {
  __type = 'Profile',
  name = nil,
  config = nil,
}

function Profile:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Profile:from(name: string, config: table)
  assert(name ~= nil)
  return Profile:new({
    name = name,
    config = config or Meta:table {}
  })
end

function Profile:copy()
  return Profile:new(OBJECT.deep_copy({
    name = self.name,
    config = self.config,
  }))
end

function Profile:with_datasource(url: string, username: string, password: string)
  self.config.spring = self.config.spring or Meta:table {}

  self.config.spring.datasource = {
    url = url,
    username = username,
    password = password,
  }
  return self
end

function Profile:with_app_openid_client(client: table)
  self.config.app = self.config.app or Meta:table {}
  self.config.app.openid = self.config.app.openid or Meta:table {}

  self.config.app.openid.client = {
    ["issuer-uri"] = client.issuer_uri,
    ["client-id"] = client.client_id,
    ["client-secret"] = client.client_secret,
    ["redirect-uri"] = client.redirect_uri
  }

  return self
end

function Profile:with_port(port: number)
  self.config.server = self.config.server or Meta:table {}
  self.config.server.port = port
  return self
end

function Profile:unwrap()
  return self.config
end

return Profile
