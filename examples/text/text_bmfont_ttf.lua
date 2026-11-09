-------------------------------------------------------------------------------------------
--
--  raylib [text] example - font loading
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [text] example - font loading")
local msg = "!#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI\nJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmn\nopqrstuvwxyz{|}~"
local fontBm = LoadFont("resources/pixantiqua.fnt")
local fontTtf = LoadFontEx("resources/pixantiqua.ttf", 32)
SetTextLineSpacing(16)
local useTtf = false
SetTargetFPS(60)

while not WindowShouldClose() do
    useTtf = IsKeyDown(KEY_SPACE)
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText("Hold SPACE to use TTF generated font", 20, 20, 20, LIGHTGRAY)
        if not useTtf then
            DrawTextEx(fontBm, msg, Vector2(20, 100), fontBm.baseSize, 2, MAROON)
            DrawText("Using BMFont (Angelcode) imported", 20, GetScreenHeight() - 30, 20, GRAY)
        else
            DrawTextEx(fontTtf, msg, Vector2(20, 100), fontTtf.baseSize, 2, LIME)
            DrawText("Using TTF font generated", 20, GetScreenHeight() - 30, 20, GRAY)
        end
    EndDrawing()
end
UnloadFont(fontBm)
UnloadFont(fontTtf)
CloseWindow()
