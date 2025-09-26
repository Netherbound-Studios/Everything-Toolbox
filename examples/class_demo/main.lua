-- allow running this example from the `examples/` directory by adding
-- parent paths to package.path so `require 'etb'` resolves to the
-- project-level `etb/init.lua`.
package.path = package.path .. ';../?.lua;../?/init.lua;../../?.lua;../../?/init.lua'

local etb = require 'etb'
local Class = etb.class

local Entity = Class('Entity', { x = 0, y = 0 })
function Entity:init(x, y)
  self.x = x or self.x
  self.y = y or self.y
end
function Entity:draw()
  love.graphics.print(string.format('%s at (%.1f, %.1f)', self.class.__name, self.x, self.y), self.x, self.y)
end

local Player = Entity:extend('Player', { name = 'Player' })
function Player:init(x, y, name)
  self:supercall('init', x, y)
  self.name = name or self.name
end
function Player:draw()
  love.graphics.setColor(1, 1, 0)
  love.graphics.print(self.name, self.x, self.y)
  love.graphics.setColor(1, 1, 1)
end

local player

function love.load()
  player = Player:new(100, 100, 'Alice')
  love.graphics.setFont(love.graphics.newFont(14))
end

function love.draw()
  player:draw()
  love.graphics.print('Press space to move the player to the right', 10, 10)
end

function love.keypressed(key)
  if key == 'space' then
    player.x = player.x + 20
  end
end


