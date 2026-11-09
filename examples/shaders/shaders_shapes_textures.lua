-------------------------------------------------------------------------------------------
--
--  raylib [shaders] example - shapes textures
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local GLSL_VERSION = 330
local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [shaders] example - shapes textures")
local fudesumi = LoadTexture("resources/fudesumi.png")
local shader = LoadShader(nil, TextFormat("resources/shaders/glsl%i/grayscale.fs", GLSL_VERSION))
SetTargetFPS(60)

while not WindowShouldClose() do
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText("USING DEFAULT SHADER", 20, 40, 10, RED)
        DrawCircle(80, 120, 35, DARKBLUE)
        DrawCircleGradient(Vector2(80, 220), 60, GREEN, SKYBLUE)
        DrawCircleLines(80, 340, 80, DARKBLUE)
        BeginShaderMode(shader)
            DrawText("USING CUSTOM SHADER", 190, 40, 10, RED)
            DrawRectangle(250 - 60, 90, 120, 60, RED)
            DrawRectangleGradientH(250 - 90, 170, 180, 130, MAROON, GOLD)
            DrawRectangleLines(250 - 40, 320, 80, 60, ORANGE)
        EndShaderMode()
        DrawText("USING DEFAULT SHADER", 370, 40, 10, RED)
        DrawTriangle(Vector2(430, 80), Vector2(430 - 60, 150), Vector2(430 + 60, 150), VIOLET)
        DrawTriangleLines(Vector2(430, 160), Vector2(430 - 20, 230), Vector2(430 + 20, 230), DARKBLUE)
        DrawPoly(Vector2(430, 320), 6, 80, 0, BROWN)
        BeginShaderMode(shader)
            DrawTexture(fudesumi, 500, -30, WHITE)
        EndShaderMode()
        DrawText("(c) Fudesumi sprite by Eiden Marsal", 380, screenHeight - 20, 10, GRAY)
    EndDrawing()
end
UnloadShader(shader)
UnloadTexture(fudesumi)
CloseWindow()
