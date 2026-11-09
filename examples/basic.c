/*******************************************************************************************
*
*   raylib-lua basic host
*
*   Compile with CMake, or:
*   gcc -o basic.exe basic.c -I../src -I../src/external/lua/include \
*       -L../src/external/lua/lib -lraylib -llua53 -lopengl32 -lgdi32 -lwinmm -std=c99
*
*   Copyright (c) 2016-2026 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

#include "raylib.h"

#define RLUA_IMPLEMENTATION
#include "raylib-lua.h"

int main(void)
{
    rLuaInitDevice();
    rLuaExecuteFile("core/core_basic_window.lua");
    rLuaCloseDevice();
    return 0;
}
