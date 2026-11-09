-------------------------------------------------------------------------------------------
--
--  raylib [core] example - Random values
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - random values")

local randValue = GetRandomValue(-8, 5)
local framesCounter = 0

SetTargetFPS(60)

while not WindowShouldClose() do
    framesCounter = framesCounter + 1

    if ((framesCounter//120)%2) == 1 then
        randValue = GetRandomValue(-8, 5)
        framesCounter = 0
    end

    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("Every 2 seconds a new random value is generated:", 130, 100, 20, MAROON)
        DrawText(TextFormat("%i", randValue), 360, 180, 80, LIGHTGRAY)

    EndDrawing()
end

CloseWindow()
