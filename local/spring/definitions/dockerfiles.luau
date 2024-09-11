local Docker = require('spring/docker/Docker')

local poms = require('spring/definitions/poms')

local dockerfiles = {}

dockerfiles.docker = Docker
  :from(poms.pom)
  :with_image('assembly_web')
  :with_namespace('store')

return dockerfiles
