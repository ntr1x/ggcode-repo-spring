local ggcode = require('core/ggcode')
local POM = require('spring/POM')
local Project = require('spring/Project')
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

local pom = POM:from('my.company', 'application', {
    "common_api",
    "common_web",
    "common_ws",
    "common_events",
    "service_catalog",
    "service_customers",
    "service_basket",
    "service_payments",
    "service_events",
    "gateway_payments",
    "gateway_customers",
    "assembly_web",
})

local project = Project:from('my_application', pom)

local profile_local = Profile:new()
    :with_port(8080)
    :with_datasource('jdbc:postgresql://localhost:5432/app', 'app', 'app')

local assembly_web = Module
    :from(project, 'assembly_web')
    :with_profile('local', profile_local:copy():with_port(8080))

local service_catalog = Module
    :from(project, 'service_catalog')
    :with_profile('local', profile_local:copy():with_port(8081))

local service_customers = Module
    :from(project, 'service_customers')
    :with_profile('local', profile_local:copy():with_port(8082))

local service_basket = Module
    :from(project, 'service_basket')
    :with_profile('local', profile_local:copy():with_port(8083))

local service_payments = Module
    :from(project, 'service_payments')
    :with_profile('local', profile_local:copy():with_port(8084))

local service_events = Module
    :from(project, 'service_events')
    :with_profile('local', profile_local:copy():with_port(8085))

local gateway_payments = Module
    :from(project, 'gateway_payments')
    :with_profile('local', profile_local:copy():with_port(8086))

local gateway_customers = Module
    :from(project, 'gateway_customers')
    :with_profile('local', profile_local:copy():with_port(8087))

local docker = Docker:from(project)
    :with_image('assembly_web')

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
        Ref:one { name = 'category', column = 'category_id', unit = unit_category },
    }

local unit_customer = Unit:from(service_customers, "public.customer")
local unit_customer_verify_phone = Unit:from(service_customers, "public.customer_verify_phone")
local unit_customer_verify_email = Unit:from(service_customers, "public.customer_verify_email")

local unit_agent = Unit:from(service_customers, "public.agent")

unit_customer:with_columns {
    PK:uuid 'id',
    Prop:text 'email',
    Prop:text 'phone',
    Prop:text 'name',
    Prop:text 'surname',
    Prop:text 'patronymic',
    Ref:many { name = 'agents', column = 'customer_id', unit = unit_agent },
    Ref:many { name = 'phones', column = 'customer_id', unit = unit_customer_verify_phone },
    Ref:many { name = 'emails', column = 'customer_id', unit = unit_customer_verify_email },
}

unit_agent:with_columns {
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
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_customer },
}

unit_customer_verify_phone:with_columns {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:text 'phone',
    Prop:int 'secret',
    Prop:boolean 'is_confirmed',
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_customer },
}

unit_customer_verify_email:with_columns {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:text 'email',
    Prop:text 'secret',
    Prop:boolean 'is_confirmed',
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_customer },
}

local unit_event = Unit
    :from(service_events, "public.event")
    :with_columns {
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

local unit_basket_customer_ref = Unit
    :from(service_basket, "public.customer")
    :with_columns {
        PK:uuid 'id',
        Prop:text 'email',
        Prop:text 'phone',
        Prop:text 'name',
        Prop:text 'surname',
        Prop:text 'patronymic',
    }

local unit_basket_product_ref = Unit
    :from(service_basket, "public.product")
    :with_columns {
        PK:uuid 'id',
        Prop:text 'name',
        Prop:decimal 'price',
    }

local unit_basket = Unit
    :from(service_basket, "public.basket")
    :with_columns {
        PK:uuid 'id',
        Prop:uuid 'customer_id',
        Prop:uuid 'agent_id',
        Ref:one { name = 'customer', column = 'customer_id', unit = unit_basket_customer_ref },
        Ref:one { name = 'agent', column = 'agent_id', unit = unit_basket_customer_ref },
    }

local unit_basket_entry = Unit
    :from(service_basket, "public.basket_entry")
    :with_columns {
        PK:uuid 'id',
        Prop:uuid 'basket_id',
        Prop:uuid 'product_id',
        Prop:int 'quantity',
        Ref:one { name = 'product', column = 'product_id', unit = unit_basket_product_ref },
        Ref:one { name = 'basket', column = 'basket_id', unit = unit_basket },
    }

local unit_favorite = Unit
    :from(service_basket, "public.favorite")
    :with_columns {
        PK:uuid 'id',
        Prop:uuid 'customer_id',
        Prop:uuid 'product_id',
        Ref:one { name = 'customer', column = 'customer_id', unit = unit_basket_customer_ref },
        Ref:one { name = 'product', column = 'product_id', unit = unit_basket_product_ref },
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
    Ref:one { name = 'customer', column = 'customer_id', unit = unit_payment_customer_ref },
    Ref:one { name = 'order_type', column = 'order_type_id', unit = unit_order_type },
    Ref:one { name = 'order_status', column = 'order_status_id', unit = unit_order_status },
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
    Ref:one { name = 'order', column = 'order_id', unit = unit_order },
    Ref:one { name = 'product', column = 'product_id', unit = unit_payment_product_ref },
}

unit_order_status:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:text 'description',
}

unit_payment:with_columns {
    PK:uuid 'id',
    Prop:uuid 'customer_id',
    Prop:uuid 'order_id',
    Prop:uuid 'payment_status_id',
    Prop:uuid 'payment_type_id',
    Prop:decimal 'value',
    Prop:datetime 'created_at',
    Prop:datetime 'updated_at',
    Ref:one { name = 'payment_status', column = 'payment_status_id', unit = unit_payment_status },
    Ref:one { name = 'payment_type', column = 'payment_type_id', unit = unit_payment_type },
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
    Prop:text 'surname',
    Prop:text 'patronymic',
}

unit_payment_product_ref:with_columns {
    PK:uuid 'id',
    Prop:text 'name',
    Prop:decimal 'price',
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

local exchange_service_customers = Exchange
    :from(service_customers)
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
            Action.Fetch:by_path(unit_basket, 'basket', 'request.basket_id'):with_is_optional(),
            Action.Validate:equals('basket.customer_id', 'context.customer_id'),
        };
        Action:create("isAuthenticated()"):with_rules {
            Action.Fetch:by_path(unit_basket, 'basket', 'request.basket_id'):with_is_optional(),
            Action.Validate:equals('basket.customer_id', 'context.customer_id'),
            Action.Override:from_value("id", "generatorService.randomUUID()");
        };
        Action:remove("isAuthenticated()"):with_rules {
            Action.Validate:equals('entity.basket.customer_id', 'context.customer_id'),
        };
        Action:delete "isAuthenticated()";
        Action:update("isAuthenticated()"):with_rules {
            Action.Fetch:by_path(unit_basket, 'basket', 'request.basket_id'):with_is_optional(),
            Action.Validate:equals('basket.customer_id', 'context.customer_id'),
        },
        Action:replace("isAuthenticated()"):with_rules {
            Action.Fetch:by_path(unit_basket, 'basket', 'request.basket_id'):with_is_optional(),
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
ggcode.generate "@/project" { target = '@app', variables = project:unwrap() }

-- Generate Build Scripts
ggcode.generate "@/docker" { target = '@app', variables = docker:unwrap() }

-- Generate Modules
ggcode.generate "@/assembly" {
    target = '@app',
    variables = Assembly:from(assembly_web, {
        service_basket,
        service_catalog,
        service_customers,
        service_payments,
        service_events,
    }):unwrap()
}
ggcode.generate "@/module_web" { target = '@app', variables = service_basket:unwrap() }
ggcode.generate "@/module_web" { target = '@app', variables = service_catalog:unwrap() }
ggcode.generate "@/module_web" { target = '@app', variables = service_customers:unwrap() }
ggcode.generate "@/module_web" { target = '@app', variables = service_payments:unwrap() }
ggcode.generate "@/module_web" { target = '@app', variables = service_events:unwrap() }
ggcode.generate "@/module_web" { target = '@app', variables = gateway_customers:unwrap() }
ggcode.generate "@/module_web" { target = '@app', variables = gateway_payments:unwrap() }

-- Generate Exchanges
ggcode.generate "@/exchange" { target = '@app', variables = exchange_service_catalog:unwrap() }
ggcode.generate "@/exchange" { target = '@app', variables = exchange_service_payments:unwrap() }
ggcode.generate "@/exchange" { target = '@app', variables = exchange_service_customers:unwrap() }
ggcode.generate "@/exchange" { target = '@app', variables = exchange_gateway_payments:unwrap() }
ggcode.generate "@/exchange" { target = '@app', variables = exchange_gateway_customers:unwrap() }
ggcode.generate "@/exchange" { target = '@app', variables = exchange_service_events:unwrap() }

-- Generate Units
ggcode.generate "@/unit" { target = '@app', variables = unit_category:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_product:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_customer:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_agent:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_customer_verify_email:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_customer_verify_phone:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_basket:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_basket_entry:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_favorite:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_basket_customer_ref:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_basket_product_ref:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_order:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_order_type:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_order_entry:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_order_status:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payment:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payment_type:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payment_status:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payment_customer_ref:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_payment_product_ref:unwrap() }
ggcode.generate "@/unit" { target = '@app', variables = unit_event:unwrap() }

-- Generate system resources

ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_customer)
        :with_title("Customers")
        :with_expanded_signals('public_customer')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_agent)
        :with_title("Agents")
        :with_expanded_signals('public_agent')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_order_type)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_order_status)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_payment_type)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_payment_status)
        :with_title("Dictionaries")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_product)
        :with_title("Products")
        :with_expanded_signals('public_product')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_category)
        :with_title("Product Categories")
        :with_expanded_signals('public_category')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_payment)
        :with_title("Payments")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_system, unit_event)
        :with_title("Events")
        :unwrap()
}

-- Generate personal resources

ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile, unit_basket)
        :with_title("Basket")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile_basket, unit_basket_entry)
        :with_title("Basket")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile, unit_favorite)
        :with_title("Favorites")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile_order, unit_order)
        :with_title("Orders")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile_payment, unit_payment)
        :with_title("Payments")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile_attribute, unit_customer)
        :with_title("Customer Profile")
        :with_expanded_signals('public_customer')
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_profile_verify_phone, unit_customer_verify_phone)
        :with_title("Customer Profile")
        :with_rules({
            Resource.Signal:create('verify_phone', '#result.created');
            Resource.Signal:update('update_email', '#result.updated');
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
        :from(projection_profile_verify_email, unit_customer_verify_email)
        :with_title("Customer Profile")
        :with_rules({
            Resource.Signal:create('verify_email', '#result.created');
            Resource.Signal:update('update_email', '#result.updated');
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
    variables = Resource
        :from(projection_anonymous, unit_product)
        :with_title("Public")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_anonymous, unit_category)
        :with_title("Public")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_anonymous, unit_order_type)
        :with_title("Public")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_anonymous, unit_order_status)
        :with_title("Public")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_anonymous, unit_payment_type)
        :with_title("Public")
        :unwrap()
}
ggcode.generate "@/resource" {
    target = '@app',
    variables = Resource
        :from(projection_anonymous, unit_payment_status)
        :with_title("Public")
        :unwrap()
}

-- Generate listeners

ggcode.generate "@/listener" {
    target = '@app',
    variables = Listener
        :from(gateway_payments, "public_payment")
        :unwrap()
}
ggcode.generate "@/listener" {
    target = '@app',
    variables = Listener
        :from(gateway_payments, "public_order")
        :unwrap()
}
ggcode.generate "@/listener" {
    target = '@app',
    variables = Listener
        :from(gateway_customers, "public_customer")
        :unwrap()
}
ggcode.generate "@/listener" {
    target = '@app',
    variables = Listener
        :from(gateway_customers, "verify_phone")
        :unwrap()
}
ggcode.generate "@/listener" {
    target = '@app',
    variables = Listener
        :from(gateway_customers, "verify_email")
        :unwrap()
}
ggcode.generate "@/listener" {
    target = '@app',
    variables = Listener
        :from(service_customers, "update_phone")
        :unwrap()
}
ggcode.generate "@/listener" {
    target = '@app',
    variables = Listener
        :from(service_customers, "update_email")
        :unwrap()
}
ggcode.generate "@/listener" {
    target = '@app',
    variables = Listener
        :from(service_events, "public_event")
        :with_topic_pattern("public_.*")
        :with_batch_flag(true)
        :unwrap()
}
