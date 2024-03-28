local Project = require('spring/Project')
local Module = require('spring/Module')
local Unit = require('spring/Unit')

local project = Project
  :from('example-application', 'org.example', 'application')
  :with_module('service_store')

assert('example-application' == project.project.name)
assert('org.example' == project.pom.group_id)
assert('application' == project.pom.artifact_id)
assert('table' == typeof(project.pom.modules))

local module = Module
  :from(project, 'service_store')

assert('service_store' == module.pom.artifact_id)
assert('ServiceStoreApplication' == module.module.app_class)
assert('ServiceStoreSuite' == module.module.suite_class)
assert('org.example.service.store' == module.package.name)
assert('org/example/service/store' == module.package.path)

local unit = Unit
  :from(module, 'store_item')

assert('store_item', unit.snake_name)
assert('storeItem', unit.camel_name)
assert('StoreItem', unit.pascal_name)
assert('store-item', unit.kebab_name)
