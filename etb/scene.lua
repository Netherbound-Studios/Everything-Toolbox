
local Scene = {}

local stack = {}
local transition = nil

local _debug = false
local function nameOf(s)
  if type(s) ~= 'table' then return tostring(s) end
  return s.__name or s.name or tostring(s)
end
local function dbg(...)
  if _debug then print('[etb.scene]', ...) end
end

function Scene.set_debug(v)
  _debug = not not v
end

local function current()
  return stack[#stack]
end

-- push a scene onto the stack. calls pause() on previous scene and load()/resume() on new scene
function Scene.push(scene, opts)
  opts = opts or {}
  opts.mode = opts.mode or 'replace' -- 'replace' | 'modal' | 'overlay'
  if opts.mode == 'overlay' then
    if opts.allow_update_under == nil then opts.allow_update_under = true end
  else
    if opts.allow_update_under == nil then opts.allow_update_under = false end
  end

  local prevEntry = current()
  local prev = prevEntry and prevEntry.scene
  dbg('push requested ->', nameOf(scene), 'mode=', opts.mode, 'prev=', nameOf(prev), 'stackCount=', #stack)

  -- ignore pushing same scene if it's already the top and duplicates not allowed
  if prev == scene and not opts.allow_duplicates then
    dbg('push ignored; scene already on top ->', nameOf(scene))
    return scene
  end

  -- Pause previous scene unless overlay (overlay keeps previous running)
  if prevEntry and opts.mode ~= 'overlay' then
    if type(prev.pause) == 'function' then
      dbg('calling pause on', nameOf(prev))
      prev:pause()
      prevEntry.paused = true
    end
  end

  local entry = { scene = scene, opts = opts, paused = false }
  table.insert(stack, entry)
  dbg('scene inserted ->', nameOf(scene), 'stackCount=', #stack)

  if type(scene.load) == 'function' then
    dbg('calling load on', nameOf(scene))
    scene:load()
  elseif type(scene.resume) == 'function' then
    dbg('calling resume on', nameOf(scene))
    scene:resume()
  end

  return entry
end

-- pop the top scene. by default prevents removing the last scene; pass force=true to allow empty stack
function Scene.pop(force)
  dbg('pop requested force=', not not force, 'stackCount=', #stack)
  if #stack == 0 then
    dbg('pop: stack empty')
    return nil
  end
  if #stack == 1 and not force then
    -- don't pop the last scene to avoid empty/black screen
    dbg('pop prevented: last scene (use force=true to allow)')
    return nil
  end

  local entry = table.remove(stack)
  local s = entry and entry.scene
  dbg('popped ->', nameOf(s), 'stackCount=', #stack)
  if entry and s and type(s.unload) == 'function' then
    dbg('calling unload on', nameOf(s))
    s:unload()
  end

  local topEntry = current()
  if topEntry and topEntry.paused then
    local top = topEntry.scene
    if type(top.resume) == 'function' then
      dbg('calling resume on', nameOf(top))
      top:resume()
    end
    topEntry.paused = false
  end

  return entry
end

function Scene.switch(scene, opts)
  dbg('switch to ->', nameOf(scene))
  -- replace the top scene (force pop to ensure replacement)
  Scene.pop(true)
  return Scene.push(scene, opts)
end

function Scene.update(dt)
  if transition and transition.update then
    transition:update(dt)
    if transition.done then transition = nil end
  end

  local topEntry = current()
  if not topEntry then return end

  -- if top is overlay and allows updates under, update all entries (bottom->top)
  if topEntry.opts.mode == 'overlay' and topEntry.opts.allow_update_under then
    for i = 1, #stack do
      local e = stack[i]
      if e.scene and type(e.scene.update) == 'function' then
        e.scene:update(dt)
      end
    end
    return
  end

  -- otherwise only update top scene
  local s = topEntry.scene
  if s and type(s.update) == 'function' then s:update(dt) end
end

function Scene.draw()
  local topEntry = current()
  if not topEntry then
    if transition and type(transition.draw) == 'function' then transition:draw() end
    return
  end

  -- if top is replace, draw only top; otherwise draw all bottom->top
  if topEntry.opts.mode == 'replace' then
    local s = topEntry.scene
    if s and type(s.draw) == 'function' then s:draw() end
  else
    for i = 1, #stack do
      local e = stack[i]
      if e.scene and type(e.scene.draw) == 'function' then
        e.scene:draw()
      end
    end
  end

  if transition and type(transition.draw) == 'function' then transition:draw() end
end

-- simple fade transition
function Scene.transition_fade(duration)
  local t = { t = 0, dur = duration or 0.4, done = false }
  function t:update(dt)
    self.t = self.t + dt
    if self.t >= self.dur then self.done = true end
  end
  function t:draw()
    local a = math.min(1, self.t / self.dur)
    love.graphics.setColor(0, 0, 0, a)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1,1,1,1)
  end
  transition = t
  return t
end

-- introspection helpers
function Scene.top()
  return current()
end

function Scene.count()
  return #stack
end

-- iterator over stack entries. reverse=true yields top->bottom, otherwise bottom->top
function Scene.iter(reverse)
  if reverse then
    local i = #stack + 1
    return function()
      i = i - 1
      if i >= 1 then return stack[i] end
    end
  else
    local i = 0
    return function()
      i = i + 1
      if i <= #stack then return stack[i] end
    end
  end
end

return Scene


