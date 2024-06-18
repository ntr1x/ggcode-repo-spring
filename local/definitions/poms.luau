local POM = require('spring/POM')

local projects = require('definitions/projects')

local poms = {}

poms.pom = POM:from(projects.project, 'com.example', 'application', {
  "common_api",
  "common_jpa",
  "common_web",
  "common_ws",
  "common_events",
  "service_catalog",
  "service_profile",
  "service_events",
  "service_payments",
  "service_security",
  "gateway_events",
  "gateway_payments",
  "gateway_profile",
  "assembly_web",
})

return poms