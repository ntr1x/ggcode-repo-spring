local ggcode = require('core/ggcode')

local projects = require('definitions/projects')
local poms = require('definitions/poms')
local profiles = require('definitions/profiles')
local modules = require('definitions/modules')
local dockerfiles = require('definitions/dockerfiles')
local units = require('definitions/units')
local exchanges = require('definitions/exchanges')
local projections = require('definitions/projections')
local assemblies = require('definitions/assemblies')
local listeners = require('definitions/listeners')
local resources = require('definitions/resources')
local statements = require('definitions/statements')

-- Generate Projects
for _, pom in poms do
  ggcode.generate "@/project" { target = '@app', variables = pom:unwrap() }
end

-- Generate Build Scripts
for _, docker in dockerfiles do
  ggcode.generate "@/docker" { target = '@app', variables = docker:unwrap() }
end

-- Generate Assemblies
for _, assembly in assemblies do
  ggcode.generate "@/assembly" { target = '@app', variables = assembly:unwrap() }
end

-- Generate Modules
for _, item in modules do
  if item.kind == 'web' then
    ggcode.generate "@/module_web" { target = '@app', variables = item:unwrap() }
  elseif item.kind == 'gateway' then
    ggcode.generate "@/module_web" { target = '@app', variables = item:unwrap() }
  elseif item.kind == 'security' then
    ggcode.generate "@/module_security" { target = '@app', variables = item:unwrap() }
  end
end

-- Generate Exchanges
for _, exchange in exchanges do
  ggcode.generate "@/exchange" { target = '@app', variables = exchange:unwrap() }
end

-- Generate Units
for _, unit in units do
  ggcode.generate "@/unit" { target = '@app', variables = unit:unwrap() }
end

-- Generate Resources
for _, resource in resources do
  ggcode.generate "@/resource" { target = '@app', variables = resource:unwrap() }
end

-- Generate Listeners
for _, listener in listeners do
  ggcode.generate "@/listener" { target = '@app', variables = listener:unwrap() }
end

-- Generate DDL Statements
for _, statement in statements do
  ggcode.generate "@/ddl" { target = '@ddl', variables = statement:unwrap() }
end
