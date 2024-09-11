local POM = require('spring/POM')

local projects = require('spring/definitions/projects')

local poms = {}

poms.pom = POM:from(projects.project, 'com.example', 'application', {
  "assembly_web",
  "common_api",
  "common_events",
  "common_jpa",
  "common_minio",
  "common_security",
  "common_web",
  "common_ws",
  "service_catalog",
  "service_events",
  "service_payments",
  "service_profile",
  "service_security",
  "service_structure",
  "service_uploads",
  "gateway_events",
  "gateway_payments",
  "gateway_profile",
  "shared_api",
})

return poms
