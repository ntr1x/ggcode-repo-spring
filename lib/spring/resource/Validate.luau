local Meta = require('core/Meta')
local case = require('core/util/string/case')
local Arg = require('spring/validate/Arg')

local Validate = {
  __type = 'Validate',

  Arg = Arg,

  status_code = 400,
  message = 'Bad Request',
  predicate = nil,
  args = nil,
}

function Validate:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Validate:from(predicate: string, args: table)
  options = options or Meta:table({})
  return Validate:new({
    predicate = predicate,
    args = args or Meta:array({}),
  })
end

function Validate:with_status(status_code: number, message: string)
  self.status_code = status_code
  self.message = message
  return self
end

function Validate:with_status_code(status_code: number)
  self.status_code = status_code
  return self
end

function Validate:with_message(message: string)
  self.message = message
  return self
end

function Validate:with_rules(children: table)
  children = children or Meta:array({})

  for _, child in children do
    if child.__type == 'Arg' then
      self.args[#self.args + 1] = child
    end
  end

  return self
end

function Validate:equals(a_path: string, b_path: string)
  return Validate:from('equals'):with_rules {
    Arg:from_path(a_path),
    Arg:from_path(b_path),
  }
end

function Validate:not_null(path: string)
  return Validate:from('notNull'):with_rules {
    Arg:from_path(path),
  }
end

function Validate:is_true(path: string)
  return Validate:from('isTrue'):with_rules {
    Arg:from_path(path),
  }
end

function Validate:unwrap_args()
  local args = Meta:array {}
  for _, arg in self.args do
    args[#args + 1] = arg:unwrap()
  end
  return args
end

function Validate:unwrap()
  return {
    status_code = self.status_code,
    message = self.message,
    predicate = self.predicate,
    args = self:unwrap_args(),
  }
end

return Validate
