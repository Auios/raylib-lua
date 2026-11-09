-------------------------------------------------------------------------------------------
--
--  raylib [text] example - font spritefont
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [text] example - font spritefont")
local msg1 = "THIS IS A custom SPRITE FONT..."
local msg2 = "...and this is ANOTHER CUSTOM font..."
local msg3 = "...and a THIRD one! GREAT! :D"
local font1 = LoadFont("resources/custom_mecha.png")
local font2 = LoadFont("resources/custom_alagard.png")
local font3 = LoadFont("resources/custom_jupiter_crash.png")
local fontPosition1 = Vector2(screenWidth/2 - MeasureTextEx(font1, msg1, font1.baseSize, -3).x/2, screenHeight/2 - font1.baseSize/2 - 80)
local fontPosition2 = Vector2(screenWidth/2 - MeasureTextEx(font2, msg2, font2.baseSize, -2).x/2, screenHeight/2 - font2.baseSize/2 - 10)
local fontPosition3 = Vector2(screenWidth/2 - MeasureTextEx(font3, msg3, font3.baseSize, 2).x/2, screenHeight/2 - font3.baseSize/2 + 50)
SetTargetFPS(60)

while not WindowShouldClose() do
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawTextEx(font1, msg1, fontPosition1, font1.baseSize, -3, WHITE)
        DrawTextEx(font2, msg2, fontPosition2, font2.baseSize, -2, WHITE)
        DrawTextEx(font3, msg3, fontPosition3, font3.baseSize, 2, WHITE)
    EndDrawing()
end
UnloadFont(font1)
UnloadFont(font2)
UnloadFont(font3)
CloseWindow()
