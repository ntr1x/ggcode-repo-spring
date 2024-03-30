local Projection = {
  __type = 'Projection',
  name = nil,
  actions = {},
  context = {},
}

function Projection:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Projection:from(name: string, children: table)
  return Projection
    :new({ name = name, actions = {}, context = {} })
    :with_rules(children)
end

function Projection:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Action' then
      self.actions[#self.actions + 1] = child
    elseif child.__type == 'Auth' then
      self.context[#self.context + 1] = child
    end
  end

  return self
end

function Projection:unwrap_actions()
  local actions = {}
  for i, action in self.actions do
    actions[i] = action:unwrap()
  end
  return actions
end

function Projection:unwrap_context()
  local context = {}
  for i, item in self.context do
    context[i] = item:unwrap()
  end
  return context
end

function Projection:unwrap()
  return {
    name = self.name,
    actions = self:unwrap_actions(),
    context = self:unwrap_context(),
  }
end

return Projection
