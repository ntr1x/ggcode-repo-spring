local POM = require('spring/POM')

local projects = require('spring/definitions/projects')

local poms = {}

poms.pom = POM:from(projects.project, 'com.example', 'application', {
  "common_api",
  "common_jpa",
  "common_web",
  "common_ws",
  "common_events",
  "shared_api",
  "service_catalog",
  "service_profile",
  "service_events",
  "service_payments",
  "service_security",
  "service_structure",
  "gateway_events",
  "gateway_payments",
  "gateway_profile",
  "assembly_web",
})

return poms
