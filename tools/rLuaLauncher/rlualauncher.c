/*******************************************************************************************
*
*   rLuaLauncher v2.0 - raylib Lua Launcher
*
*   DEPENDENCIES:
*
*   raylib 6.0 - www.raylib.com
*   Lua 5.3.3  - vendored in src/external/lua
*
*   USAGE:
*
*   rlualauncher core_basic_window.lua
*   or drag & drop a .lua file onto the executable
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2016-2026 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

#include "raylib.h"

#include <string.h>

#define RLUA_IMPLEMENTATION
#include "raylib-lua.h"

int main(int argc, char *argv[])
{
    if (argc > 1)
    {
        if (IsFileExtension(argv[1], ".lua"))
        {
            const char *dir = GetDirectoryPath(argv[1]);
            if ((dir != NULL) && (dir[0] != '\0')) ChangeDirectory(dir);

            rLuaInitDevice();
            rLuaExecuteFile(GetFileName(argv[1]));
            rLuaCloseDevice();
        }
        else TraceLog(LOG_WARNING, "File format not supported: %s", argv[1]);
    }
    else
    {
        bool launcherShouldClose = false;

        while (!launcherShouldClose)
        {
            const int screenWidth = 800;
            const int screenHeight = 450;

            InitWindow(screenWidth, screenHeight, "rLL - raylib Lua Launcher");

            char luaFileToLoad[512] = { 0 };
            bool runLuaFile = false;

            SetTargetFPS(60);

            while (!WindowShouldClose() && !runLuaFile)
            {
                if (IsFileDropped())
                {
                    FilePathList droppedFiles = LoadDroppedFiles();

                    if (droppedFiles.count == 1)
                    {
                        if (IsFileExtension(droppedFiles.paths[0], ".lua"))
                        {
                            runLuaFile = true;
                            strncpy(luaFileToLoad, droppedFiles.paths[0], sizeof(luaFileToLoad) - 1);
                        }
                        else TraceLog(LOG_WARNING, "[%s] File format not supported", droppedFiles.paths[0]);
                    }

                    UnloadDroppedFiles(droppedFiles);
                }

                BeginDrawing();
                    ClearBackground(RAYWHITE);
                    DrawText("rLL - raylib Lua launcher", 10, 10, 20, LIGHTGRAY);
                    DrawText("rLL v2.0 (raylib 6.0)", 10, 430, 10, GRAY);
                    DrawText("< drag & drop raylib Lua file here >", 230, 180, 20, GRAY);
                EndDrawing();
            }

            CloseWindow();

            launcherShouldClose = true;

            if (runLuaFile)
            {
                TraceLog(LOG_INFO, "Loading Lua file: %s", luaFileToLoad);

                rLuaInitDevice();
                ChangeDirectory(GetDirectoryPath(luaFileToLoad));
                rLuaExecuteFile(luaFileToLoad);
                rLuaCloseDevice();

                launcherShouldClose = false;
            }
        }
    }

    return 0;
}
