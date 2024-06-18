local DDL = require('spring/DDL')

local projects = require('definitions/projects')
local units = require('definitions/units')

local statements = {}

-- Profile

statements.ddl_profile_customer = DDL:from(projects.project_ddl, units.unit_profile_customer.entity)
statements.ddl_profile_customer_verify_email = DDL:from(projects.project_ddl, units.unit_profile_customer_verify_email.entity)
statements.ddl_profile_customer_verify_phone = DDL:from(projects.project_ddl, units.unit_profile_customer_verify_phone.entity)
statements.ddl_profile_agent = DDL:from(projects.project_ddl, units.unit_profile_agent.entity)
statements.ddl_profile_customer_bonus = DDL:from(projects.project_ddl, units.unit_profile_customer_bonus.entity)

-- Events

statements.ddl_events_event = DDL:from(projects.project_ddl, units.unit_events_event.entity)
statements.ddl_events_event_topic_info = DDL:from(projects.project_ddl, units.unit_events_event_topic_info.entity)
statements.ddl_events_event_source_info = DDL:from(projects.project_ddl, units.unit_events_event_source_info.entity)
statements.ddl_events_event_type_info = DDL:from(projects.project_ddl, units.unit_events_event_type_info.entity)
statements.ddl_events_subscription = DDL:from(projects.project_ddl, units.unit_events_subscription.entity)
statements.ddl_events_subscription_type = DDL:from(projects.project_ddl, units.unit_events_subscription_type.entity)
statements.ddl_events_dispatch = DDL:from(projects.project_ddl, units.unit_events_dispatch.entity)
statements.ddl_events_dispatch_type = DDL:from(projects.project_ddl, units.unit_events_dispatch_type.entity)
statements.ddl_events_dispatch_status = DDL:from(projects.project_ddl, units.unit_events_dispatch_status.entity)

-- Catalog

statements.ddl_catalog_image_type = DDL:from(projects.project_ddl, units.unit_catalog_image_type.entity)
statements.ddl_catalog_attachment_type = DDL:from(projects.project_ddl, units.unit_catalog_attachment_type.entity)
statements.ddl_catalog_source_type = DDL:from(projects.project_ddl, units.unit_catalog_source_type.entity)
statements.ddl_catalog_region = DDL:from(projects.project_ddl, units.unit_catalog_region.entity)
statements.ddl_catalog_shop = DDL:from(projects.project_ddl, units.unit_catalog_shop.entity)
statements.ddl_catalog_category = DDL:from(projects.project_ddl, units.unit_catalog_category.entity)
statements.ddl_catalog_product = DDL:from(projects.project_ddl, units.unit_catalog_product.entity)
statements.ddl_catalog_product_image = DDL:from(projects.project_ddl, units.unit_catalog_product_image.entity)
statements.ddl_catalog_product_attachment = DDL:from(projects.project_ddl, units.unit_catalog_product_attachment.entity)
statements.ddl_catalog_item = DDL:from(projects.project_ddl, units.unit_catalog_item.entity)
statements.ddl_catalog_promotion = DDL:from(projects.project_ddl, units.unit_catalog_promotion.entity)
statements.ddl_catalog_promotion_type = DDL:from(projects.project_ddl, units.unit_catalog_promotion_type.entity)
statements.ddl_catalog_promotion_target = DDL:from(projects.project_ddl, units.unit_catalog_promotion_target.entity)
statements.ddl_catalog_promotion_image = DDL:from(projects.project_ddl, units.unit_catalog_promotion_image.entity)

-- Payments

statements.ddl_payments_favorite = DDL:from(projects.project_ddl, units.unit_payments_favorite.entity)
statements.ddl_payments_basket = DDL:from(projects.project_ddl, units.unit_payments_basket.entity)
statements.ddl_payments_basket_entry = DDL:from(projects.project_ddl, units.unit_payments_basket_entry.entity)
statements.ddl_payments_order_status = DDL:from(projects.project_ddl, units.unit_payments_order_status.entity)
statements.ddl_payments_order_type = DDL:from(projects.project_ddl, units.unit_payments_order_type.entity)
statements.ddl_payments_order = DDL:from(projects.project_ddl, units.unit_payments_order.entity)
statements.ddl_payments_order_entry = DDL:from(projects.project_ddl, units.unit_payments_order_entry.entity)
statements.ddl_payments_order_discount = DDL:from(projects.project_ddl, units.unit_payments_order_discount.entity)
statements.ddl_payments_payment_status = DDL:from(projects.project_ddl, units.unit_payments_payment_status.entity)
statements.ddl_payments_payment_type = DDL:from(projects.project_ddl, units.unit_payments_payment_type.entity)
statements.ddl_payments_payment = DDL:from(projects.project_ddl, units.unit_payments_payment.entity)

return statements