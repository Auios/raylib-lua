-------------------------------------------------------------------------------------------
--
--  raylib [core] example - Mouse wheel input
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - input mouse wheel")

local boxPositionY = screenHeight/2 - 40
local scrollSpeed = 4

SetTargetFPS(60)

while not WindowShouldClose() do
    boxPositionY = boxPositionY - (GetMouseWheelMove()*scrollSpeed)

    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawRectangle(screenWidth/2 - 40, boxPositionY, 80, 80, MAROON)
        DrawText("Use mouse wheel to move the cube up and down!", 10, 10, 20, GRAY)
        DrawText(TextFormat("Box position Y: %03i", boxPositionY), 10, 40, 20, LIGHTGRAY)

    EndDrawing()
end

CloseWindow()
