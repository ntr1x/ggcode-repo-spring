local Assembly = require('spring/Assembly')

local modules = require('spring/definitions/modules')

local assemblies = {}

assemblies.assembly_web = Assembly:from(modules.assembly_web, {
  modules.service_catalog,
  modules.service_profile,
  modules.service_payments,
  modules.service_events,
  modules.service_security,
  modules.service_structure,
  modules.service_uploads,
  modules.shared_api,
  modules.gateway_events,
  modules.gateway_payments,
  modules.gateway_profile,
})

return assemblies
