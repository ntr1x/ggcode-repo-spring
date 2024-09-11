local Unit = require('spring/Unit')
local PK = require('spring/jpa/PK')
local Prop = require('spring/jpa/Prop')
local Ref = require('spring/jpa/Ref')
local Formula = require('spring/jpa/Formula')

local modules = require('spring/definitions/modules')

local units = {}

units.unit_catalog_source_type = Unit:from(modules.service_catalog, "public.source_type")
units.unit_catalog_region = Unit:from(modules.service_catalog, "public.region")
units.unit_catalog_shop = Unit:from(modules.service_catalog, "public.shop")
units.unit_catalog_category = Unit:from(modules.service_catalog, "public.category")
units.unit_catalog_product = Unit:from(modules.service_catalog, "public.product")
units.unit_catalog_product_image = Unit:from(modules.service_catalog, "public.product_image")
units.unit_catalog_product_attachment = Unit:from(modules.service_catalog, "public.product_attachment")
units.unit_catalog_image_type = Unit:from(modules.service_catalog, "public.image_type")
units.unit_catalog_attachment_type = Unit:from(modules.service_catalog, "public.attachment_type")
units.unit_catalog_item = Unit:from(modules.service_catalog, "public.item")
units.unit_catalog_promotion = Unit:from(modules.service_catalog, "public.promotion")
units.unit_catalog_promotion_type = Unit:from(modules.service_catalog, "public.promotion_type")
units.unit_catalog_promotion_target = Unit:from(modules.service_catalog, "public.promotion_target")
units.unit_catalog_promotion_image = Unit:from(modules.service_catalog, "public.promotion_image")

units.unit_catalog_source_type:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_catalog_region:with_columns {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_catalog_shop:with_columns {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:text 'description',
  Prop:text 'address',
  Prop:decimal 'lon',
  Prop:decimal 'lat',
  Prop:uuid 'region_id',
  Ref:one { name = 'region', column = 'region_id', unit = units.unit_catalog_region },
}

units.unit_catalog_category:with_columns {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_catalog_product:with_columns {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:text 'description',
  Prop:decimal 'price',
  Prop:text 'ean_13',
  Prop:uuid 'category_id',
  Ref:one { name = 'category', column = 'category_id', unit = units.unit_catalog_category },
  Ref:many { name = 'images', column = 'product_id', unit = units.unit_catalog_product_image },
  Ref:many { name = 'attachments', column = 'product_id', unit = units.unit_catalog_product_attachment },
}

units.unit_catalog_product_image:with_columns {
  PK:uuid 'id',
  Prop:text 'uri',
  Prop:text 'name',
  Prop:int 'type_id',
  Prop:uuid 'product_id',
  Prop:uuid 'original_id',
  Ref:one { name = 'type', column = 'type_id', unit = units.unit_catalog_image_type },
  Ref:one { name = 'product', column = 'product_id', unit = units.unit_catalog_product },
  Ref:one { name = 'original', column = 'original_id', unit = units.unit_catalog_product_image },
}

units.unit_catalog_product_attachment:with_columns {
  PK:uuid 'id',
  Prop:text 'uri',
  Prop:int 'size',
  Prop:int 'page_count',
  Prop:text 'name',
  Prop:int 'type_id',
  Prop:uuid 'product_id',
  Ref:one { name = 'type', column = 'type_id', unit = units.unit_catalog_attachment_type },
  Ref:one { name = 'product', column = 'product_id', unit = units.unit_catalog_product },
}

units.unit_catalog_item:with_columns {
  PK:uuid 'id',
  Prop:uuid 'product_id',
  Prop:uuid 'shop_id',
  Prop:text 'ean_13',
  Prop:text 'code_128',
  Ref:one { name = 'product', column = 'product_id', unit = units.unit_catalog_product },
  Ref:one { name = 'shop', column = 'shop_id', unit = units.unit_catalog_shop },
}

units.unit_catalog_promotion:with_columns {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:text 'description',
  Prop:int 'type_id',
  Prop:jsonb('config')
    :with_column_definition('jsonb')
    :with_user_type('io.hypersistence.utils.hibernate.type.json.JsonBinaryType')
    :with_lob(true),
  Ref:one { name = 'type', column = 'type_id', unit = units.unit_catalog_promotion_type },
  Ref:many { name = 'images', column = 'promotion_id', unit = units.unit_catalog_promotion_image },
}

units.unit_catalog_promotion_type:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_catalog_promotion_image:with_columns {
  PK:uuid 'id',
  Prop:text 'uri',
  Prop:text 'name',
  Prop:int 'type_id',
  Prop:uuid 'promotion_id',
  Prop:uuid 'original_id',
  Ref:one { name = 'type', column = 'type_id', unit = units.unit_catalog_image_type },
  Ref:one { name = 'promotion', column = 'promotion_id', unit = units.unit_catalog_promotion },
  Ref:one { name = 'original', column = 'original_id', unit = units.unit_catalog_promotion_image },
}

units.unit_catalog_image_type:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
  Prop:text 'format',
  Prop:int 'width',
  Prop:int 'height',
}

units.unit_catalog_attachment_type:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_catalog_promotion_target:with_columns {
  PK:uuid 'id',
  Prop:int 'source_type_id',
  Prop:uuid 'promotion_id',
  Prop:uuid 'category_id',
  Prop:uuid 'product_id',
  Prop:uuid 'region_id',
  Prop:uuid 'shop_id',
  Ref:one { name = 'source_type', column = 'source_type_id', unit = units.unit_catalog_source_type },
  Ref:one { name = 'promotion', column = 'promotion_id', unit = units.unit_catalog_promotion },
  Ref:one { name = 'category', column = 'category_id', unit = units.unit_catalog_category },
  Ref:one { name = 'product', column = 'product_id', unit = units.unit_catalog_product },
  Ref:one { name = 'region', column = 'region_id', unit = units.unit_catalog_region },
  Ref:one { name = 'shop', column = 'shop_id', unit = units.unit_catalog_shop },
}

units.unit_profile_customer = Unit:from(modules.service_profile, "public.customer")
units.unit_profile_customer_verify_phone = Unit:from(modules.service_profile, "public.customer_verify_phone")
units.unit_profile_customer_verify_email = Unit:from(modules.service_profile, "public.customer_verify_email")
units.unit_profile_customer_bonus = Unit:from(modules.service_profile, "public.customer_bonus")
units.unit_profile_agent = Unit:from(modules.service_profile, "public.agent")

units.unit_profile_customer:with_columns {
  PK:uuid 'id',
  Prop:text 'email',
  Prop:text 'phone',
  Prop:text 'name',
  Prop:text 'surname',
  Prop:text 'patronymic',
  Formula:text('full_name', "CONCAT_WS(' ', {alias}.name, {alias}.patronymic, {alias}.surname)"),
  Ref:many { name = 'agents', column = 'customer_id', unit = units.unit_profile_agent },
  Ref:many { name = 'phones', column = 'customer_id', unit = units.unit_profile_customer_verify_phone },
  Ref:many { name = 'emails', column = 'customer_id', unit = units.unit_profile_customer_verify_email },
  Ref:many { name = 'bonuses', column = 'customer_id', unit = units.unit_profile_customer_bonus },
}

units.unit_profile_customer_bonus:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:uuid 'order_discount_id',
  Prop:decimal 'bonus',
  Prop:datetime 'created_at',
  Prop:datetime 'updated_at',
  Ref:one { name = 'customer', column = 'customer_id', unit = units.unit_profile_customer },
}

units.unit_profile_agent:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:text 'kind',
  Prop:text 'title',
  Prop:text 'inn',
  Prop:text 'kpp',
  Prop:text 'bic',
  Prop:text 'bank',
  Prop:text 'okved',
  Prop:text 'address',
  Prop:text 'phone',
  Prop:text 'email',
  Prop:text 'registration_address',
  Ref:one { name = 'customer', column = 'customer_id', unit = units.unit_profile_customer },
}

units.unit_profile_customer_verify_phone:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:text 'phone',
  Prop:int 'secret',
  Prop:boolean 'is_confirmed',
  Ref:one { name = 'customer', column = 'customer_id', unit = units.unit_profile_customer },
}

units.unit_profile_customer_verify_email:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:text 'email',
  Prop:text 'secret',
  Prop:boolean 'is_confirmed',
  Ref:one { name = 'customer', column = 'customer_id', unit = units.unit_profile_customer },
}

units.unit_events_event = Unit:from(modules.service_events, "public.event")
units.unit_events_event_topic_info = Unit:from(modules.service_events, "public.event_topic_info")
units.unit_events_event_source_info = Unit:from(modules.service_events, "public.event_source_info")
units.unit_events_event_type_info = Unit:from(modules.service_events, "public.event_type_info")
units.unit_events_subscription = Unit:from(modules.service_events, "public.subscription")
units.unit_events_subscription_type = Unit:from(modules.service_events, "public.subscription_type")
units.unit_events_dispatch = Unit:from(modules.service_events, "public.dispatch")
units.unit_events_dispatch_type = Unit:from(modules.service_events, "public.dispatch_type")
units.unit_events_dispatch_status = Unit:from(modules.service_events, "public.dispatch_status")
units.unit_events_customer_ref = Unit:from(modules.service_events, "public.customer")
units.unit_events_template = Unit:from(modules.service_events, "public.template")
units.unit_events_template_type = Unit:from(modules.service_events, "public.template_type")
units.unit_events_template_shape = Unit:from(modules.service_events, "public.template_shape")

units.unit_events_event:with_columns {
  PK:uuid 'id',
  Prop:text 'topic',
  Prop:text 'content_type',
  Prop:text 'ce_type',
  Prop:text 'ce_source',
  Prop:text 'ce_specification',
  Prop:text 'ce_id',
  Prop:datetime 'created_at',
  Prop:jsonb('payload')
    :with_column_definition('jsonb')
    :with_user_type('io.hypersistence.utils.hibernate.type.json.JsonBinaryType')
    :with_lob(true),
  Ref:one { name = 'topic_info', column = 'topic', unit = units.unit_events_event_topic_info },
  Ref:one { name = 'ce_source_info', column = 'ce_source', unit = units.unit_events_event_source_info },
  Ref:one { name = 'ce_type_info', column = 'ce_type', unit = units.unit_events_event_type_info },
}

units.unit_events_event_topic_info:with_columns {
  PK:text 'name',
  Prop:text 'description',
}

units.unit_events_event_source_info:with_columns {
  PK:text 'name',
  Prop:text 'description',
}

units.unit_events_event_type_info:with_columns {
  PK:text 'name',
  Prop:text 'description',
}

units.unit_events_subscription:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:int 'type_id',
  Prop:text 'session_id',
  Prop:datetime 'created_at',
  Prop:jsonb('payload')
    :with_column_definition('jsonb')
    :with_user_type('io.hypersistence.utils.hibernate.type.json.JsonBinaryType')
    :with_lob(true),
  Ref:one { name = 'customer', column = 'customer_id', unit = units.unit_events_customer_ref },
  Ref:one { name = 'type', column = 'type_id', unit = units.unit_events_subscription_type },
}

units.unit_events_subscription_type:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_events_dispatch:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:text 'session_id',
  Prop:uuid 'subscription_id',
  Prop:int 'type_id',
  Prop:int 'status_id',
  Prop:int 'template_type_id',
  Prop:datetime 'created_at',
  Prop:datetime 'updated_at',
  Prop:jsonb('payload')
    :with_column_definition('jsonb')
    :with_user_type('io.hypersistence.utils.hibernate.type.json.JsonBinaryType')
    :with_lob(true),
  Ref:one { name = 'customer', column = 'customer_id', unit = units.unit_events_customer_ref },
  Ref:one { name = 'subscription', column = 'subscription_id', unit = units.unit_events_subscription },
  Ref:one { name = 'type', column = 'type_id', unit = units.unit_events_dispatch_type },
  Ref:one { name = 'status', column = 'status_id', unit = units.unit_events_dispatch_status },
  Ref:one { name = 'template_type', column = 'template_type_id', unit = units.unit_events_template_type },
}

units.unit_events_dispatch_type:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_events_dispatch_status:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_events_customer_ref:with_columns {
  PK:uuid 'id',
  Prop:text 'email',
  Prop:text 'phone',
  Prop:text 'name',
  Prop:text 'surname',
  Prop:text 'patronymic',
}

units.unit_events_template:with_columns {
  PK:uuid 'id',
  Prop:int 'type_id',
  Prop:int 'shape_id',
  Prop:text 'name',
  Prop:jsonb('payload')
    :with_column_definition('jsonb')
    :with_user_type('io.hypersistence.utils.hibernate.type.json.JsonBinaryType')
    :with_lob(true),
  Ref:one { name = 'type', column = 'type_id', unit = units.unit_events_template_type },
  Ref:one { name = 'shape', column = 'shape_id', unit = units.unit_events_template_shape },
}

units.unit_events_template_type:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_events_template_shape:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_payments_basket = Unit:from(modules.service_payments, "public.basket")
units.unit_payments_basket_entry = Unit:from(modules.service_payments, "public.basket_entry")
units.unit_payments_favorite = Unit:from(modules.service_payments, "public.favorite")
units.unit_payments_order = Unit:from(modules.service_payments, "public.order")
units.unit_payments_order_type = Unit:from(modules.service_payments, "public.order_type")
units.unit_payments_order_entry = Unit:from(modules.service_payments, "public.order_entry")
units.unit_payments_order_status = Unit:from(modules.service_payments, "public.order_status")
units.unit_payments_order_discount = Unit:from(modules.service_payments, "public.order_discount")
units.unit_payments_payment = Unit:from(modules.service_payments, "public.payment")
units.unit_payments_payment_type = Unit:from(modules.service_payments, "public.payment_type")
units.unit_payments_payment_status = Unit:from(modules.service_payments, "public.payment_status")
units.unit_payments_customer_ref = Unit:from(modules.service_payments, "public.customer")
units.unit_payments_agent_ref = Unit:from(modules.service_payments, "public.agent")
units.unit_payments_product_ref = Unit:from(modules.service_payments, "public.product")
units.unit_payments_source_type_ref = Unit:from(modules.service_payments, "public.source_type")
units.unit_payments_region_ref = Unit:from(modules.service_payments, "public.region")
units.unit_payments_shop_ref = Unit:from(modules.service_payments, "public.shop")

units.unit_payments_basket:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:uuid 'agent_id',
  Prop:uuid 'region_id',
  Prop:uuid 'shop_id',
  Ref:one { name = 'customer', column = 'customer_id', unit = units.unit_payments_customer_ref },
  Ref:one { name = 'agent', column = 'agent_id', unit = units.unit_payments_agent_ref },
  Ref:one { name = 'region', column = 'region_id', unit = units.unit_payments_region_ref },
  Ref:one { name = 'shop', column = 'shop_id', unit = units.unit_payments_shop_ref },
}

units.unit_payments_basket_entry:with_columns {
  PK:uuid 'id',
  Prop:uuid 'basket_id',
  Prop:uuid 'product_id',
  Prop:int 'quantity',
  Ref:one { name = 'product', column = 'product_id', unit = units.unit_payments_product_ref },
  Ref:one { name = 'basket', column = 'basket_id', unit = units.unit_payments_basket },
}

units.unit_payments_favorite:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:uuid 'product_id',
  Ref:one { name = 'customer', column = 'customer_id', unit = units.unit_payments_customer_ref },
  Ref:one { name = 'product', column = 'product_id', unit = units.unit_payments_product_ref },
}

units.unit_payments_order:with_columns {
  PK:uuid 'id',
  Prop:int 'source_type_id',
  Prop:uuid 'customer_id',
  Prop:uuid 'region_id',
  Prop:uuid 'shop_id',
  Prop:uuid 'basket_id',
  Prop:uuid 'agent_id',
  Prop:int 'order_type_id',
  Prop:int 'order_status_id',
  Prop:decimal 'price',
  Prop:decimal 'spend',
  Prop:decimal 'bonus',
  Prop:decimal 'discount',
  Prop:datetime 'created_at',
  Prop:datetime 'updated_at',
  Ref:one { name = 'source_type', column = 'source_type_id', unit = units.unit_payments_source_type_ref },
  Ref:one { name = 'region', column = 'region_id', unit = units.unit_payments_region_ref },
  Ref:one { name = 'shop', column = 'shop_id', unit = units.unit_payments_shop_ref },
  Ref:one { name = 'customer', column = 'customer_id', unit = units.unit_payments_customer_ref },
  Ref:one { name = 'basket', column = 'basket_id', unit = units.unit_payments_basket },
  Ref:one { name = 'agent', column = 'agent_id', unit = units.unit_payments_agent_ref },
  Ref:one { name = 'order_type', column = 'order_type_id', unit = units.unit_payments_order_type },
  Ref:one { name = 'order_status', column = 'order_status_id', unit = units.unit_payments_order_status },
}

units.unit_payments_order_type:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_payments_order_entry:with_columns {
  PK:uuid 'id',
  Prop:uuid 'order_id',
  Prop:uuid 'product_id',
  Prop:int 'quantity',
  Ref:one { name = 'order', column = 'order_id', unit = units.unit_payments_order },
  Ref:one { name = 'product', column = 'product_id', unit = units.unit_payments_product_ref },
}

units.unit_payments_order_status:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_payments_order_discount:with_columns {
  PK:uuid 'id',
  Prop:uuid 'order_id',
  Prop:uuid 'product_id',
  Prop:decimal 'discount',
  Prop:decimal 'bonus',
  Ref:one { name = 'order', column = 'order_id', unit = units.unit_payments_order },
  Ref:one { name = 'product', column = 'product_id', unit = units.unit_payments_product_ref },
}

units.unit_payments_payment:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:uuid 'order_id',
  Prop:int 'payment_status_id',
  Prop:int 'payment_type_id',
  Prop:decimal 'value',
  Prop:datetime 'created_at',
  Prop:datetime 'updated_at',
  Ref:one { name = 'customer', column = 'customer_id', unit = units.unit_payments_customer_ref },
  Ref:one { name = 'order', column = 'order_id', unit = units.unit_payments_order },
  Ref:one { name = 'payment_status', column = 'payment_status_id', unit = units.unit_payments_payment_status },
  Ref:one { name = 'payment_type', column = 'payment_type_id', unit = units.unit_payments_payment_type },
}

units.unit_payments_payment_type:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_payments_payment_status:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_payments_source_type_ref:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_payments_customer_ref:with_columns {
  PK:uuid 'id',
  Prop:text 'email',
  Prop:text 'phone',
  Prop:text 'name',
  Prop:text 'surname',
  Prop:text 'patronymic',
}

units.unit_payments_agent_ref:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:text 'kind',
  Ref:one { name = 'customer', column = 'customer_id', unit = units.unit_payments_customer_ref },
}

units.unit_payments_product_ref:with_columns {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:decimal 'price',
}

units.unit_payments_region_ref:with_columns {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_payments_shop_ref:with_columns {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:text 'description',
  Prop:text 'address',
  Prop:decimal 'lon',
  Prop:decimal 'lat',
  Prop:uuid 'region_id',
  Ref:one { name = 'region', column = 'region_id', unit = units.unit_payments_region_ref },
}

units.unit_gateway_events_subscription = Unit:from(modules.gateway_events, "public.subscription")
units.unit_gateway_events_dispatch = Unit:from(modules.gateway_events, "public.dispatch")
units.unit_gateway_events_customer_ref = Unit:from(modules.gateway_events, "public.customer")

units.unit_gateway_events_subscription:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:int 'type_id',
  Prop:text 'session_id',
  Prop:datetime 'created_at',
  Prop:jsonb('payload')
    :with_column_definition('jsonb')
    :with_user_type('io.hypersistence.utils.hibernate.type.json.JsonBinaryType')
    :with_lob(true),
}

units.unit_gateway_events_dispatch:with_columns {
  PK:uuid 'id',
  Prop:uuid 'customer_id',
  Prop:text 'session_id',
  Prop:uuid 'subscription_id',
  Prop:int 'type_id',
  Prop:int 'status_id',
  Prop:datetime 'created_at',
  Prop:datetime 'updated_at',
  Prop:jsonb('payload')
    :with_column_definition('jsonb')
    :with_user_type('io.hypersistence.utils.hibernate.type.json.JsonBinaryType')
    :with_lob(true),
}

units.unit_gateway_events_customer_ref:with_columns {
  PK:uuid 'id',
  Prop:text 'email',
  Prop:text 'phone',
  Prop:text 'name',
  Prop:text 'surname',
  Prop:text 'patronymic',
}

units.unit_structure_network = Unit:from(modules.service_structure, "public.network")
units.unit_structure_network_type = Unit:from(modules.service_structure, "public.network_type")
units.unit_structure_shop_ref = Unit:from(modules.service_structure, "public.shop")
units.unit_structure_guide = Unit:from(modules.service_structure, "public.guide")
units.unit_structure_guide_subject = Unit:from(modules.service_structure, "public.guide_subject")

units.unit_structure_network:with_columns {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:text 'password',
  Prop:boolean 'hidden',
  Prop:int 'type_id',
  Prop:uuid 'shop_id',
  Prop:datetime 'created_at',
  Prop:datetime 'updated_at',
  Ref:one { name = 'type', column = 'type_id', unit = units.unit_structure_network_type },
  Ref:one { name = 'shop', column = 'shop_id', unit = units.unit_structure_shop_ref },
}

units.unit_structure_shop_ref:with_columns {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:text 'description'
}

units.unit_structure_network_type:with_columns {
  PK:int 'id',
  Prop:text 'name',
  Prop:text 'description',
}

units.unit_structure_guide:with_columns {
  PK:uuid 'id',
  Prop:uuid 'subject_id',
  Prop:text 'name',
  Prop:text 'link',
  Prop:text 'description',
  Prop:text 'attachment',
  Prop:int 'position',
  Prop:datetime 'created_at',
  Prop:datetime 'updated_at',
  Ref:one { name = 'subject', column = 'subject_id', unit = units.unit_structure_guide_subject },
}

units.unit_structure_guide_subject:with_columns {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:int 'position',
  Prop:datetime 'created_at',
  Prop:datetime 'updated_at',
  Ref:many { name = 'guides', column = 'subject_id', unit = units.unit_structure_guide },
}

return units
