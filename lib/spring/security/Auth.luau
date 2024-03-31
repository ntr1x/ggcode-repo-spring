local case = require('core/util/string/case')

local Auth = {
  __type = 'Auth',
  claim = nil,
  name = nil,
  column = nil,
  java_type = 'java.lang.String',
}

function Auth:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Auth:subject(name: string, column: string)
  return Auth:new({
    name = name,
    claim = 'sub',
    column = column or name,
    java_type = 'java.util.UUID',
  })
end

function Auth:string_claim(name: string, claim: string, column: string)
  return Auth:new({
    name = name,
    claim = claim,
    column = column or name,
    java_type = 'java.lang.String',
  })
end

function Auth:with_claim(claim: string)
  self.claim = claim
  return self
end

function Auth:with_name(name: string)
  self.name = name
  return self
end

function Auth:with_column(column: string)
  self.column = column
  return self
end

function Auth:with_java_type(java_type: string)
  self.java_type = java_type
  return self
end

function Auth:unwrap()
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    claim = self.claim,
    java_type = self.java_type,
    column = {
      name = self.column,
      snake_name = self.column,
      camel_name = case.snakeToCamel(self.column),
      pascal_name = case.snakeToPascal(self.column),
    }
  }
end

return Auth
