-------------------------------------------------------------------------------------------
--
--  raylib [text] example - format text
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [text] example - format text")
local score, hiscore, lives = 100020, 200450, 5
SetTargetFPS(60)
while not WindowShouldClose() do
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText(TextFormat("Score: %08i", score), 200, 80, 20, RED)
        DrawText(TextFormat("HiScore: %08i", hiscore), 200, 120, 20, GREEN)
        DrawText(TextFormat("Lives: %02i", lives), 200, 160, 40, BLUE)
        DrawText(TextFormat("Elapsed Time: %02.02f ms", GetFrameTime()*1000), 200, 220, 20, BLACK)
    EndDrawing()
end
CloseWindow()
