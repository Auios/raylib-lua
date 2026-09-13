<img align="left" src="logo/raylib-lua_256x256.png" width=256>

Lua bindings for [raylib](https://www.raylib.com) 6.0. The binding is a single header, [src/raylib-lua.h](src/raylib-lua.h). Include it in a small C host to load and run raylib programs written in Lua.

Scripts call raylib as globals (`InitWindow`, `DrawText`, `RAYWHITE`, `KEY_A`, `CAMERA_FREE`), matching the C API closely enough that official examples port almost 1:1.

<br><br>

### Host API

```c
#define RLUA_IMPLEMENTATION
#include "raylib-lua.h"

int main(void)
{
    rLuaInitDevice();
    rLuaExecuteFile("core_basic_window.lua");
    rLuaCloseDevice();
    return 0;
}
```

- `rLuaInitDevice` — create the Lua state and register raylib
- `rLuaExecuteFile` / `rLuaExecuteCode` — run a script
- `rLuaCloseDevice` — close Lua

Lua 5.3.3 is vendored under [src/external/lua](src/external/lua). **rlgl**, **raygui**, and **physac** are out of scope (physac is no longer part of raylib). Pin **raylib 6.0** (`tag 6.0`); 6.2-dev is already changing Image/File APIs.

### Lua types

Field tables (constructors + named fields): `Color`, `Vector2`/`Vector3`/`Vector4`, `Quaternion`, `Matrix`, `Rectangle`, `Camera`/`Camera3D`, `Camera2D`, `Ray`, `RayCollision`, `BoundingBox`, `NPatchInfo`, `Transform`.

Opaque userdata (some readable fields such as `texture.width`): `Image`, `Texture2D`, `RenderTexture2D`, `Font`, `Mesh`, `Shader`, `Material`, `Model`, `Wave`, `Sound`, `Music`, `AudioStream`.

Pointer-mutating C APIs take the object and return it:

```lua
image = ImageFormat(image, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)
UpdateCamera(camera, CAMERA_FREE)   -- also mutates the table in place
```

`LoadDroppedFiles()` returns a 1-based string array. Model materials are not nested C arrays; use `SetModelTexture(model, MATERIAL_MAP_DIFFUSE, texture)` and `SetModelShader(model, shader)`.

### Build

Needs an installed **raylib 6.0** (headers + library). Lua 5.3.3 is compiled from [src/external/lua/src](src/external/lua/src). From the repo root:

```
cmake -B build -DRAYLIB_DIR=/path/to/raylib
cmake --build build
```

`find_package(raylib 6.0)` is used when raylib was installed with CMake; otherwise pass `-DRAYLIB_DIR` (or the `RAYLIB_DIR` environment variable) pointing at a prefix with `include/raylib.h` and `lib/`. Targets: `rlualauncher`, `rlua_tester`, `rlua_basic`. On Windows the host also links `opengl32`, `gdi32`, and `winmm`.

### rLuaLauncher

[tools/rLuaLauncher/rlualauncher.c](tools/rLuaLauncher/rlualauncher.c) runs a `.lua` file from the command line or by drag-and-drop. It `ChangeDirectory`s into the script folder so relative `resources/` paths work.

```
rlualauncher examples/core/core_basic_window.lua
```

### Examples

Lua scripts under [examples](examples) are ports of the matching raylib 6.0 C examples that already lived in this tree (not the full 215-example catalog). Enums and colors use C names (`KEY_DOWN`, `PIXELFORMAT_UNCOMPRESSED_R8G8B8A8`). Texture/model/audio/font files are the same assets as the official C examples; copy them from a raylib 6.0 checkout into each example's `resources/` folder.

### Regenerating the header

Do not edit `src/raylib-lua.h` by hand:

```
python tools/rLuaParser/gen_bindings.py
```

That reads `tools/rLuaParser/api/raylib_api.json` (rlparser dump from tag `6.0`), `api/raymath.h`, and the handwritten runtime in `runtime.inl`.

# License

raylib-lua is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
BSD-like license that allows static linking with closed source software. Check [LICENSE](LICENSE) for further details.

*Copyright (c) 2016-2026 Ghassan Al-Mashareqa and Ramon Santamaria ([@raysan5](https://twitter.com/raysan5))*
