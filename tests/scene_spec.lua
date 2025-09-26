local scene = require 'etb.scene'

local passed = true

local A = { load = function(self) self._loaded = true end, unload = function(self) self._unloaded = true end }
local B = { load = function(self) self._loaded = true end }

scene.push(A)
assert(A._loaded)
scene.push(B)
assert(B._loaded)
scene.pop()
assert(B._unloaded == nil)
scene.pop()
assert(A._unloaded == true)

print('scene tests passed')

return true


