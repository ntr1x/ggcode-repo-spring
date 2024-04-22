local ggcode = require('core/ggcode')
local POM = require('spring/POM')
local Project = require('spring/Project')
local Module = require('spring/Module')
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

local pom = POM:from('my.company', 'application', {
    "common_api",
    "common_web",
    "common_events",
    "service_catalog",
    "service_customers",
    "service_basket",
    "service_payments",
    "gateway_payments",
    "gateway_customers",
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

local gateway_payments = Module
    :from(project, 'gateway_payments')
    :with_profile('local', profile_local:copy():with_port(8084))

local gateway_customers = Module
    :from(project, 'gateway_customers')
    :with_profile('local', profile_local:copy():with_port(8085))

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

local unit_customer_verify_phone = Unit
    :from(service_customers, "public.customer_verify_phone")
    :with_columns {
        PK:uuid 'id',
        Prop:uuid 'customer_id',
        Prop:text 'phone',
        Prop:int 'secret',
        Prop:boolean 'is_confirmed',
        Ref:new {
            name = 'customer',
            column = 'customer_id',
            unit = unit_customer
        },
    }

local unit_customer_verify_email = Unit
    :from(service_customers, "public.customer_verify_email")
    :with_columns {
        PK:uuid 'id',
        Prop:uuid 'customer_id',
        Prop:text 'email',
        Prop:text 'secret',
        Prop:boolean 'is_confirmed',
        Ref:new {
            name = 'customer',
            column = 'customer_id',
            unit = unit_customer
        },
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

local exchange_service_customers = Exchange
    :from(service_customers)
    :with_rules {
        Topic:from('public_customers'),
        Topic:from('verify_phone'),
        Topic:from('verify_email'),
    }

local exchange_gateway_payments = exchange_service_payments
    :clone()
    :with_module(gateway_payments)

local exchange_gateway_customers = exchange_service_customers
    :clone()
    :with_module(gateway_customers)

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
        Projection.Override:from_context "customer_id";
        Action:get "isAuthenticated()";
        Action:select "isAuthenticated()";
        Action:create("isAuthenticated()"):with_rules {
            Action.Override:from_value("id", "generatorService.randomUUID()");
        };
        Action:remove "isAuthenticated()";
        Action:delete "isAuthenticated()";
        Action:update "isAuthenticated()";
        Action:replace "isAuthenticated()";
    }

local projection_profile_verify_phone = Projection
    :from("profile")
    :with_rules {
        Auth:subject "customer_id";
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
        Projection.Override:from_context "customer_id";
        Action:get "isAuthenticated()";
        Action:select "isAuthenticated()";
        Action:create("isAuthenticated()"):with_rules {
            Action.Override:from_value("id", "generatorService.randomUUID()");
        };
        Action:update "isAuthenticated()";
        Action:delete "isAuthenticated()";
    }

-- Generate Project
ggcode.generate "@/project" { target = '@examples', variables = project:unwrap() }

-- Generate Modules
ggcode.generate "@/module_web" { target = '@examples', variables = service_basket:unwrap() }
ggcode.generate "@/module_web" { target = '@examples', variables = service_catalog:unwrap() }
ggcode.generate "@/module_web" { target = '@examples', variables = service_customers:unwrap() }
ggcode.generate "@/module_web" { target = '@examples', variables = service_payments:unwrap() }
ggcode.generate "@/module_web" { target = '@examples', variables = gateway_customers:unwrap() }
ggcode.generate "@/module_web" { target = '@examples', variables = gateway_payments:unwrap() }

-- Generate Exchanges
ggcode.generate "@/exchange" { target = '@examples', variables = exchange_service_catalog:unwrap() }
ggcode.generate "@/exchange" { target = '@examples', variables = exchange_service_payments:unwrap() }
ggcode.generate "@/exchange" { target = '@examples', variables = exchange_service_customers:unwrap() }
ggcode.generate "@/exchange" { target = '@examples', variables = exchange_gateway_payments:unwrap() }
ggcode.generate "@/exchange" { target = '@examples', variables = exchange_gateway_customers:unwrap() }

-- Generate Units
ggcode.generate "@/unit" { target = '@examples', variables = unit_category:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_product:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_customer:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_customer_verify_email:unwrap() }
ggcode.generate "@/unit" { target = '@examples', variables = unit_customer_verify_phone:unwrap() }
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
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_system, unit_customer)
        :with_title("Customers")
        :with_expanded_signals('public_customer')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_profile_verify_phone, unit_customer_verify_phone)
        :with_title("Customers")
        :with_rules({
            Resource.Signal:create('verify_phone', '#result.created');
            Resource.View:kafka({ "secret", "is_confirmed" });
            Resource.View:update({ "secret" });
            Resource.Request:create(unit_customer_verify_phone):with_rules {
                Resource.Override:from_expression('secret', '@generatorService.randomInt(1000, 9999)');
                Resource.Override:from_value('is_confirmed', 'false');
            };
            Resource.Request:select(unit_customer_verify_phone):with_rules {
                Resource.Override:from_hidden('secret');
            };
            Resource.Request:update(unit_customer_verify_phone):with_rules {
                Resource.Filter:from('is_confirmed', "false");
                Resource.Filter:from('email', "#request.email");
                Resource.Filter:from('secret', "#request.secret");
            };
        })
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_profile_verify_email, unit_customer_verify_email)
        :with_title("Customers")
        :with_rules({
            Resource.Signal:create('verify_email', '#result.created');
            Resource.View:kafka({ "secret", "is_confirmed" });
            Resource.View:update({ "secret" });
            Resource.Request:create(unit_customer_verify_email):with_rules {
                Resource.Override:from_expression('secret', "@generatorService.randomString(12)");
                Resource.Override:from_value('is_confirmed', 'false');
            };
            Resource.Request:select(unit_customer_verify_email):with_rules {
                Resource.Override:from_hidden('secret');
            };
            Resource.Request:update(unit_customer_verify_email):with_rules {
                Resource.Filter:from('is_confirmed', "false");
                Resource.Filter:from('email', "#request.email");
                Resource.Filter:from('secret', "#request.secret");
            };
        })
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_system, unit_order_type)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_system, unit_order_status)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_system, unit_payment_type)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_system, unit_payment_status)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_system, unit_product)
        :with_title("Products")
        :with_expanded_signals('public_product')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_system, unit_category)
        :with_title("Product Categories")
        :with_expanded_signals('public_category')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_profile, unit_basket_entry)
        :with_title("Basket")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_profile, unit_favorite)
        :with_title("Favorites")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_profile, unit_order)
        :with_title("Orders")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_profile, unit_payment)
        :with_title("Payments")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_anonymous, unit_product)
        :with_title("Public")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_anonymous, unit_category)
        :with_title("Public")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_anonymous, unit_order_type)
        :with_title("Public")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_anonymous, unit_order_status)
        :with_title("Public")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_anonymous, unit_payment_type)
        :with_title("Public")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@examples',
    variables = Resource
        :from(projection_anonymous, unit_payment_status)
        :with_title("Public")
        :unwrap()
}

-- Generate listeners
ggcode.generate "@/listener" {
    target = '@examples',
    variables = Listener
        :from(gateway_payments, "public_payment")
        :unwrap()
}

ggcode.generate "@/listener" {
    target = '@examples',
    variables = Listener
        :from(gateway_payments, "public_order")
        :unwrap()
}

ggcode.generate "@/listener" {
    target = '@examples',
    variables = Listener
        :from(gateway_customers, "public_customer")
        :unwrap()
}
