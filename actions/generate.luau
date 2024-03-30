local ggcode = require('core/ggcode')
local POM = require('spring/POM')
local Project = require('spring/Project')
local Module = require('spring/Module')
local Profile = require('spring/Profile')
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

local unit_category = Unit
    :from(service_catalog, "public.category")
    :with_columns {
        PK:uuid 'id',
        Prop:text 'name',
        Prop:text 'description',
    }

local unit_product = Unit
    :from(service_catalog, "public.product")
    :with_columns {
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

local unit_customer = Unit
    :from(service_customers, "public.customer")
    :with_columns {
        PK:uuid 'id',
        Prop:text 'email',
        Prop:text 'phone',
        Prop:text 'name',
    }

local unit_basket_customer_ref = Unit
    :from(service_basket, "public.customer")
    :with_columns {
        PK:uuid 'id',
        Prop:text 'email',
        Prop:text 'phone',
        Prop:text 'name',
    }

local unit_basket_product_ref = Unit
    :from(service_basket, "public.product")
    :with_columns {
        PK:uuid 'id',
        Prop:text 'name',
        Prop:decimal 'price',
    }

local unit_basket_entry = Unit
    :from(service_basket, "public.basket_entry")
    :with_columns {
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

local unit_favorite = Unit
    :from(service_basket, "public.favorite")
    :with_columns {
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

local unit_order = Unit:from(service_payments, "public.order")
local unit_order_type = Unit:from(service_payments, "public.order_type")
local unit_order_entry = Unit:from(service_payments, "public.order_entry")
local unit_order_status = Unit:from(service_payments, "public.order_status")
local unit_payment = Unit:from(service_payments, "public.payment")
local unit_payment_type = Unit:from(service_payments, "public.payment_type")
local unit_payment_status = Unit:from(service_payments, "public.payment_status")
local unit_payment_customer_ref = Unit:from(service_payments, "public.customer")
local unit_payment_product_ref = Unit:from(service_payments, "public.product")

unit_order:with_columns {
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

unit_order_type:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_order_entry:with_columns {
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

unit_order_status:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payment:with_columns {
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

unit_payment_type:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payment_status:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payment_customer_ref:with_columns {
    PK:uuid 'id',
    Prop:text 'email',
    Prop:text 'phone',
    Prop:text 'name',
}

unit_payment_product_ref:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:decimal 'price',
}

local projection_system = Projection
    :from("system")
    :with_rules {
        Action:create "hasAuthority('realm:admin')";
        Action:remove "hasAuthority('realm:admin')";
        Action:remove "isAuthenticated()";
        Action:delete "isAuthenticated()";
        Action:update "isAuthenticated()";
        Action:replace "isAuthenticated()";
        Action:get "isAuthenticated()";
        Action:select "isAuthenticated()";
        Action:update "hasAuthority('realm:admin')";
        Action:get "hasAuthority('realm:admin')";
        Action:select "hasAuthority('realm:admin')";
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
        Action:get "isAuthenticated()";
        Action:select "isAuthenticated()";
        Action:create "isAuthenticated()";
        Action:remove "isAuthenticated()";
        Action:delete "isAuthenticated()";
        Action:update "isAuthenticated()";
        Action:replace "isAuthenticated()";
    }

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

-- Generate resources
ggcode.generate "@/resource" { target = '@examples', variables = Resource:from(projection_system, unit_order_type):unwrap() }
ggcode.generate "@/resource" { target = '@examples', variables = Resource:from(projection_system, unit_order_status):unwrap() }
ggcode.generate "@/resource" { target = '@examples', variables = Resource:from(projection_system, unit_payment_type):unwrap() }
ggcode.generate "@/resource" { target = '@examples', variables = Resource:from(projection_system, unit_payment_status):unwrap() }
ggcode.generate "@/resource" { target = '@examples', variables = Resource:from(projection_anonymous, unit_product):unwrap() }
ggcode.generate "@/resource" { target = '@examples', variables = Resource:from(projection_anonymous, unit_category):unwrap() }
ggcode.generate "@/resource" { target = '@examples', variables = Resource:from(projection_profile, unit_basket_entry):unwrap() }
ggcode.generate "@/resource" { target = '@examples', variables = Resource:from(projection_profile, unit_favorite):unwrap() }
ggcode.generate "@/resource" { target = '@examples', variables = Resource:from(projection_profile, unit_order):unwrap() }
ggcode.generate "@/resource" { target = '@examples', variables = Resource:from(projection_profile, unit_payment):unwrap() }
