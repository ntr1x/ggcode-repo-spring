local case = require('core/util/string/case')

local Signal = {
  __type = 'Signal',
  action = nil,
  topic = nil,
  payloadEl = nil,
  event_type = nil,
}

function Signal:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Signal:from(action: string, topic: string, payloadEl: string, event_type: string)
  return Signal:new({
    action = action,
    topic = topic,
    payloadEl = payloadEl or '#result',
    event_type = event_type,
  })
end

function Signal:create(topic: string, payloadEl: string, event_type: string)
  return Signal:from('create', topic, payloadEl, event_type or 'created')
end

function Signal:update(topic: string, payloadEl: string, event_type: string)
  return Signal:from('update', topic, payloadEl, event_type or 'updated')
end

function Signal:remove(topic: string, payloadEl: string, event_type: string)
  return Signal:from('remove', topic, payloadEl, event_type or 'removed')
end

function Signal:replace(topic: string, payloadEl: string, event_type: string)
  return Signal:from('replace', topic, payloadEl, event_type or 'replaced')
end

function Signal:unwrap()
  return {
    action = self.action,
    topic = self.topic,
    payloadEl = self.payloadEl,
    event_type = self.event_type,
  }
end

return Signal
