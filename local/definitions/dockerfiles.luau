local Docker = require('spring/docker/Docker')

local poms = require('definitions/poms')

local dockerfiles = {}

dockerfiles.docker = Docker
  :from(poms.pom)
  :with_image('assembly_web')

return dockerfiles
