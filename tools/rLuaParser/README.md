# rLuaParser

Generates the header-only Lua binding in `src/raylib-lua.h` from raylib 6.0's official API dump.

```
cmake --build build --target lua
build/lua tools/rLuaParser/gen_bindings.lua
```

Any Lua 5.3+ on `PATH` also works:

```
lua tools/rLuaParser/gen_bindings.lua
```

Inputs:

- `api/raylib_api.lua` — Lua table dump of the raylib 6.0 API (what the generator loads)
- `api/raylib_api.json` — original `rlparser` JSON dump from raylib tag `6.0` (one description string was escaped so it is valid JSON)
- `api/raymath.h` — raylib 6.0 `raymath.h` (RMAPI functions)
- `runtime.inl` — handwritten type helpers, constructors, and special wrappers

Do not edit `src/raylib-lua.h` by hand; change `runtime.inl` / `gen_bindings.lua` and regenerate.
