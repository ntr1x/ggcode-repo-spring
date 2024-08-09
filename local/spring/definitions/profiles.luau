local Profile = require('spring/Profile')

local profiles = {}

local datasource = {
  url = 'jdbc:postgresql://localhost:5432/app',
  username = 'app',
  password = 'app',
}

local openid_client = {
  client_id = 'api',
  client_secret = '4Ggxc50xzu5j1qFk5rZ4OPHwvNFXLpNX'
}

local minio_client = {
  endpoint = 'http://minio.local.example.com',
  access_key = 'y5LeRZ84J4SsenpaIxMl',
  secret_key = 'AZitoDkffcEYFYUmV4CGv1jr2fiXWIw4uSvdFlDu'
}

profiles.profile_local_with_minio_client = Profile
  :from('local')
  :with_port(8080)
  :with_app_minio_client(minio_client)
  :with_sql_trace()

profiles.profile_local_with_openid_client = Profile
  :from('local')
  :with_port(8080)
  :with_app_openid_client(openid_client)
  :with_sql_trace()

profiles.profile_local = Profile
  :from('local')
  :with_port(8080)
  :with_datasource(datasource)
  :with_sql_trace()

profiles.profile_local_full = Profile
  :from('local')
  :with_port(8080)
  :with_datasource(datasource)
  :with_app_minio_client(minio_client)
  :with_app_openid_client(openid_client)
  :with_sql_trace()

return profiles
