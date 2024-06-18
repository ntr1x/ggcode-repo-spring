local Assembly = require('spring/Assembly')

local modules = require('definitions/modules')

local assemblies = {}

assemblies.assembly_web = Assembly:from(modules.assembly_web, {
  modules.service_catalog,
  modules.service_profile,
  modules.service_payments,
  modules.service_events,
  modules.service_security,
  modules.gateway_events,
  modules.gateway_payments,
  modules.gateway_profile,
})

return assemblies
