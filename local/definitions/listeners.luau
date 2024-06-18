local Listener = require('spring/exchange/Listener')

local modules = require('definitions/modules')

local listeners = {}

listeners.listener_gateway_events_dispatch = Listener:from(modules.gateway_events, "public_dispatch")
listeners.listener_gateway_payments_payment = Listener:from(modules.gateway_payments, "public_payment")
listeners.listener_gateway_payments_order = Listener:from(modules.gateway_payments, "public_order")
listeners.listener_gateway_profile_customer = Listener:from(modules.gateway_profile, "public_customer")
listeners.listener_gateway_profile_verify_phone = Listener:from(modules.gateway_profile, "verify_phone")
listeners.listener_gateway_profile_verify_email = Listener:from(modules.gateway_profile, "verify_email")
listeners.listener_service_profile_update_phone = Listener:from(modules.service_profile, "update_phone")
listeners.listener_service_profile_update_email = Listener:from(modules.service_profile, "update_email")

listeners.listener_service_events_event = Listener
  :from(modules.service_events, "public_event")
  :with_topic_pattern("public_.*")
  :with_batch_flag(true)

return listeners