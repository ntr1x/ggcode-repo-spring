local Module = require('spring/Module')

local poms = require('spring/definitions/poms')
local profiles = require('spring/definitions/profiles')

local modules = {}

modules.assembly_web = Module
  :from(poms.pom, 'assembly', 'assembly_web')
  :with_profile('local', profiles.profile_local_full:copy():with_server_port(8080))

modules.shared_api = Module
  :from(poms.pom, 'lib', 'shared_api')
  :with_plugins {
    'common_events'
  }

modules.service_structure = Module
  :from(poms.pom, 'web', 'service_structure')
  :with_profile('local', profiles.profile_local:copy():with_server_port(8081))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events',
    'shared_api'
  }

modules.service_catalog = Module
  :from(poms.pom, 'web', 'service_catalog')
  :with_profile('local', profiles.profile_local:copy():with_server_port(8082))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events',
    'shared_api'
  }

modules.service_profile = Module
  :from(poms.pom, 'web', 'service_profile')
  :with_profile('local', profiles.profile_local:copy():with_server_port(8083))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events',
    'shared_api'
  }

modules.service_events = Module
  :from(poms.pom, 'web', 'service_events')
  :with_profile('local', profiles.profile_local:copy():with_server_port(8084))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_ws',
    'common_events',
    'shared_api'
  }

modules.service_payments = Module
  :from(poms.pom, 'web', 'service_payments')
  :with_profile('local', profiles.profile_local:copy():with_server_port(8085))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events',
    'shared_api'
  }

modules.service_security = Module
  :from(poms.pom, 'security', 'service_security')
  :with_profile('local', profiles.profile_local_with_openid_client:copy():with_server_port(8086))
  :with_plugins {
    'common_web',
    'common_events',
    'common_security',
    'shared_api'
  }

modules.service_uploads = Module
  :from(poms.pom, 'uploads', 'service_uploads')
  :with_profile('local', profiles.profile_local_with_minio_client:copy():with_server_port(8087))
  :with_plugins {
    'common_web',
    'common_events',
    'common_minio',
    'shared_api'
  }

modules.gateway_payments = Module
  :from(poms.pom, 'gateway', 'gateway_payments')
  :with_profile('local', profiles.profile_local:copy():with_server_port(8088))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events',
    'shared_api'
  }

modules.gateway_profile = Module
  :from(poms.pom, 'gateway', 'gateway_profile')
  :with_profile('local', profiles.profile_local:copy():with_server_port(8089))
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events',
    'shared_api'
  }

modules.gateway_events = Module
  :from(poms.pom, 'gateway', 'gateway_events')
  :with_profile('local', profiles.profile_local:copy():with_server_port(8090))
  :with_dependency('com.google.firebase', 'firebase-admin', '9.1.1')
  :with_plugins {
    'common_jpa',
    'common_web',
    'common_events',
    'shared_api'
  }

return modules