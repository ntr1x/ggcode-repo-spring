local Profile = require('spring/Profile')

local profiles = {}

local server = Profile.Server:from(8080)

local datasource = Profile.Datasource:new({
  url = 'jdbc:postgresql://localhost:5432/app',
  username = 'app',
  password = 'app',
})

local openid_client = Profile.OpenIdClient:from_config({
  client_id = 'api',
  client_secret = '4Ggxc50xzu5j1qFk5rZ4OPHwvNFXLpNX'
})

local minio_client = Profile.MinioClient:from_config({
  endpoint = 'http://minio.local.example.com',
  access_key = 'y5LeRZ84J4SsenpaIxMl',
  secret_key = 'AZitoDkffcEYFYUmV4CGv1jr2fiXWIw4uSvdFlDu',
})

local firebase_config = {
  push = {
    ['config-file'] = 'classpath:firebase-service-account.json',
  }
}

local huawei_config = {
  push = {
    ['client-id'] = 111569649,
    ['client-secret'] = 'fd7c6891686f73fd66a7661b2bc971c04fa7f058b431eb0e35526da1549c2c76',
    ['token-url'] = 'https://oauth-login.cloud.huawei.com/oauth2/v3/token',
    ['api-url'] = 'https://push-api.cloud.huawei.com/v1/${app.huawei.client-id}/messages:send',
  }
}

profiles.profile_local_with_minio_client = Profile
  :from('local')
  :with_trace_sql()
  :with_rules {
    server,
    minio_client,
  }

profiles.profile_local_with_openid_client = Profile
  :from('local')
  :with_trace_sql()
  :with_rules {
    server,
    openid_client,
  }

profiles.profile_local = Profile
  :from('local')
  :with_trace_sql()
  :with_rules {
    server,
    datasource,
  }

profiles.profile_local_full = Profile
  :from('local')
  :with_trace_sql()
  :with_rules {
    server,
    datasource,
    openid_client,
    minio_client
      :copy()
      :with_bucket({ name = 'app-public-document' })
      :with_bucket({ name = 'app-public-image', content_type = 'image/', content_length = '10M' })
      :with_bucket({ name = 'app-product-image', content_type = 'image/', content_length = '10M' })
      ,
    Profile.Entry:from('firebase', firebase_config),
    Profile.Entry:from('huawei', huawei_config),
  }

return profiles
