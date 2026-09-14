-------------------------------------------------------------------------------------------
--  raylib [shapes] example - Basic shapes drawing
--  This example has been created using raylib 6.0 (www.raylib.com)
-------------------------------------------------------------------------------------------
local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [shapes] example - basic shapes")
local rotation = 0.0
SetTargetFPS(60)
while not WindowShouldClose() do
    rotation = rotation + 0.2
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText("some basic shapes available on raylib", 20, 20, 20, DARKGRAY)
        DrawCircle(screenWidth/5, 120, 35, DARKBLUE)
        DrawCircleGradient(Vector2(screenWidth/5.0, 220.0), 60, GREEN, SKYBLUE)
        DrawCircleLines(screenWidth/5, 340, 80, DARKBLUE)
        DrawRectangle(screenWidth/4*2 - 60, 100, 120, 60, RED)
        DrawRectangleGradientH(screenWidth/4*2 - 90, 170, 180, 130, MAROON, GOLD)
        DrawRectangleLines(screenWidth/4*2 - 40, 320, 80, 60, ORANGE)
        DrawTriangle(Vector2(screenWidth/4.0*3.0, 80.0), Vector2(screenWidth/4.0*3.0 - 60.0, 150.0), Vector2(screenWidth/4.0*3.0 + 60.0, 150.0), VIOLET)
        DrawTriangleLines(Vector2(screenWidth/4.0*3.0, 160.0), Vector2(screenWidth/4.0*3.0 - 20.0, 230.0), Vector2(screenWidth/4.0*3.0 + 20.0, 230.0), DARKBLUE)
        DrawPoly(Vector2(screenWidth/4.0*3, 330), 6, 80, rotation, BROWN)
        DrawPolyLines(Vector2(screenWidth/4.0*3, 330), 6, 90, rotation, BROWN)
        DrawPolyLinesEx(Vector2(screenWidth/4.0*3, 330), 6, 85, rotation, 6, BEIGE)
        DrawLine(18, 42, screenWidth - 18, 42, BLACK)
    EndDrawing()
end
CloseWindow()
