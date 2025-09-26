local Class = require('etb.class')

-- Test implicit super() calling
local Base = Class('Base', { defaults = { x = 1 } })
function Base:init()
  self._base_init = true
end
function Base:foo()
  return 'base'
end

local Child = Base:extend('Child', { x = 2 })
function Child:init()
  self:super()
  self._child_init = true
end
function Child:foo()
  return 'child'
end

local Grand = Child:extend('Grand')
function Grand:foo()
  -- call parent foo via implicit super()
  local parentRes = self:super()
  return parentRes .. '>grand'
end

-- explicit supercall test
local EBase = Class{name='EBase'}
function EBase:bar()
  return 'ebase'
end
local EChild = EBase:extend('EChild')
function EChild:bar()
  return self:supercall('bar') .. '>echild'
end

-- run assertions
local g = Grand()
assert(g._base_init and g._child_init)
assert(g:foo() == 'child>grand')

local ec = EChild()
assert(ec:bar() == 'ebase>echild')

print('class super tests passed')

return true


