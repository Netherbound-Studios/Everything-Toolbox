package.path = package.path .. ';../?.lua;../?/init.lua;../../?.lua;../../?/init.lua'
local scene = require 'etb.scene'

local Pause -- forward declaration so Game can reference Pause
local Game = { x = 100 }
function Game:load() self.x = 100 end
function Game:update(dt) self.x = self.x + (50 * dt) end
function Game:draw()
  love.graphics.print(string.format('Game running. x=%.1f', self.x), 10, 10)
  love.graphics.print('Press Enter to open Pause (modal).', 10, 30)
end
function Game:keypressed(key)
  if key == 'return' then
    scene.push(Pause, { mode = 'modal' })
  end
end

Pause = {}
function Pause:load() end
function Pause:draw()
  -- draw underlying game (scene will ensure it's still drawn), then overlay message
  love.graphics.setColor(0,0,0,0.6)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(1,1,1,1)
  love.graphics.printf('PAUSED - press Escape to resume', 0, love.graphics.getHeight()/2 - 10, love.graphics.getWidth(), 'center')
end
function Pause:keypressed(key)
  if key == 'escape' then
    scene.pop()
  end
end

function love.load()
  scene.push(Game)
  love.graphics.setFont(love.graphics.newFont(14))
end

function love.update(dt)
  scene.update(dt)
end

function love.draw()
  scene.draw()
end

function love.keypressed(key)
  local topEntry = scene.top()
  local top = topEntry and topEntry.scene
  if top and type(top.keypressed) == 'function' then
    top:keypressed(key)
    return
  end
end


