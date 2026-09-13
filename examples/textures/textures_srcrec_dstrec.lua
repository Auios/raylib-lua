-------------------------------------------------------------------------------------------
--
--  raylib [textures] example - srcrec dstrec
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [textures] example - srcrec dstrec")
local scarfy = LoadTexture("resources/scarfy.png")
local frameWidth, frameHeight = scarfy.width/6, scarfy.height
local sourceRec = Rectangle(0, 0, frameWidth, frameHeight)
local destRec = Rectangle(screenWidth/2, screenHeight/2, frameWidth*2, frameHeight*2)
local origin = Vector2(frameWidth, frameHeight)
local rotation = 0
SetTargetFPS(60)

while not WindowShouldClose() do
    rotation = rotation + 1
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawTexturePro(scarfy, sourceRec, destRec, origin, rotation, WHITE)
        DrawLine(destRec.x, 0, destRec.x, screenHeight, GRAY)
        DrawLine(0, destRec.y, screenWidth, destRec.y, GRAY)
        DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, GRAY)
    EndDrawing()
end
UnloadTexture(scarfy)
CloseWindow()
