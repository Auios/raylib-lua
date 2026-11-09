-------------------------------------------------------------------------------------------
--
--  raylib [text] example - writing anim
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [text] example - writing anim")
local message = "This sample illustrates a text writing\nanimation effect! Check it out! ;)"
local framesCounter = 0
SetTargetFPS(60)
while not WindowShouldClose() do
    if IsKeyDown(KEY_SPACE) then framesCounter = framesCounter + 8 else framesCounter = framesCounter + 1 end
    if IsKeyPressed(KEY_ENTER) then framesCounter = 0 end
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText(TextSubtext(message, 0, framesCounter//10), 210, 160, 20, MAROON)
        DrawText("PRESS [ENTER] to RESTART!", 240, 260, 20, LIGHTGRAY)
        DrawText("HOLD [SPACE] to SPEED UP!", 239, 300, 20, LIGHTGRAY)
    EndDrawing()
end
CloseWindow()
