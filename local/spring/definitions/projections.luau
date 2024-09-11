local Projection = require('spring/Projection')
local Action = require('spring/security/Action')
local Auth = require('spring/security/Auth')

local units = require('spring/definitions/units')

local projections = {}

projections.projection_system = Projection
  :from("system")
  :with_rules {
    Action:get "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:select "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:create("hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')"):with_rules {
      Action.Override:from_value("id", "generatorService.randomUUID()");
    };
    Action:remove "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:delete "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:update "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:replace "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
  }

projections.projection_system_named_dictionary = Projection
  :from("system")
  :with_rules {
    Action:get "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:select "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:create "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:remove "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:delete "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:update "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:replace "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
  }

projections.projection_system_with_sequence = Projection
  :from("system")
  :with_rules {
    Action:get "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:select "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:create("hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')"):with_rules {
      Action.Override:from_value("id", "null");
    };
    Action:remove "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:delete "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:update "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
    Action:replace "hasAnyAuthority('realm:developer', 'realm:admin', 'realm:support')";
  }

projections.projection_anonymous = Projection
  :from("anonymous")
  :with_rules {
    Action:get '';
    Action:select '';
  }

projections.projection_profile = Projection
  :from("profile")
  :with_rules {
    Auth:subject "customer_id";
    Projection.Filter:from_path('customer_id', 'context.customer_id');
    Projection.Override:from_context "customer_id";
    Action:get "isAuthenticated()";
    Action:select "isAuthenticated()";
    Action:create("isAuthenticated()"):with_rules {
      Action.Override:from_value("id", "generatorService.randomUUID()");
    };
    Action:remove("isAuthenticated()"):with_rules {
      Action.Validate:equals('entity.customer_id', 'context.customer_id'),
    };
    Action:delete "isAuthenticated()";
    Action:update "isAuthenticated()";
    Action:replace("isAuthenticated()"):with_rules {
      Action.Validate:equals('entity.customer_id', 'context.customer_id'),
    };
  }

projections.projection_profile_basket = Projection
  :from("profile")
  :with_rules {
    Auth:subject "customer_id";
    -- Projection.Filter:from_path('customer_id', "context.customer_id");
    Projection.Filter:from_path('basket_id', "basket.id");
    Projection.Override:from_context "customer_id";
    Action:get("isAuthenticated()"):with_rules {
      Action.Validate:equals('entity.basket.customer_id', 'context.customer_id'),
    };
    Action:select("isAuthenticated()"):with_rules {
      Action.Fetch:by_path(units.unit_payments_basket, 'basket', 'request.basket_id'):with_is_optional(),
      Action.Validate:equals('basket.customer_id', 'context.customer_id'),
    };
    Action:create("isAuthenticated()"):with_rules {
      Action.Fetch:by_path(units.unit_payments_basket, 'basket', 'request.basket_id'):with_is_optional(),
      Action.Validate:equals('basket.customer_id', 'context.customer_id'),
      Action.Override:from_value("id", "generatorService.randomUUID()");
    };
    Action:remove("isAuthenticated()"):with_rules {
      Action.Validate:equals('entity.basket.customer_id', 'context.customer_id'),
    };
    Action:delete "isAuthenticated()";
    Action:update("isAuthenticated()"):with_rules {
      Action.Fetch:by_path(units.unit_payments_basket, 'basket', 'request.basket_id'):with_is_optional(),
      Action.Validate:equals('basket.customer_id', 'context.customer_id'),
    },
    Action:replace("isAuthenticated()"):with_rules {
      Action.Fetch:by_path(units.unit_payments_basket, 'basket', 'request.basket_id'):with_is_optional(),
      Action.Validate:equals('basket.customer_id', 'context.customer_id'),
    };
  }

projections.projection_profile_attribute = Projection
  :from("profile")
  :with_rules {
    Auth:subject "customer_id";
    Action:upsert("isAuthenticated()"):with_route(''):with_rules {
      Projection.Override:from_context("id", "customer_id"):with_hidden();
      Projection.Override:from_hidden("email");
      Projection.Override:from_hidden("phone");
    };
    Action:find("isAuthenticated()"):with_route(''):with_rules {
      Projection.Override:from_context("id", "customer_id"):with_hidden();
      Projection.Override:from_hidden("email");
      Projection.Override:from_hidden("phone");
      Projection.Override:from_hidden("name");
      Projection.Override:from_hidden("surname");
      Projection.Override:from_hidden("patronymic");
    };
  }

projections.projection_profile_verify_phone = Projection
  :from("profile")
  :with_rules {
    Auth:subject "customer_id";
    Projection.Filter:from_path("customer_id", "context.customer_id");
    Projection.Override:from_context "customer_id";
    Action:get "isAuthenticated()";
    Action:select "isAuthenticated()";
    Action:create("isAuthenticated()"):with_rules {
      Action.Override:from_value("id", "generatorService.randomUUID()");
    };
    Action:update "isAuthenticated()";
    Action:delete "isAuthenticated()";
  }

projections.projection_profile_verify_email = Projection
  :from("profile")
  :with_rules {
    Auth:subject "customer_id";
    Projection.Filter:from_path("customer_id", "context.customer_id");
    Projection.Override:from_context "customer_id";
    Action:get "isAuthenticated()";
    Action:select "isAuthenticated()";
    Action:create("isAuthenticated()"):with_rules {
      Action.Override:from_value("id", "generatorService.randomUUID()");
    };
    Action:update "isAuthenticated()";
    Action:delete "isAuthenticated()";
  }

projections.projection_profile_payment = Projection
  :from("profile")
  :with_rules {
    -- User can see but cannot update his payments directly
    Auth:subject "customer_id";
    Projection.Filter:from_path("customer_id", "context.customer_id");
    Projection.Override:from_context "customer_id";
    Action:get "isAuthenticated()";
    Action:select "isAuthenticated()";
  }

projections.projection_profile_order = Projection
  :from("profile")
  :with_rules {
    -- User can submit an order and see order history
    Auth:subject "customer_id";
    Projection.Filter:from_path("customer_id", "context.customer_id");
    Projection.Override:from_context "customer_id";
    Action:get "isAuthenticated()";
    Action:select "isAuthenticated()";
    Action:create("isAuthenticated()"):with_rules {
      Action.Override:from_value("id", "generatorService.randomUUID()");
    };
  }

return projections