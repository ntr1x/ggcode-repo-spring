local case = require('core/util/string/case')

local Signal = {
  __type = 'Signal',
  action = nil,
  topic = nil,
  payload_el = nil,
  event_type = nil,
  condition_el = nil,
}

function Signal:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Signal:from(action: string, topic: string, payload_el: string, event_type: string)
  return Signal:new({
    action = action,
    topic = topic,
    payload_el = payload_el,
    event_type = event_type,
    condition_el = nil,
  })
end

function Signal:create(topic: string, payload_el: string, event_type: string)
  return Signal:from('create', topic, payload_el, event_type or 'created')
end

function Signal:update(topic: string, payload_el: string, event_type: string)
  return Signal:from('update', topic, payload_el, event_type or 'updated')
end

function Signal:remove(topic: string, payload_el: string, event_type: string)
  return Signal:from('remove', topic, payload_el, event_type or 'removed')
end

function Signal:replace(topic: string, payload_el: string, event_type: string)
  return Signal:from('replace', topic, payload_el, event_type or 'replaced')
end

function Signal:with_payload_el(payload_el: string)
  self.payload_el = payload_el
  return self
end

function Signal:with_condition_el(condition_el: string)
  self.condition_el = condition_el
  return self
end

function Signal:unwrap()
  return {
    action = self.action,
    topic = self.topic,
    payload_el = self.payload_el,
    event_type = self.event_type,
    condition_el = self.condition_el,
  }
end

return Signal
