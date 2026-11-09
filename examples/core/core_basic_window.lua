-------------------------------------------------------------------------------------------
--
--  raylib [core] example - Basic window
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2013-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window")

SetTargetFPS(60)

while not WindowShouldClose() do
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("Congrats! You created your first window!", 190, 200, 20, LIGHTGRAY)

    EndDrawing()
end

CloseWindow()
