local Resource = require('spring/Resource')

local projections = require('definitions/projections')
local units = require('definitions/units')

local resources = {}

-- System resources

resources.resource_system_profile_customer = Resource
    :from(projections.projection_system, units.unit_profile_customer)
    :with_title("Customers")
    :with_expanded_signals('public_customer')

resources.resource_system_profile_agent = Resource
    :from(projections.projection_system, units.unit_profile_agent)
    :with_title("Agents")
    :with_expanded_signals('public_agent')

resources.resource_system_catalog_source_type = Resource
    :from(projections.projection_system_with_sequence, units.unit_catalog_source_type)
    :with_title("Sources")

resources.resource_system_catalog_region = Resource
    :from(projections.projection_system, units.unit_catalog_region)
    :with_title("Regions")

resources.resource_system_catalog_shop = Resource
    :from(projections.projection_system, units.unit_catalog_shop)
    :with_title("Shops")

resources.resource_system_catalog_promotion = Resource
    :from(projections.projection_system, units.unit_catalog_promotion)
    :with_title("Promotions")

resources.resource_system_catalog_promotion_type = Resource
    :from(projections.projection_system_with_sequence, units.unit_catalog_promotion_type)
    :with_title("Dictionaries")

resources.resource_system_catalog_promotion_target = Resource
    :from(projections.projection_system, units.unit_catalog_promotion_target)
    :with_title("Promotion Targets")

resources.resource_system_catalog_image_type = Resource
    :from(projections.projection_system_with_sequence, units.unit_catalog_image_type)
    :with_title("Dictionaries")

resources.resource_system_catalog_attachment_type = Resource
    :from(projections.projection_system_with_sequence, units.unit_catalog_attachment_type)
    :with_title("Dictionaries")

resources.resource_system_payments_order_type = Resource
    :from(projections.projection_system_with_sequence, units.unit_payments_order_type)
    :with_title("Dictionaries")

resources.resource_system_payments_order_status = Resource
    :from(projections.projection_system_with_sequence, units.unit_payments_order_status)
    :with_title("Dictionaries")

resources.resource_system_payments_payment_type = Resource
    :from(projections.projection_system_with_sequence, units.unit_payments_payment_type)
    :with_title("Dictionaries")

resources.resource_system_payments_payment_status = Resource
    :from(projections.projection_system_with_sequence, units.unit_payments_payment_status)
    :with_title("Dictionaries")

resources.resource_system_catalog_product = Resource
    :from(projections.projection_system, units.unit_catalog_product)
    :with_title("Products")
    :with_expanded_signals('public_product')

resources.resource_system_catalog_item = Resource
    :from(projections.projection_system, units.unit_catalog_item)
    :with_title("Product Items")
    :with_expanded_signals('public_item')

resources.resource_system_catalog_category = Resource
    :from(projections.projection_system, units.unit_catalog_category)
    :with_title("Product Categories")
    :with_expanded_signals('public_category')

resources.resource_system_payments_order = Resource
    :from(projections.projection_system, units.unit_payments_order)
    :with_title("Orders")

resources.resource_system_payments_payment = Resource
    :from(projections.projection_system, units.unit_payments_payment)
    :with_title("Payments")
    :with_rules {
        Resource.Link:from_resource('order', resources.resource_system_payments_order)
    }

resources.resource_system_events_event = Resource
    :from(projections.projection_system, units.unit_events_event)
    :with_title("Events")

resources.resource_system_events_event_topic_info = Resource
    :from(projections.projection_system_named_dictionary, units.unit_events_event_topic_info)
    :with_title("Event Topics")

resources.resource_system_events_event_source_info = Resource
    :from(projections.projection_system_named_dictionary, units.unit_events_event_source_info)
    :with_title("Event Sources")

resources.resource_system_events_event_type_info = Resource
    :from(projections.projection_system_named_dictionary, units.unit_events_event_type_info)
    :with_title("Event Types")

resources.resource_system_events_subscription = Resource
    :from(projections.projection_system, units.unit_events_subscription)
    :with_title("Subscriptions")

resources.resource_system_events_subscription_type = Resource
    :from(projections.projection_system_with_sequence, units.unit_events_subscription_type)
    :with_title("Subscription Types")

resources.resource_system_events_dispatch = Resource
    :from(projections.projection_system, units.unit_events_dispatch)
    :with_title("Dispatches")
    :with_expanded_signals('public_dispatch')
    :with_rules {
        Resource.Link:from_resource('subscription', resources.resource_system_events_subscription)
    }

resources.resource_system_events_dispatch_type = Resource
    :from(projections.projection_system_with_sequence, units.unit_events_dispatch_type)
    :with_title("Dispatch Types")

resources.resource_system_events_dispatch_status = Resource
    :from(projections.projection_system_with_sequence, units.unit_events_dispatch_status)
    :with_title("Dispatch Statuses")

-- Profile resources

resources.resource_profile_payments_basket = Resource
    :from(projections.projection_profile, units.unit_payments_basket)
    :with_title("Basket")

resources.resource_profile_payments_basket_entry = Resource
    :from(projections.projection_profile_basket, units.unit_payments_basket_entry)
    :with_title("Basket")

resources.resource_profile_payments_favorite = Resource
    :from(projections.projection_profile, units.unit_payments_favorite)
    :with_title("Favorites")

resources.resource_profile_payments_order = Resource
    :from(projections.projection_profile_order, units.unit_payments_order)
    :with_title("Orders")

resources.resource_profile_payments_payment = Resource
    :from(projections.projection_profile_payment, units.unit_payments_payment)
    :with_title("Payments")

resources.resource_profile_profile_customer = Resource
    :from(projections.projection_profile_attribute, units.unit_profile_customer)
    :with_title("Customer Profile")
    :with_expanded_signals('public_customer')

resources.resource_profile_profile_customer_verify_phone = Resource
    :from(projections.projection_profile_verify_phone, units.unit_profile_customer_verify_phone)
    :with_title("Customer Profile")
    :with_rules({
        Resource.Signal:create('verify_phone', '#result.created');
        Resource.Signal:update('update_phone', '#result.updated');
        Resource.View:kafka({ "secret", "is_confirmed" });
        Resource.View:update({ "secret" });
        Resource.Request:create(units.unit_profile_customer_verify_phone):with_rules {
            Resource.Override:from_expression('secret', '@generatorService.randomInt(1000, 9999)');
            Resource.Override:from_value('is_confirmed', 'false');
        };
        Resource.Request:select(units.unit_profile_customer_verify_phone):with_rules {
            Resource.Override:from_hidden('secret');
        };
        Resource.Request:update(units.unit_profile_customer_verify_phone):with_rules {
            Resource.Validate:not_null('request.id'):with_message("Property 'id' is required'"),
            Resource.Validate:not_null('request.secret'):with_message("Property 'secret' is required'"),
            Resource.Override:from_hidden('phone'),
            Resource.Override:from_value('is_confirmed', 'true'):with_hidden();
            Resource.Filter:from_value('is_confirmed', 'false');
            Resource.Filter:from_path('secret', 'request.secret'):with_is_optional();
        };
    })

resources.resource_profile_profile_customer_verify_email = Resource
    :from(projections.projection_profile_verify_email, units.unit_profile_customer_verify_email)
    :with_title("Customer Profile")
    :with_rules({
        Resource.Signal:create('verify_email', '#result.created');
        Resource.Signal:update('update_email', '#result.updated');
        Resource.View:kafka({ "secret", "is_confirmed" });
        Resource.View:update({ "secret" });
        Resource.Request:create(units.unit_profile_customer_verify_email):with_rules {
            Resource.Override:from_expression('secret', "@generatorService.randomString(12)");
            Resource.Override:from_value('is_confirmed', 'false');
        };
        Resource.Request:select(units.unit_profile_customer_verify_email):with_rules {
            Resource.Override:from_hidden('secret');
        };
        Resource.Request:update(units.unit_profile_customer_verify_email):with_rules {
            Resource.Validate:not_null('request.id'):with_message("Property 'id' is required'"),
            Resource.Validate:not_null('request.secret'):with_message("Property 'secret' is required'"),
            Resource.Override:from_hidden('email'),
            Resource.Override:from_value('is_confirmed', 'true'):with_hidden();
            Resource.Filter:from_value('is_confirmed', 'false');
            Resource.Filter:from_path('secret', 'request.secret'):with_is_optional();
        };
    })

-- Publicly accessible resources

resources.resource_anonymous_catalog_item = Resource
    :from(projections.projection_anonymous, units.unit_catalog_item)
    :with_title("Public")

resources.resource_anonymous_catalog_product = Resource
    :from(projections.projection_anonymous, units.unit_catalog_product)
    :with_title("Public")

resources.resource_anonymous_catalog_category = Resource
    :from(projections.projection_anonymous, units.unit_catalog_category)
    :with_title("Public")

resources.resource_anonymous_catalog_promotion = Resource
    :from(projections.projection_anonymous, units.unit_catalog_promotion)
    :with_title("Public")

resources.resource_anonymous_catalog_region = Resource
    :from(projections.projection_anonymous, units.unit_catalog_region)
    :with_title("Public")

resources.resource_anonymous_catalog_shop = Resource
    :from(projections.projection_anonymous, units.unit_catalog_shop)
    :with_title("Public")

return resources