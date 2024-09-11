local Meta = require('core/Meta')
local Bucket = require('spring/profile/Bucket')
local Wrapper = require('core/Wrapper')
local ARRAY = require('core/util/array')

local MinioClient = {
  __type = 'MinioClient',
  endpoint = nil,
  access_key = nil,
  secret_key = nil,
  buckets = nil,
}

function MinioClient:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function MinioClient:from_config(config: table)
  return MinioClient:new({
    endpoint = config.endpoint,
    access_key = config.access_key,
    secret_key = config.secret_key,
    buckets = Meta:array {},
  })
end

function MinioClient:with_bucket(bucket: table)
  self.buckets[#self.buckets + 1] = Bucket:new(bucket)
  return self
end

function MinioClient:copy()
  return MinioClient:new({
    endpoint = self.endpoint,
    access_key = self.access_key,
    secret_key = self.secret_key,
    buckets = ARRAY.copy(self.buckets),
  })
end

function MinioClient:unwrap()
  return {
    client = {
      ["endpoint"] = self.endpoint,
      ["access-key"] = self.access_key,
      ["secret-key"] = self.secret_key,
    },
    buckets = #self.buckets > 0 and Wrapper:unwrap_array(self.buckets) or nil,
  }
end

return MinioClient
