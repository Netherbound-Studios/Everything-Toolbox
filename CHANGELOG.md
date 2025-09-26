# Changelog

## 0.1.0 - initial release

- Added `etb.class` - Ruby-like class helper with inheritance, mixins, and defaults
- Added `etb.scene` - scene manager with push/pop/switch, transitions, modal and overlay modes
- Examples: `examples/class_demo`, `examples/scene_demo`, `examples/scene_modal`, `examples/scene_overlay`
- Basic tests under `tests/`


## 0.1.1 - fixes

- Fix `cls:super` to correctly traverse superclass chain and support inferred caller lookup
- Add tests for `super` and `supercall` behavior


