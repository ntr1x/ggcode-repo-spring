local OpenIdClient = {
  __type = 'OpenIdClient',
  issuer_uri = nil,
  client_id = nil,
  client_secret = nil,
  redirect_uri = nil
}

function OpenIdClient:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function OpenIdClient:from_config(config: table)
  return OpenIdClient:new({
    client_id = config.client_id,
    client_secret = config.client_secret,
    issuer_uri = config.issuer_uri,
    redirect_uri = config.redirect_uri,
  })
end

function OpenIdClient:copy()
  return OpenIdClient:new({
    client_id = self.client_id,
    client_secret = self.client_secret,
    issuer_uri = self.issuer_uri,
    redirect_uri = self.redirect_uri,
  })
end

function OpenIdClient:unwrap()
  return {
    client = {
      ["issuer-uri"] = self.issuer_uri,
      ["client-id"] = self.client_id,
      ["client-secret"] = self.client_secret,
      ["redirect-uri"] = self.redirect_uri
    }
  }
end

return OpenIdClient
