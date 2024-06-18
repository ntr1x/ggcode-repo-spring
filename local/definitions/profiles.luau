local Profile = require('spring/Profile')

local profiles = {}

profiles.profile_local_with_client = Profile
  :from('local')
  :with_port(8080)
  :with_app_openid_client({
    client_id = 'api',
    client_secret = '4Ggxc50xzu5j1qFk5rZ4OPHwvNFXLpNX'
  })

profiles.profile_local = Profile
  :from('local')
  :with_port(8080)
  :with_datasource('jdbc:postgresql://localhost:5432/app', 'app', 'app')

return profiles