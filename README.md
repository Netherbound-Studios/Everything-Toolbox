# everything-toolbox

Lightweight utility toolbox for Love2D projects.

## Modules

- `etb.class` — Ruby-like Class helper (`Class('Name')`, `:extend`, `:new`, `:include`)
- `etb.scene` — Scene manager with stack, transitions, modal and overlay support

## Scene API

Basic usage:

```lua
local scene = require 'etb.scene'

-- push a scene (replace mode)
scene.push(MyScene)

-- push a modal (pauses underlying update but still draws it)
scene.push(PauseScene, { mode = 'modal' })

-- push an overlay (draws on top, underlying continues updating)
scene.push(HUD, { mode = 'overlay', allow_update_under = true })

-- pop (default prevents popping last scene)
scene.pop()

-- force pop last scene
scene.pop(true)

-- switch (replace top)
scene.switch(GameScene)
```

Scene entry options:
- `mode` (string) — `'replace'` (default), `'modal'`, or `'overlay'`.
- `allow_duplicates` (bool) — allow pushing same scene multiple times. Default `false`.
- `allow_update_under` (bool) — for `overlay`, whether underlying scenes update. Defaults to `true` for overlay, `false` otherwise.

Lifecycle hooks supported on scenes:
- `load()` — called when scene is pushed.
- `pause()` — called when scene is covered and should stop updating.
- `resume()` — called when scene becomes top again.
- `unload()` — called when scene is popped and removed.

## Class API

```lua
local Class = require 'etb.class'
local Entity = Class('Entity')
function Entity:init(x,y) self.x, self.y = x or 0, y or 0 end
local e = Entity:new(10,20)
```

Supports `:extend`, `:include` mixins, `:supercall(method, ...)` for explicit super calls, and `:isInstance(obj)`.

## Examples

- `examples/scene_demo` — basic scene switching.
- `examples/scene_modal` — demonstrate modal pause overlay.
- `examples/scene_overlay` — HUD overlay that doesn't pause underlying update.
- `examples/class_demo` — Class usage example.

## License

MIT

## Version

See `VERSION` for the current release. This release (0.1.1) fixes superclass `super()` traversal and improves `super`/`supercall` behavior.


