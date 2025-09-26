local scene = require 'etb.scene'

local passed = true

local A = { load = function() A._loaded = true end, unload = function() A._unloaded = true end }
local B = { load = function() B._loaded = true end }

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


