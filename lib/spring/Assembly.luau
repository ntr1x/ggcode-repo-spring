local Meta = require('core/Meta')
local case = require('core/util/string/case')
local Project = require('spring/Project')
local POM = require('spring/POM')

local Assembly = {
  module = nil,
  nested_modules = nil,
}

function Assembly:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Assembly:from(parent: Module, nested_modules: table)
  return Assembly:new({
    module = parent,
    nested_modules = nested_modules or Meta:array {},
  })
end

function Assembly:with_nested_module(nested_module: Module)
  for _, m in nested_modules do
    self.nested_modules[#self.nested_modules + 1] = nested_module
  end
end

function Assembly:with_nested_modules(nested_modules: table)
  nested_modules = nested_modules or Meta:array {}
  for _, m in nested_modules do
    self.nested_modules[#self.nested_modules + 1] = m
  end
  return self
end

function Assembly:unwrap_nested_modules()
  local nested_modules = Meta:array {}

  for _, m in self.nested_modules do
    nested_modules[#nested_modules + 1] = m:unwrap()
  end

  return nested_modules
end

function Assembly:unwrap()
  local result = self.module:unwrap()
  result.nested_modules = self:unwrap_nested_modules()
  return result
end

return Assembly
