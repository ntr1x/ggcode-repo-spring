local Entity = require('spring/jpa/Entity')
local PK = require('spring/jpa/PK')
local Prop = require('spring/jpa/Prop')
local Ref = require('spring/jpa/Ref')

return Entity:from('public.record', {
  PK:uuid 'id',
  Prop:text 'name',
  Prop:text 'description',
  Prop:decimal 'price',
  -- ref.one 'category' ('category_id', 'my.company.service.catalog.entity.CategoryEntity'),
  -- ref.many 'tags' { prop = 'id', source = 'public.tag.product_id' }
}):unwrap()
