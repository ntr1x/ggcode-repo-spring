local Module = require('spring/Module')

local poms = require('definitions/poms')
local profiles = require('definitions/profiles')

local modules = {}

modules.assembly_web = Module
  :from(poms.pom, 'assembly', 'assembly_web')
  :with_profile('local', profiles.profile_local:copy():with_port(8080))

modules.service_catalog = Module
  :from(poms.pom, 'web', 'service_catalog')
  :with_profile('local', profiles.profile_local:copy():with_port(8082))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events'
  }

modules.service_profile = Module
  :from(poms.pom, 'web', 'service_profile')
  :with_profile('local', profiles.profile_local:copy():with_port(8083))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events'
  }

modules.service_events = Module
  :from(poms.pom, 'web', 'service_events')
  :with_profile('local', profiles.profile_local:copy():with_port(8084))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events'
  }

modules.service_payments = Module
  :from(poms.pom, 'web', 'service_payments')
  :with_profile('local', profiles.profile_local:copy():with_port(8085))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events'
  }

modules.service_security = Module
  :from(poms.pom, 'web', 'service_security')
  :with_profile('local', profiles.profile_local_with_client:copy():with_port(8086))
  :with_plugins {
    'common_web',
    'common_events'
  }

modules.gateway_payments = Module
  :from(poms.pom, 'gateway', 'gateway_payments')
  :with_profile('local', profiles.profile_local:copy():with_port(8087))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events'
  }

modules.gateway_profile = Module
  :from(poms.pom, 'gateway', 'gateway_profile')
  :with_profile('local', profiles.profile_local:copy():with_port(8088))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events'
  }

modules.gateway_events = Module
  :from(poms.pom, 'gateway', 'gateway_events')
  :with_profile('local', profiles.profile_local:copy():with_port(8089))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events'
  }

return modules