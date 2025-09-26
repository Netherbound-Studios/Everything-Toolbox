local scene = require 'etb.scene'

-- simulate push modal over game
local Game = { load = function(self) self.updated = false end, update = function(self,dt) self.updated = true end }
local Pause = { load = function() end }

scene.push(Game)
assert(scene.count() == 1)
scene.push(Pause, { mode = 'modal' })
assert(scene.count() == 2)

-- top should be Pause but underlying Game should not update while modal
scene.update(0.016)
local top = scene.top().scene
assert(top == Pause)
assert(not Game.updated, 'Game should not update while modal is active')

-- pop pause and ensure game resumes updating
scene.pop()
scene.update(0.016)
assert(Game.updated, 'Game should update after modal popped')

print('scene_modal tests passed')

return true


