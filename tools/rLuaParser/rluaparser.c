/**********************************************************************************************

    rluaparser - superseded by gen_bindings.py

    Binding generation for raylib 6.0 is done by gen_bindings.py, which reads the official
    rlparser dump in api/raylib_api.json plus api/raymath.h and writes src/raylib-lua.h.

    Usage:
        python tools/rLuaParser/gen_bindings.py

    LICENSE: zlib/libpng

    Copyright (c) 2018-2026 Ramon Santamaria (@raysan5)

**********************************************************************************************/

#include <stdio.h>

int main(void)
{
    printf("raylib-lua bindings are generated with:\n");
    printf("    python tools/rLuaParser/gen_bindings.py\n");
    printf("See tools/rLuaParser/README.md\n");
    return 0;
}
