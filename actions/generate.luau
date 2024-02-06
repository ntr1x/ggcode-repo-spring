local ggcode = require('core/ggcode')
local Project = require('spring/project')
local Module = require('spring/module')
local Profile = require('spring/profile')
local Unit = require('spring/unit')
local pk = require('spring/jpa/pk')
local prop = require('spring/jpa/prop')
local ref = require('spring/jpa/ref')

local project = Project:from('my_application', 'my.company', 'application', {
    "common_api",
    "common_web",
    "service_catalog",
    "service_customers",
    "service_basket",
    "service_payments",
})

ggcode.generate "@/project" { target = '@examples', variables = project }

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

ggcode.generate "@/module_web" { target = '@examples', variables = service_catalog }
ggcode.generate "@/module_web" { target = '@examples', variables = service_customers }
ggcode.generate "@/module_web" { target = '@examples', variables = service_basket }
ggcode.generate "@/module_web" { target = '@examples', variables = service_payments }

local unit_category = Unit:from(service_catalog, "category")
local unit_product = Unit:from(service_catalog, "product")

unit_category:entity "public.category" {
    pk.uuid 'id',
    prop.text 'name',
    prop.text 'description',
}

unit_product:entity "public.product" {
    pk.uuid 'id',
    prop.text 'name',
    prop.text 'description',
    prop.decimal 'price',
    prop.uuid 'category_id',
    ref.one 'category' {
        column = 'category_id',
        unit = unit_category
    },
}

ggcode.generate "@/unit" { target = '@examples', variables = unit_category }
ggcode.generate "@/unit" { target = '@examples', variables = unit_product }

local unit_customer = Unit:from(service_customers, "customer")

unit_customer:entity "public.customer" {
    pk.uuid 'id',
    prop.text 'email',
    prop.text 'phone',
    prop.text 'name',
}

ggcode.generate "@/unit" { target = '@examples', variables = unit_customer }

local unit_basket_entry = Unit:from(service_basket, "basket_entry")
local unit_favorite = Unit:from(service_basket, "favorite")
local unit_basket_customer_ref = Unit:from(service_basket, "customer")
local unit_basket_product_ref = Unit:from(service_basket, "product")

unit_basket_entry:entity "public.basket_entry" {
    pk.uuid 'id',
    prop.uuid 'customer_id',
    prop.uuid 'product_id',
    prop.int 'quantity',
    ref.one 'customer' {
        column = 'customer_id',
        unit = unit_basket_customer_ref
    },
    ref.one 'product' {
        column = 'product_id',
        unit = unit_basket_product_ref
    },
}

unit_favorite:entity "public.favorite" {
    pk.uuid 'id',
    prop.uuid 'customer_id',
    prop.uuid 'product_id',
    ref.one 'customer' {
        column = 'customer_id',
        unit = unit_basket_customer_ref
    },
    ref.one 'product' {
        column = 'product_id',
        unit = unit_basket_product_ref
    },
}

unit_basket_customer_ref:entity "public.customer" {
    pk.uuid 'id',
    prop.text 'email',
    prop.text 'phone',
    prop.text 'name',
}

unit_basket_product_ref:entity "public.product" {
    pk.uuid 'id',
    prop.text 'name',
    prop.decimal 'price',
}

ggcode.generate "@/unit" { target = '@examples', variables = unit_basket_entry }
ggcode.generate "@/unit" { target = '@examples', variables = unit_favorite }
ggcode.generate "@/unit_ref" { target = '@examples', variables = unit_basket_customer_ref }
ggcode.generate "@/unit_ref" { target = '@examples', variables = unit_basket_product_ref }

local unit_order = Unit:from(service_payments, "order")
local unit_order_type = Unit:from(service_payments, "order_type")
local unit_order_entry = Unit:from(service_payments, "order_entry")
local unit_order_status = Unit:from(service_payments, "order_status")
local unit_payment = Unit:from(service_payments, "payment")
local unit_payment_type = Unit:from(service_payments, "payment_type")
local unit_payment_status = Unit:from(service_payments, "payment_status")
local unit_payment_customer_ref = Unit:from(service_payments, "customer")
local unit_payment_product_ref = Unit:from(service_payments, "product")

unit_order:entity "public.order" {
    pk.uuid 'id',
    prop.uuid 'customer_id',
    prop.int 'order_type_id',
    prop.int 'order_status_id',
    prop.datetime 'created_at',
    prop.datetime 'updated_at',
    ref.one 'customer' {
        column = 'customer_id',
        unit = unit_payment_customer_ref
    },
    ref.one 'order_type' {
        column = 'order_type_id',
        unit = unit_order_type
    },
    ref.one 'order_status' {
        column = 'order_status_id',
        unit = unit_order_status
    },
}

unit_order_type:entity "public.order_type" {
    pk.uuid 'id',
    prop.text 'name',
    prop.text 'description',
}

unit_order_entry:entity "public.order_entry" {
    pk.uuid 'id',
    prop.uuid 'product_id',
    prop.uuid 'order_id',
    prop.int 'quantity',
    ref.one 'order' {
        column = 'order_id',
        unit = unit_order
    },
    ref.one 'product' {
        column = 'product_id',
        unit = unit_payment_product_ref
    },
}

unit_order_status:entity "public.order_status" {
    pk.uuid 'id',
    prop.text 'name',
    prop.text 'description',
}

unit_payment:entity "public.payment" {
    pk.uuid 'id',
    prop.uuid 'order_id',
    prop.uuid 'payment_status_id',
    prop.uuid 'payment_type_id',
    prop.decimal 'value',
    prop.datetime 'created_at',
    prop.datetime 'updated_at',
    ref.one 'payment_status' {
        column = 'payment_status_id',
        unit = unit_payment_status
    },
    ref.one 'payment_type' {
        column = 'payment_type_id',
        unit = unit_payment_type
    },
}

unit_payment_type:entity "public.payment_type" {
    pk.uuid 'id',
    prop.text 'name',
    prop.text 'description',
}

unit_payment_status:entity "public.payment_status" {
    pk.uuid 'id',
    prop.text 'name',
    prop.text 'description',
}

unit_payment_customer_ref:entity "public.customer" {
    pk.uuid 'id',
    prop.text 'email',
    prop.text 'phone',
    prop.text 'name',
}

unit_payment_product_ref:entity "public.product" {
    pk.uuid 'id',
    prop.text 'name',
    prop.decimal 'price',
}

ggcode.generate "@/unit" { target = '@examples', variables = unit_order }
ggcode.generate "@/unit" { target = '@examples', variables = unit_order_type }
ggcode.generate "@/unit" { target = '@examples', variables = unit_order_entry }
ggcode.generate "@/unit" { target = '@examples', variables = unit_order_status }
ggcode.generate "@/unit" { target = '@examples', variables = unit_payment }
ggcode.generate "@/unit" { target = '@examples', variables = unit_payment_type }
ggcode.generate "@/unit" { target = '@examples', variables = unit_payment_status }
ggcode.generate "@/unit_ref" { target = '@examples', variables = unit_payment_customer_ref }
ggcode.generate "@/unit_ref" { target = '@examples', variables = unit_payment_product_ref }
