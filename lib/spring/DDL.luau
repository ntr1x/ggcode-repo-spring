local Meta = require('core/Meta')
local Project = require('core/Project')
local Entity = require('spring/jpa/Entity')

local DDL = {
  __type = 'DDL',

  project = nil,
  entity = nil,
  base_name = nil,
  create_name = nil,
  drop_name = nil,
}

function DDL:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function DDL:from(project: Project, entity: Entity)
  return DDL:new({
    project = project,
    entity = entity,
  })
end

function DDL:with_base_name(base_name: string)
  self.base_name = base_name
  return self
end

function DDL:with_create_name(create_name: string)
  self.create_name = create_name
  return self
end

function DDL:with_drop_name(drop_name: string)
  self.drop_name = drop_name
  return self
end

function DDL:unwrap_directory()
  return {
    base_name = self.base_name,
    create_name = self.create_name,
    drop_name = self.drop_name,
  }
end

function DDL:unwrap()
  return {
    project = self.project:unwrap_project(),
    entity = self.entity:unwrap(),
    directory = self:unwrap_directory()
  }
end

return DDL
