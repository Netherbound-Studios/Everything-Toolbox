local etb = require 'etb'
local Class = etb.class

local function ok(cond, msg)
  if not cond then error('Test failed: ' .. (msg or '')) end
end

-- Test defaults and init
local Entity = Class('Entity', { x = 1, y = 2 })
function Entity:init(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

local e = Entity:new()
ok(e.x == 1 and e.y == 2, 'defaults applied')

local e2 = Entity:new(5, 6)
ok(e2.x == 5 and e2.y == 6, 'init overrides defaults')

-- Test inheritance and supercall
local Player = Entity:extend('Player', { name = 'anon' })
function Player:init(x, y, name)
  -- explicit supercall
  self:supercall('init', x, y)
  self.name = name or self.name
end

local p = Player:new(0, 0, 'alice')
ok(p.x == 0 and p.y == 0 and p.name == 'alice', 'inheritance and supercall')

-- Test mixin
local Health = {
  setHealth = function(self, h) self.hp = h end,
  heal = function(self, a) self.hp = self.hp + a end,
}
Player:include(Health)
p:setHealth(100)
p:heal(5)
ok(p.hp == 105, 'mixin methods work')

-- isInstance
ok(Player:isInstance(p), 'player is instance of Player')
ok(Entity:isInstance(p), 'player is instance of Entity (parent)')
ok(not Player:isInstance(e), 'entity not instance of Player')

print('All tests passed')

return true


