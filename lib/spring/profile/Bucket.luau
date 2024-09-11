local Bucket = {
  __type = 'Bucket',
  name = nil,
  content_type = nil,
  content_length = nil,
}

function Bucket:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Bucket:from(name: string, content_type: string, content_length: string)
  return Bucket:new({
    name = name,
    content_type = content_type,
    content_length = content_length,
  })
end

function Bucket:unwrap_upload_policy()
  if self.content_type ~= nil or self.content_length ~= nil then
    return {
      content_type = self.content_type,
      content_length = self.content_length,
    }
  end

  return nil
end

function Bucket:copy()
  return Bucket:new({
    name = self.name,
    content_type = self.content_type,
    content_length = self.content_length,
  })
end

function Bucket:unwrap()
  return {
    name = self.name,
    upload_policy = self:unwrap_upload_policy(),
  }
end

return Bucket
