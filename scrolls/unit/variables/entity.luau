local entity = require('spring/jpa/entity')
local pk = require('spring/jpa/pk')
local prop = require('spring/jpa/prop')
local ref = require('spring/jpa/ref')

return entity.entity 'public.product' {
    pk.uuid 'id',
    prop.text 'name',
    prop.text 'description',
    prop.decimal 'price',
    prop.uuid 'category_id',
    -- ref.one 'category' ('category_id', 'my.company.service.catalog.entity.CategoryEntity'),
    -- ref.many 'tags' { prop = 'id', source = 'public.tag.product_id' }
  }
