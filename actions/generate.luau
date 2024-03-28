local ggcode = require('core/ggcode')
local POM = require('spring/POM')
local Project = require('spring/Project')
local Module = require('spring/Module')
local Profile = require('spring/Profile')
local Unit = require('spring/Unit')
local Entity = require('spring/jpa/Entity')
local Table = require('spring/jpa/Table')
local Resource = require('spring/Resource')
local PK = require('spring/jpa/PK')
local Prop = require('spring/jpa/Prop')
local Ref = require('spring/jpa/Ref')

local pom = POM:from('my.company', 'application', {
    "common_api",
    "common_web",
    "service_catalog",
    "service_customers",
    "service_basket",
    "service_payments",
})

local project = Project:from('my_application', pom)

local profile_local = Profile:new()
    :with_port(8080)
    :with_datasource('jdbc:postgresql://localhost:5432/app', 'app', 'app')

local service_catalog = Module
    :from(project, 'service_catalog')
    :with_profile('local', profile_local:copy():with_port(8080))

local service_customers = Module
    :from(project, 'service_customers')
    :with_profile('local', profile_local:copy():with_port(8081))

local service_basket = Module
    :from(project, 'service_basket')
    :with_profile('local', profile_local:copy():with_port(8082))

local service_payments = Module
    :from(project, 'service_payments')
    :with_profile('local', profile_local:copy():with_port(8083))

local unit_category = Unit:from(service_catalog, "category")
local unit_product = Unit:from(service_catalog, "product")

unit_category:setup_entity "public.category" {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_product:setup_entity "public.product" {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
    Prop:decimal 'price',
    Prop:uuid 'category_id',
    Ref:new {
        name = 'category',
        column = 'category_id',
        unit = unit_category,
    },
}

local unit_customer = Unit:from(service_customers, "customer")

unit_customer:setup_entity "public.customer" {
    PK:uuid 'id',
    Prop:text 'email',
    Prop:text 'phone',
    Prop:text 'name',
}

local unit_basket_entry = Unit:from(service_basket, "basket_entry")
local unit_favorite = Unit:from(service_basket, "favorite")
local unit_basket_customer_ref = Unit:from(service_basket, "customer")
local unit_basket_product_ref = Unit:from(service_basket, "product")

unit_basket_entry:setup_entity "public.basket_entry" {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:uuid 'product_id',
    Prop:int 'quantity',
    Ref:new {
        name = 'customer',
        column = 'customer_id',
        unit = unit_basket_customer_ref
    },
    Ref:new {
        name = 'product',
        column = 'product_id',
        unit = unit_basket_product_ref
    },
}

unit_favorite:setup_entity "public.favorite" {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:uuid 'product_id',
    Ref:new {
        name = 'customer',
        column = 'customer_id',
        unit = unit_basket_customer_ref
    },
    Ref:new {
        name = 'product',
        column = 'product_id',
        unit = unit_basket_product_ref
    },
}

unit_basket_customer_ref:setup_entity "public.customer" {
    PK:uuid 'id',
    Prop:text 'email',
    Prop:text 'phone',
    Prop:text 'name',
}

unit_basket_product_ref:setup_entity "public.product" {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:decimal 'price',
}

local unit_order = Unit:from(service_payments, "order")
local unit_order_type = Unit:from(service_payments, "order_type")
local unit_order_entry = Unit:from(service_payments, "order_entry")
local unit_order_status = Unit:from(service_payments, "order_status")
local unit_payment = Unit:from(service_payments, "payment")
local unit_payment_type = Unit:from(service_payments, "payment_type")
local unit_payment_status = Unit:from(service_payments, "payment_status")
local unit_payment_customer_ref = Unit:from(service_payments, "customer")
local unit_payment_product_ref = Unit:from(service_payments, "product")

unit_order:setup_entity "public.order" {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:int 'order_type_id',
    Prop:int 'order_status_id',
    Prop:datetime 'created_at',
    Prop:datetime 'updated_at',
    Ref:new {
        name = 'customer',
        column = 'customer_id',
        unit = unit_payment_customer_ref
    },
    Ref:new {
        name = 'order_type',
        column = 'order_type_id',
        unit = unit_order_type
    },
    Ref:new {
        name = 'order_status',
        column = 'order_status_id',
        unit = unit_order_status
    },
}

unit_order_type:setup_entity "public.order_type" {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_order_entry:setup_entity "public.order_entry" {
    PK:uuid 'id',
    Prop:uuid 'product_id',
    Prop:uuid 'order_id',
    Prop:int 'quantity',
    Ref:new {
        name = 'order',
        column = 'order_id',
        unit = unit_order
    },
    Ref:new {
        name = 'product',
        column = 'product_id',
        unit = unit_payment_product_ref
    },
}

unit_order_status:setup_entity "public.order_status" {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payment:setup_entity "public.payment" {
    PK:uuid 'id',
    Prop:uuid 'order_id',
    Prop:uuid 'payment_status_id',
    Prop:uuid 'payment_type_id',
    Prop:decimal 'value',
    Prop:datetime 'created_at',
    Prop:datetime 'updated_at',
    Ref:new {
        name = 'payment_status',
        column = 'payment_status_id',
        unit = unit_payment_status
    },
    Ref:new {
        name = 'payment_type',
        column = 'payment_type_id',
        unit = unit_payment_type
    },
}

unit_payment_type:setup_entity "public.payment_type" {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payment_status:setup_entity "public.payment_status" {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payment_customer_ref:setup_entity "public.customer" {
    PK:uuid 'id',
    Prop:text 'email',
    Prop:text 'phone',
    Prop:text 'name',
}

unit_payment_product_ref:setup_entity "public.product" {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:decimal 'price',
}

-- local projection_system_actions = {
--     action.create "hasAuthority('realm:admin')";
--     action.remove "hasAuthority('realm:admin')";
--     action.update "hasAuthority('realm:admin')";
--     action.get "hasAuthority('realm:admin')";
--     action.list "hasAuthority('realm:admin')";
-- }

-- local projection_system = Projection:from("system")

-- Resource:from(projection_system, unit_order_type)
-- Resource:from(projection_system, unit_order_status)
-- Resource:from(projection_system, unit_payment_type)
-- Resource:from(projection_system, unit_payment_status):with_config()

-- local projection_public_actions = {
--     action.get nil;
--     action.list nil;
-- }

-- local projection_public = Projection:from("public")

-- Resource:from(unit_product, projection_public):with_config(projection_public_actions)
-- Resource:from(unit_category, projection_public):with_config(projection_public_actions)

-- local projection_profile_actions = {
--     owner.sub "customer_id";
--     action.create "isAuthenticated()";
--     action.remove "isAuthenticated()";
--     action.update "isAuthenticated()";
--     action.get "isAuthenticated()";
--     action.list "isAuthenticated()";
-- }

-- local projection_profile = Projection:from("profile")

-- Resource:from(projection_profile, unit_basket_entry):with_config(projection_profile_actions)
-- Resource:from(projection_profile, unit_favorite):with_config(projection_profile_actions)
-- Resource:from(projection_profile, unit_order):with_config(projection_profile_actions)
-- Resource:from(projection_profile, unit_payment):with_config(projection_profile_actions)

-- Generate Project
ggcode.generate "@/project" { target = '@examples', variables = project:unwrap() }

-- Generate Modules
ggcode.generate "@/module_web" { target = '@examples', variables = service_basket:unwrap() }
ggcode.generate "@/module_web" { target = '@examples', variables = service_catalog:unwrap() }
ggcode.generate "@/module_web" { target = '@examples', variables = service_customers:unwrap() }
ggcode.generate "@/module_web" { target = '@examples', variables = service_payments:unwrap() }

-- Generate Units
ggcode.generate "@/unit" { target = '@examples', variables = unit_category:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_product:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_customer:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_basket_entry:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_favorite:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_basket_customer_ref:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_basket_product_ref:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_order:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_order_type:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_order_entry:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_order_status:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_payment:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_payment_type:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_payment_status:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_payment_customer_ref:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_payment_product_ref:unwrap() }

-- for im, module in project.modules do
--     -- Generate Modules
--     ggcode.generate "@/module_web" { target = '@examples', variables = module:unwrap() }

--     -- Generate Units (with entities, repositories and primary models)
--     for i, unit in module.units do
--         ggcode.generate "@/unit" { target = '@examples', variables = unit:unwrap() }
--     end

-- --     -- Generate Resources (with models, services and controllers)
-- --     for i, resource in module.resources do
-- --         ggcode.generate "@/resource" { target = '@examples', variables = resource:unwrap() }
-- --     end
-- end
