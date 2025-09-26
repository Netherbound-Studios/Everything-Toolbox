package.path = package.path .. ';../?.lua;../?/init.lua;../../?.lua;../../?/init.lua'
local scene = require 'etb.scene'
scene.set_debug(true)

local Menu = {}
function Menu:load() end
function Menu:update(dt) end
function Menu:draw()
  love.graphics.print('Menu - press enter to go to Game', 10, 10)
end

local Game = {}
function Game:load() end
function Game:update(dt) end
function Game:draw()
  love.graphics.print('Game - press escape to return', 10, 10)
end

function love.load()
  scene.push(Menu)
end

function love.update(dt)
  scene.update(dt)
end

function love.draw()
  scene.draw()
end

function love.keypressed(key)
  if key == 'return' then
    scene.push(Game)
  elseif key == 'escape' then
    scene.pop()
  end
end


