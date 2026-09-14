-------------------------------------------------------------------------------------------
--  raylib [shapes] example - raylib logo using shapes
--  This example has been created using raylib 6.0 (www.raylib.com)
-------------------------------------------------------------------------------------------
local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [shapes] example - logo raylib")
SetTargetFPS(60)
while not WindowShouldClose() do
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawRectangle(screenWidth/2 - 128, screenHeight/2 - 128, 256, 256, BLACK)
        DrawRectangle(screenWidth/2 - 112, screenHeight/2 - 112, 224, 224, RAYWHITE)
        DrawText("raylib", screenWidth/2 - 44, screenHeight/2 + 48, 50, BLACK)
        DrawText("this is NOT a texture!", 350, 370, 10, GRAY)
    EndDrawing()
end
CloseWindow()
