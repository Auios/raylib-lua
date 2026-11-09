-------------------------------------------------------------------------------------------
--
--  raylib [core] example - Keyboard input
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - input keys")

local ballPosition = Vector2(screenWidth/2, screenHeight/2)

SetTargetFPS(60)

while not WindowShouldClose() do
    if IsKeyDown(KEY_RIGHT) then ballPosition.x = ballPosition.x + 2.0 end
    if IsKeyDown(KEY_LEFT) then ballPosition.x = ballPosition.x - 2.0 end
    if IsKeyDown(KEY_UP) then ballPosition.y = ballPosition.y - 2.0 end
    if IsKeyDown(KEY_DOWN) then ballPosition.y = ballPosition.y + 2.0 end

    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("move the ball with arrow keys", 10, 10, 20, DARKGRAY)
        DrawCircleV(ballPosition, 50, MAROON)

    EndDrawing()
end

CloseWindow()
