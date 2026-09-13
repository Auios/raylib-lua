# rLuaParser

Generates the header-only Lua binding in `src/raylib-lua.h` from raylib 6.0's official API dump.

```
python tools/rLuaParser/gen_bindings.py
```

Inputs:

- `api/raylib_api.json` — `rlparser` JSON dump from raylib tag `6.0` (one description string was escaped so it is valid JSON)
- `api/raymath.h` — raylib 6.0 `raymath.h` (RMAPI functions)
- `runtime.inl` — handwritten type helpers, constructors, and special wrappers

Do not edit `src/raylib-lua.h` by hand; change `runtime.inl` / `gen_bindings.py` and regenerate.
