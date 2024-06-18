local Exchange = require('spring/Exchange')
local Topic = require('spring/exchange/Topic')

local modules = require('definitions/modules')

local exchanges = {}

exchanges.exchange_service_events = Exchange
  :from(modules.service_events)
  :with_rules {
    Topic:from('public_customers'),
    Topic:from('public_category'),
    Topic:from('public_product'),
    Topic:from('public_dispatch'),
  }

exchanges.exchange_service_catalog = Exchange
  :from(modules.service_catalog)
  :with_rules {
    Topic:from('public_category'),
    Topic:from('public_product'),
  }

exchanges.exchange_service_payments = Exchange
  :from(modules.service_payments)
  :with_rules {
    Topic:from('public_order'),
    Topic:from('public_payment'),
  }

exchanges.exchange_service_profile = Exchange
  :from(modules.service_profile)
  :with_rules {
    Topic:from('public_customers'),
    Topic:from('verify_phone'),
    Topic:from('verify_email'),
    Topic:from('update_phone'),
    Topic:from('update_email'),
  }

exchanges.exchange_gateway_payments = exchanges.exchange_service_payments
  :clone()
  :with_module(modules.gateway_payments)

exchanges.exchange_gateway_profile = exchanges.exchange_service_profile
  :clone()
  :with_module(modules.gateway_profile)

exchanges.exchange_gateway_events = exchanges.exchange_service_events
  :clone()
  :with_module(modules.gateway_events)

return exchanges
