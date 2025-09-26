package.path = package.path .. ';../?.lua;../?/init.lua;../../?.lua;../../?/init.lua'
local scene = require 'etb.scene'

local HUD -- forward declaration so Game can reference HUD
local Game = { x = 100 }
function Game:load() self.x = 100 end
function Game:update(dt) self.x = self.x + (50 * dt) end
function Game:draw()
  love.graphics.print(string.format('Game running. x=%.1f', self.x), 10, 10)
  love.graphics.print('Press H to toggle HUD overlay (non-blocking).', 10, 30)
end
function Game:keypressed(key)
  if key == 'h' then
    if scene.count() > 1 then
      scene.pop()
    else
      scene.push(HUD, { mode = 'overlay', allow_duplicates = false, allow_update_under = true })
    end
  end
end

HUD = {}
function HUD:load() end
function HUD:draw()
  love.graphics.setColor(0,0,0,0.4)
  love.graphics.rectangle('fill', love.graphics.getWidth()-160, 10, 150, 60)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print('HUD Overlay', love.graphics.getWidth()-140, 20)
  love.graphics.print('x=' .. tostring(math.floor(Game.x)), love.graphics.getWidth()-140, 40)
end
function HUD:keypressed(key)
  if key == 'escape' then scene.pop() end
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


