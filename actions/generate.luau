local ggcode = require('core/ggcode')
local Project = require('core/Project')
local POM = require('spring/POM')
local Module = require('spring/Module')
local Assembly = require('spring/Assembly')
local Profile = require('spring/Profile')
local Exchange = require('spring/Exchange')
local Topic = require('spring/exchange/Topic')
local Listener = require('spring/exchange/Listener')
local Unit = require('spring/Unit')
local Projection = require('spring/Projection')
local Resource = require('spring/Resource')
local Entity = require('spring/jpa/Entity')
local Table = require('spring/jpa/Table')
local PK = require('spring/jpa/PK')
local Prop = require('spring/jpa/Prop')
local Ref = require('spring/jpa/Ref')
local Action = require('spring/security/Action')
local Auth = require('spring/security/Auth')
local Docker = require('spring/docker/Docker')
local DDL = require('spring/DDL')

local project = Project:from('store_backend')

local project_ddl = Project:from('store_migrate')

local pom = POM:from(project, 'com.example', 'application', {
    "common_api",
    "common_jpa",
    "common_web",
    "common_ws",
    "common_events",
    "service_catalog",
    "service_profile",
    "service_events",
    "service_payments",
    "service_security",
    "gateway_payments",
    "gateway_profile",
    "assembly_web",
})

local profile_local_with_client = Profile:from('local')
    :with_port(8080)
    :with_app_openid_client({
        client_id = 'api',
        client_secret = '4Ggxc50xzu5j1qFk5rZ4OPHwvNFXLpNX'
    })

local profile_local = Profile:from('local')
    :with_port(8080)
    :with_datasource('jdbc:postgresql://localhost:5432/app', 'app', 'app')

local assembly_web = Module
    :from(pom, 'assembly_web')
    :with_profile('local', profile_local:copy():with_port(8080))

local service_catalog = Module
    :from(pom, 'service_catalog')
    :with_profile('local', profile_local:copy():with_port(8082))
    :with_plugins {
        'common_jpa',
        'common_web',
        'common_events'
    }

local service_profile = Module
    :from(pom, 'service_profile')
    :with_profile('local', profile_local:copy():with_port(8083))
    :with_plugins {
        'common_jpa',
        'common_web',
        'common_events'
    }

local service_events = Module
    :from(pom, 'service_events')
    :with_profile('local', profile_local:copy():with_port(8084))
    :with_plugins {
        'common_jpa',
        'common_web',
        'common_events'
    }

local service_payments = Module
    :from(pom, 'service_payments')
    :with_profile('local', profile_local:copy():with_port(8085))
    :with_plugins {
        'common_jpa',
        'common_web',
        'common_events'
    }

local service_security = Module
    :from(pom, 'service_security')
    :with_profile('local', profile_local_with_client:copy():with_port(8086))
    :with_plugins {
        'common_web',
        'common_events'
    }

local gateway_payments = Module
    :from(pom, 'gateway_payments')
    :with_profile('local', profile_local:copy():with_port(8087))
    :with_plugins {
        'common_jpa',
        'common_web',
        'common_events'
    }

local gateway_profile = Module
    :from(pom, 'gateway_profile')
    :with_profile('local', profile_local:copy():with_port(8088))
    :with_plugins {
        'common_jpa',
        'common_web',
        'common_events'
    }

local docker = Docker:from(pom)
    :with_image('assembly_web')

local unit_catalog_source_type = Unit:from(service_catalog, "public.source_type")
local unit_catalog_region = Unit:from(service_catalog, "public.region")
local unit_catalog_shop = Unit:from(service_catalog, "public.shop")
local unit_catalog_category = Unit:from(service_catalog, "public.category")
local unit_catalog_product = Unit:from(service_catalog, "public.product")
local unit_catalog_product_image = Unit:from(service_catalog, "public.product_image")
local unit_catalog_product_attachment = Unit:from(service_catalog, "public.product_attachment")
local unit_catalog_image_type = Unit:from(service_catalog, "public.image_type")
local unit_catalog_attachment_type = Unit:from(service_catalog, "public.attachment_type")
local unit_catalog_item = Unit:from(service_catalog, "public.item")
local unit_catalog_promotion = Unit:from(service_catalog, "public.promotion")
local unit_catalog_promotion_type = Unit:from(service_catalog, "public.promotion_type")
local unit_catalog_promotion_target = Unit:from(service_catalog, "public.promotion_target")
local unit_catalog_promotion_image = Unit:from(service_catalog, "public.promotion_image")

unit_catalog_source_type:with_columns {
    PK:int 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_catalog_region:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_catalog_shop:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
    Prop:text 'address',
    Prop:decimal 'lon',
    Prop:decimal 'lat',
    Prop:uuid 'region_id',
    Ref:one { name = 'region', column = 'region_id', unit = unit_catalog_region },
}

unit_catalog_category:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_catalog_product:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
    Prop:decimal 'price',
    Prop:text 'ean_13',
    Prop:uuid 'category_id',
    Ref:one { name = 'category', column = 'category_id', unit = unit_catalog_category },
    Ref:many { name = 'images', column = 'product_id', unit = unit_catalog_product_image },
    Ref:many { name = 'attachments', column = 'product_id', unit = unit_catalog_product_attachment },
}

unit_catalog_product_image:with_columns {
    PK:uuid 'id',
    Prop:text 'uri',
    Prop:text 'name',
    Prop:int 'type_id',
    Prop:uuid 'product_id',
    Prop:uuid 'original_id',
    Ref:one { name = 'type', column = 'type_id', unit = unit_catalog_image_type },
    Ref:one { name = 'product', column = 'product_id', unit = unit_catalog_product },
    Ref:one { name = 'original', column = 'original_id', unit = unit_catalog_product_image },
}

unit_catalog_product_attachment:with_columns {
    PK:uuid 'id',
    Prop:text 'uri',
    Prop:int 'size',
    Prop:int 'page_count',
    Prop:text 'name',
    Prop:int 'type_id',
    Prop:uuid 'product_id',
    Ref:one { name = 'type', column = 'type_id', unit = unit_catalog_attachment_type },
    Ref:one { name = 'product', column = 'product_id', unit = unit_catalog_product },
}

unit_catalog_item:with_columns {
    PK:uuid 'id',
    Prop:uuid 'product_id',
    Prop:uuid 'shop_id',
    Prop:text 'ean_13',
    Prop:text 'code_128',
    Ref:one { name = 'product', column = 'product_id', unit = unit_catalog_product },
    Ref:one { name = 'shop', column = 'shop_id', unit = unit_catalog_shop },
}

unit_catalog_promotion:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
    Prop:int 'type_id',
    Prop:jsonb('config')
        :with_column_definition('jsonb')
        :with_user_type('io.hypersistence.utils.hibernate.type.json.JsonBinaryType')
        :with_lob(true),
    Ref:one { name = 'type', column = 'type_id', unit = unit_catalog_promotion_type },
    Ref:many { name = 'images', column = 'promotion_id', unit = unit_catalog_promotion_image },
}

unit_catalog_promotion_type:with_columns {
    PK:int 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_catalog_promotion_image:with_columns {
    PK:uuid 'id',
    Prop:text 'uri',
    Prop:text 'name',
    Prop:int 'type_id',
    Prop:uuid 'promotion_id',
    Prop:uuid 'original_id',
    Ref:one { name = 'type', column = 'type_id', unit = unit_catalog_image_type },
    Ref:one { name = 'promotion', column = 'promotion_id', unit = unit_catalog_promotion },
    Ref:one { name = 'original', column = 'original_id', unit = unit_catalog_promotion_image },
}

unit_catalog_image_type:with_columns {
    PK:int 'id',
    Prop:text 'name',
    Prop:text 'description',
    Prop:text 'format',
    Prop:int 'width',
    Prop:int 'height',
}

unit_catalog_attachment_type:with_columns {
    PK:int 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_catalog_promotion_target:with_columns {
    PK:uuid 'id',
    Prop:int 'source_type_id',
    Prop:uuid 'promotion_id',
    Prop:uuid 'category_id',
    Prop:uuid 'product_id',
    Prop:uuid 'region_id',
    Prop:uuid 'shop_id',
    Ref:one { name = 'source_type', column = 'source_type_id', unit = unit_catalog_source_type },
    Ref:one { name = 'promotion', column = 'promotion_id', unit = unit_catalog_promotion },
    Ref:one { name = 'category', column = 'category_id', unit = unit_catalog_category },
    Ref:one { name = 'product', column = 'product_id', unit = unit_catalog_product },
    Ref:one { name = 'region', column = 'region_id', unit = unit_catalog_region },
    Ref:one { name = 'shop', column = 'shop_id', unit = unit_catalog_shop },
}

local unit_profile_customer = Unit:from(service_profile, "public.customer")
local unit_profile_customer_verify_phone = Unit:from(service_profile, "public.customer_verify_phone")
local unit_profile_customer_verify_email = Unit:from(service_profile, "public.customer_verify_email")
local unit_profile_customer_bonus = Unit:from(service_profile, "public.customer_bonus")
local unit_profile_agent = Unit:from(service_profile, "public.agent")

unit_profile_customer:with_columns {
    PK:uuid 'id',
    Prop:text 'email',
    Prop:text 'phone',
    Prop:text 'name',
    Prop:text 'surname',
    Prop:text 'patronymic',
    Ref:many { name = 'agents', column = 'customer_id', unit = unit_profile_agent },
    Ref:many { name = 'phones', column = 'customer_id', unit = unit_profile_customer_verify_phone },
    Ref:many { name = 'emails', column = 'customer_id', unit = unit_profile_customer_verify_email },
    Ref:many { name = 'bonuses', column = 'customer_id', unit = unit_profile_customer_bonus },
}

unit_profile_customer_bonus:with_columns {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:uuid 'order_discount_id',
    Prop:decimal 'bonus',
    Prop:datetime 'created_at',
    Prop:datetime 'updated_at',
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_profile_customer },
}

unit_profile_agent:with_columns {
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
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_profile_customer },
}

unit_profile_customer_verify_phone:with_columns {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:text 'phone',
    Prop:int 'secret',
    Prop:boolean 'is_confirmed',
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_profile_customer },
}

unit_profile_customer_verify_email:with_columns {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:text 'email',
    Prop:text 'secret',
    Prop:boolean 'is_confirmed',
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_profile_customer },
}

local unit_events_event = Unit:from(service_events, "public.event")

unit_events_event:with_columns {
    PK:uuid 'id',
    Prop:text 'topic',
    Prop:text 'content_type',
    Prop:text 'ce_type',
    Prop:text 'ce_source',
    Prop:text 'ce_specification',
    Prop:text 'ce_id',
    Prop:jsonb('payload')
        :with_column_definition('jsonb')
        :with_user_type('io.hypersistence.utils.hibernate.type.json.JsonBinaryType')
        :with_lob(true),
}

local unit_payments_basket = Unit:from(service_payments, "public.basket")
local unit_payments_basket_entry = Unit:from(service_payments, "public.basket_entry")
local unit_payments_favorite = Unit:from(service_payments, "public.favorite")
local unit_payments_order = Unit:from(service_payments, "public.order")
local unit_payments_order_type = Unit:from(service_payments, "public.order_type")
local unit_payments_order_entry = Unit:from(service_payments, "public.order_entry")
local unit_payments_order_status = Unit:from(service_payments, "public.order_status")
local unit_payments_order_discount = Unit:from(service_payments, "public.order_discount")
local unit_payments_payment = Unit:from(service_payments, "public.payment")
local unit_payments_payment_type = Unit:from(service_payments, "public.payment_type")
local unit_payments_payment_status = Unit:from(service_payments, "public.payment_status")
local unit_payments_customer_ref = Unit:from(service_payments, "public.customer")
local unit_payments_agent_ref = Unit:from(service_payments, "public.agent")
local unit_payments_product_ref = Unit:from(service_payments, "public.product")
local unit_payments_source_type_ref = Unit:from(service_payments, "public.source_type")
local unit_payments_region_ref = Unit:from(service_payments, "public.region")
local unit_payments_shop_ref = Unit:from(service_payments, "public.shop")

unit_payments_basket:with_columns {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:uuid 'agent_id',
    Prop:uuid 'region_id',
    Prop:uuid 'shop_id',
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_payments_customer_ref },
    Ref:one { name = 'agent', column = 'agent_id', unit = unit_payments_agent_ref },
    Ref:one { name = 'region', column = 'region_id', unit = unit_payments_region_ref },
    Ref:one { name = 'shop', column = 'shop_id', unit = unit_payments_shop_ref },
}

unit_payments_basket_entry:with_columns {
    PK:uuid 'id',
    Prop:uuid 'basket_id',
    Prop:uuid 'product_id',
    Prop:int 'quantity',
    Ref:one { name = 'product', column = 'product_id', unit = unit_payments_product_ref },
    Ref:one { name = 'basket', column = 'basket_id', unit = unit_payments_basket },
}

unit_payments_favorite:with_columns {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:uuid 'product_id',
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_payments_customer_ref },
    Ref:one { name = 'product', column = 'product_id', unit = unit_payments_product_ref },
}

unit_payments_order:with_columns {
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
    Ref:one { name = 'source_type', column = 'source_type_id', unit = unit_payments_source_type_ref },
    Ref:one { name = 'region', column = 'region_id', unit = unit_payments_region_ref },
    Ref:one { name = 'shop', column = 'shop_id', unit = unit_payments_shop_ref },
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_payments_customer_ref },
    Ref:one { name = 'basket', column = 'basket_id', unit = unit_payments_basket },
    Ref:one { name = 'agent', column = 'agent_id', unit = unit_payments_agent_ref },
    Ref:one { name = 'order_type', column = 'order_type_id', unit = unit_payments_order_type },
    Ref:one { name = 'order_status', column = 'order_status_id', unit = unit_payments_order_status },
}

unit_payments_order_type:with_columns {
    PK:int 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payments_order_entry:with_columns {
    PK:uuid 'id',
    Prop:uuid 'order_id',
    Prop:uuid 'product_id',
    Prop:int 'quantity',
    Ref:one { name = 'order', column = 'order_id', unit = unit_payments_order },
    Ref:one { name = 'product', column = 'product_id', unit = unit_payments_product_ref },
}

unit_payments_order_status:with_columns {
    PK:int 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payments_order_discount:with_columns {
    PK:uuid 'id',
    Prop:uuid 'order_id',
    Prop:uuid 'product_id',
    Prop:decimal 'discount',
    Prop:decimal 'bonus',
    Ref:one { name = 'order', column = 'order_id', unit = unit_payments_order },
    Ref:one { name = 'product', column = 'product_id', unit = unit_payments_product_ref },
}

unit_payments_payment:with_columns {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:uuid 'order_id',
    Prop:int 'payment_status_id',
    Prop:int 'payment_type_id',
    Prop:decimal 'value',
    Prop:datetime 'created_at',
    Prop:datetime 'updated_at',
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_payments_customer_ref },
    Ref:one { name = 'order', column = 'order_id', unit = unit_payments_order },
    Ref:one { name = 'payment_status', column = 'payment_status_id', unit = unit_payments_payment_status },
    Ref:one { name = 'payment_type', column = 'payment_type_id', unit = unit_payments_payment_type },
}

unit_payments_payment_type:with_columns {
    PK:int 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payments_payment_status:with_columns {
    PK:int 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payments_source_type_ref:with_columns {
    PK:int 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payments_customer_ref:with_columns {
    PK:uuid 'id',
    Prop:text 'email',
    Prop:text 'phone',
    Prop:text 'name',
    Prop:text 'surname',
    Prop:text 'patronymic',
}

unit_payments_agent_ref:with_columns {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:text 'kind',
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_payments_customer_ref },
}

unit_payments_product_ref:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:decimal 'price',
}

unit_payments_region_ref:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payments_shop_ref:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
    Prop:text 'address',
    Prop:decimal 'lon',
    Prop:decimal 'lat',
    Prop:uuid 'region_id',
    Ref:one { name = 'region', column = 'region_id', unit = unit_payments_region_ref },
}

local exchange_service_events = Exchange
    :from(service_events)
    :with_rules {
        Topic:from('public_customers'),
        Topic:from('public_category'),
        Topic:from('public_product'),
    }

local exchange_service_catalog = Exchange
    :from(service_catalog)
    :with_rules {
        Topic:from('public_category'),
        Topic:from('public_product'),
    }

local exchange_service_payments = Exchange
    :from(service_payments)
    :with_rules {
        Topic:from('public_order'),
        Topic:from('public_payment'),
    }

local exchange_service_profile = Exchange
    :from(service_profile)
    :with_rules {
        Topic:from('public_customers'),
        Topic:from('verify_phone'),
        Topic:from('verify_email'),
        Topic:from('update_phone'),
        Topic:from('update_email'),
    }

local exchange_gateway_payments = exchange_service_payments
    :clone()
    :with_module(gateway_payments)

local exchange_gateway_profile = exchange_service_profile
    :clone()
    :with_module(gateway_profile)

local projection_system = Projection
    :from("system")
    :with_rules {
        Action:get "hasAuthority('realm:admin')";
        Action:select "hasAuthority('realm:admin')";
        Action:create("hasAuthority('realm:admin')"):with_rules {
            Action.Override:from_value("id", "generatorService.randomUUID()");
        };
        Action:remove "hasAuthority('realm:admin')";
        Action:delete "hasAuthority('realm:admin')";
        Action:update "hasAuthority('realm:admin')";
        Action:replace "hasAuthority('realm:admin')";
    }

local projection_system_with_sequence = Projection
    :from("system")
    :with_rules {
        Action:get "hasAuthority('realm:admin')";
        Action:select "hasAuthority('realm:admin')";
        Action:create("hasAuthority('realm:admin')"):with_rules {
            Action.Override:from_value("id", "null");
        };
        Action:remove "hasAuthority('realm:admin')";
        Action:delete "hasAuthority('realm:admin')";
        Action:update "hasAuthority('realm:admin')";
        Action:replace "hasAuthority('realm:admin')";
    }

local projection_anonymous = Projection
    :from("anonymous")
    :with_rules {
        Action:get '';
        Action:select '';
    }

local projection_profile = Projection
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
        Action:remove "isAuthenticated()";
        Action:delete "isAuthenticated()";
        Action:update "isAuthenticated()";
        Action:replace("isAuthenticated()"):with_rules {
            Action.Validate:equals('entity.customer_id', 'context.customer_id'),
        };
    }

local projection_profile_basket = Projection
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
            Action.Fetch:by_path(unit_payments_basket, 'basket', 'request.basket_id'):with_is_optional(),
            Action.Validate:equals('basket.customer_id', 'context.customer_id'),
        };
        Action:create("isAuthenticated()"):with_rules {
            Action.Fetch:by_path(unit_payments_basket, 'basket', 'request.basket_id'):with_is_optional(),
            Action.Validate:equals('basket.customer_id', 'context.customer_id'),
            Action.Override:from_value("id", "generatorService.randomUUID()");
        };
        Action:remove("isAuthenticated()"):with_rules {
            Action.Validate:equals('entity.basket.customer_id', 'context.customer_id'),
        };
        Action:delete "isAuthenticated()";
        Action:update("isAuthenticated()"):with_rules {
            Action.Fetch:by_path(unit_payments_basket, 'basket', 'request.basket_id'):with_is_optional(),
            Action.Validate:equals('basket.customer_id', 'context.customer_id'),
        },
        Action:replace("isAuthenticated()"):with_rules {
            Action.Fetch:by_path(unit_payments_basket, 'basket', 'request.basket_id'):with_is_optional(),
            Action.Validate:equals('basket.customer_id', 'context.customer_id'),
        };
    }

local projection_profile_attribute = Projection
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

local projection_profile_verify_phone = Projection
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

local projection_profile_verify_email = Projection
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

local projection_profile_payment = Projection
    :from("profile")
    :with_rules {
        -- User can see but cannot update his payments directly
        Auth:subject "customer_id";
        Projection.Filter:from_path("customer_id", "context.customer_id");
        Projection.Override:from_context "customer_id";
        Action:get "isAuthenticated()";
        Action:select "isAuthenticated()";
    }

local projection_profile_order = Projection
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

-- Generate Project
ggcode.generate "@/project" { target = '@app', variables = pom:unwrap() }

-- Generate Build Scripts
ggcode.generate "@/docker" { target = '@app', variables = docker:unwrap() }

-- Generate Modules
ggcode.generate "@/assembly" {
    target = '@app',
    variables = Assembly:from(assembly_web, {
        service_catalog,
        service_profile,
        service_payments,
        service_events,
        service_security,
    }):unwrap()
}
ggcode.generate "@/module_web" { target = '@app', variables = service_catalog:unwrap() }
ggcode.generate "@/module_web" { target = '@app', variables = service_profile:unwrap() }
ggcode.generate "@/module_web" { target = '@app', variables = service_events:unwrap() }
ggcode.generate "@/module_web" { target = '@app', variables = service_payments:unwrap() }
ggcode.generate "@/module_web" { target = '@app', variables = gateway_profile:unwrap() }
ggcode.generate "@/module_web" { target = '@app', variables = gateway_payments:unwrap() }
ggcode.generate "@/module_security" { target = '@app', variables = service_security:unwrap() }

-- Generate Exchanges
ggcode.generate "@/exchange" { target = '@app', variables = exchange_service_catalog:unwrap() }
ggcode.generate "@/exchange" { target = '@app', variables = exchange_service_payments:unwrap() }
ggcode.generate "@/exchange" { target = '@app', variables = exchange_service_profile:unwrap() }
ggcode.generate "@/exchange" { target = '@app', variables = exchange_gateway_payments:unwrap() }
ggcode.generate "@/exchange" { target = '@app', variables = exchange_gateway_profile:unwrap() }
ggcode.generate "@/exchange" { target = '@app', variables = exchange_service_events:unwrap() }

-- Generate Units
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_source_type:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_region:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_shop:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_item:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_image_type:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_attachment_type:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_promotion:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_promotion_type:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_promotion_target:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_promotion_image:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_product:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_product_image:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_product_attachment:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_catalog_category:unwrap() }

ggcode.generate "@/unit" { target = '@app', variables = unit_profile_customer:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_profile_agent:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_profile_customer_verify_email:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_profile_customer_verify_phone:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_profile_customer_bonus:unwrap() }

ggcode.generate "@/unit" { target = '@app', variables = unit_payments_basket:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_basket_entry:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_favorite:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_order:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_order_type:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_order_entry:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_order_status:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_order_discount:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_payment:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_payment_type:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_payment_status:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_customer_ref:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_agent_ref:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_product_ref:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_source_type_ref:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_region_ref:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payments_shop_ref:unwrap() }

ggcode.generate "@/unit" { target = '@app', variables = unit_events_event:unwrap() }

-- Generate system resources

ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_profile_customer)
        :with_title("Customers")
        :with_expanded_signals('public_customer')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_profile_agent)
        :with_title("Agents")
        :with_expanded_signals('public_agent')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system_with_sequence, unit_catalog_source_type)
        :with_title("Sources")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_catalog_region)
        :with_title("Regions")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_catalog_shop)
        :with_title("Shops")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_catalog_promotion)
        :with_title("Promotions")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system_with_sequence, unit_catalog_promotion_type)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system_with_sequence, unit_catalog_image_type)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system_with_sequence, unit_catalog_attachment_type)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system_with_sequence, unit_payments_order_type)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system_with_sequence, unit_payments_order_status)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system_with_sequence, unit_payments_payment_type)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system_with_sequence, unit_payments_payment_status)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_catalog_product)
        :with_title("Products")
        :with_expanded_signals('public_product')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_catalog_item)
        :with_title("Product Items")
        :with_expanded_signals('public_item')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_catalog_category)
        :with_title("Product Categories")
        :with_expanded_signals('public_category')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_payments_order)
        :with_title("Orders")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_payments_payment)
        :with_title("Payments")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_events_event)
        :with_title("Events")
        :unwrap()
}

-- Generate personal resources

ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile, unit_payments_basket)
        :with_title("Basket")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile_basket, unit_payments_basket_entry)
        :with_title("Basket")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile, unit_payments_favorite)
        :with_title("Favorites")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile_order, unit_payments_order)
        :with_title("Orders")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile_payment, unit_payments_payment)
        :with_title("Payments")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile_attribute, unit_profile_customer)
        :with_title("Customer Profile")
        :with_expanded_signals('public_customer')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile_verify_phone, unit_profile_customer_verify_phone)
        :with_title("Customer Profile")
        :with_rules({
            Resource.Signal:create('verify_phone', '#result.created');
            Resource.Signal:update('update_phone', '#result.updated');
            Resource.View:kafka({ "secret", "is_confirmed" });
            Resource.View:update({ "secret" });
            Resource.Request:create(unit_profile_customer_verify_phone):with_rules {
                Resource.Override:from_expression('secret', '@generatorService.randomInt(1000, 9999)');
                Resource.Override:from_value('is_confirmed', 'false');
            };
            Resource.Request:select(unit_profile_customer_verify_phone):with_rules {
                Resource.Override:from_hidden('secret');
            };
            Resource.Request:update(unit_profile_customer_verify_phone):with_rules {
                Resource.Validate:not_null('request.id'):with_message("Property 'id' is required'"),
                Resource.Validate:not_null('request.secret'):with_message("Property 'secret' is required'"),
                Resource.Override:from_hidden('phone'),
                Resource.Override:from_value('is_confirmed', 'true'):with_hidden();
                Resource.Filter:from_value('is_confirmed', 'false');
                Resource.Filter:from_path('secret', 'request.secret'):with_is_optional();
            };
        })
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile_verify_email, unit_profile_customer_verify_email)
        :with_title("Customer Profile")
        :with_rules({
            Resource.Signal:create('verify_email', '#result.created');
            Resource.Signal:update('update_email', '#result.updated');
            Resource.View:kafka({ "secret", "is_confirmed" });
            Resource.View:update({ "secret" });
            Resource.Request:create(unit_profile_customer_verify_email):with_rules {
                Resource.Override:from_expression('secret', "@generatorService.randomString(12)");
                Resource.Override:from_value('is_confirmed', 'false');
            };
            Resource.Request:select(unit_profile_customer_verify_email):with_rules {
                Resource.Override:from_hidden('secret');
            };
            Resource.Request:update(unit_profile_customer_verify_email):with_rules {
                Resource.Validate:not_null('request.id'):with_message("Property 'id' is required'"),
                Resource.Validate:not_null('request.secret'):with_message("Property 'secret' is required'"),
                Resource.Override:from_hidden('email'),
                Resource.Override:from_value('is_confirmed', 'true'):with_hidden();
                Resource.Filter:from_value('is_confirmed', 'false');
                Resource.Filter:from_path('secret', 'request.secret'):with_is_optional();
            };
        })
        :unwrap()
}

-- Publicly accessible resources

ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource:from(projection_anonymous, unit_catalog_item):with_title("Public"):unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource:from(projection_anonymous, unit_catalog_product):with_title("Public"):unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource:from(projection_anonymous, unit_catalog_category):with_title("Public"):unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource:from(projection_anonymous, unit_catalog_promotion):with_title("Public"):unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource:from(projection_anonymous, unit_catalog_region):with_title("Public"):unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource:from(projection_anonymous, unit_catalog_shop):with_title("Public"):unwrap()
}

-- Generate listeners

ggcode.generate "@/listener" { target = '@app', variables = Listener:from(gateway_payments, "public_payment"):unwrap() }
ggcode.generate "@/listener" { target = '@app', variables = Listener:from(gateway_payments, "public_order"):unwrap() }
ggcode.generate "@/listener" { target = '@app', variables = Listener:from(gateway_profile, "public_customer"):unwrap() }
ggcode.generate "@/listener" { target = '@app', variables = Listener:from(gateway_profile, "verify_phone"):unwrap() }
ggcode.generate "@/listener" { target = '@app', variables = Listener:from(gateway_profile, "verify_email"):unwrap() }
ggcode.generate "@/listener" { target = '@app', variables = Listener:from(service_profile, "update_phone"):unwrap() }
ggcode.generate "@/listener" { target = '@app', variables = Listener:from(service_profile, "update_email"):unwrap() }
ggcode.generate "@/listener" {
    target = '@app',
    variables = Listener
        :from(service_events, "public_event")
        :with_topic_pattern("public_.*")
        :with_batch_flag(true)
        :unwrap()
}

-- Generate ddl statements

ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_profile_customer.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_profile_customer_verify_email.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_profile_customer_verify_phone.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_profile_agent.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_profile_customer_bonus.entity):unwrap() }

ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_events_event.entity):unwrap() }

ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_image_type.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_attachment_type.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_source_type.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_region.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_shop.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_category.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_product.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_product_image.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_product_attachment.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_item.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_promotion.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_promotion_type.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_promotion_target.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_catalog_promotion_image.entity):unwrap() }

ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_payments_favorite.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_payments_basket.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_payments_basket_entry.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_payments_order_status.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_payments_order_type.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_payments_order.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_payments_order_entry.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_payments_order_discount.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_payments_payment_status.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_payments_payment_type.entity):unwrap() }
ggcode.generate "@/ddl" { target = '@ddl', variables = DDL:from(project_ddl, unit_payments_payment.entity):unwrap() }
