local Meta = require('core/Meta')
local POM = require('spring/POM')

local Docker = {
  pom = nil,
  name = nil,
  filename = nil,
  namespace = nil,
  images = nil,
}

function Docker:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Docker:from(pom: POM, name: string, images: table)
  return Docker:new({
    pom = pom,
    name = name,
    namespace = name,
    images = images or Meta:array {},
  })
end

function Docker:with_namespace(namespace: string)
  self.namespace = namespace
  return self
end

function Docker:with_filename(filename: string)
  self.filename = filename
  return self
end

function Docker:with_image(image: string)
  self.images[#self.images + 1] = image
  return self
end

function Docker:unwrap()
  return {
    project = self.pom.project:unwrap_project(),
    docker = {
      name = self.name,
      filename = self.filename or 'Dockerfile',
      namespace = self.namespace,
      version = self.pom.version,
      modules = self.pom.modules,
      images = self.images
    }
  }
end

return Docker
