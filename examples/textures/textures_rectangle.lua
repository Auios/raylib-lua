-------------------------------------------------------------------------------------------
--
--  raylib [textures] example - sprite animation
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local MAX_FRAME_SPEED, MIN_FRAME_SPEED = 15, 1
local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [textures] example - sprite animation")
local scarfy = LoadTexture("resources/scarfy.png")
local position = Vector2(350.0, 280.0)
local frameRec = Rectangle(0, 0, scarfy.width/6, scarfy.height)
local currentFrame, framesCounter, framesSpeed = 0, 0, 8
SetTargetFPS(60)

while not WindowShouldClose() do
    framesCounter = framesCounter + 1
    if framesCounter >= (60/framesSpeed) then
        framesCounter = 0
        currentFrame = currentFrame + 1
        if currentFrame > 5 then currentFrame = 0 end
        frameRec.x = currentFrame*scarfy.width/6
    end
    if IsKeyPressed(KEY_RIGHT) then framesSpeed = framesSpeed + 1
    elseif IsKeyPressed(KEY_LEFT) then framesSpeed = framesSpeed - 1 end
    if framesSpeed > MAX_FRAME_SPEED then framesSpeed = MAX_FRAME_SPEED
    elseif framesSpeed < MIN_FRAME_SPEED then framesSpeed = MIN_FRAME_SPEED end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawTexture(scarfy, 15, 40, WHITE)
        DrawRectangleLines(15, 40, scarfy.width, scarfy.height, LIME)
        DrawRectangleLines(15 + frameRec.x, 40 + frameRec.y, frameRec.width, frameRec.height, RED)
        DrawText("FRAME SPEED: ", 165, 210, 10, DARKGRAY)
        DrawText(TextFormat("%02i FPS", framesSpeed), 575, 210, 10, DARKGRAY)
        DrawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 240, 10, DARKGRAY)
        for i = 0, MAX_FRAME_SPEED - 1 do
            if i < framesSpeed then DrawRectangle(250 + 21*i, 205, 20, 20, RED) end
            DrawRectangleLines(250 + 21*i, 205, 20, 20, MAROON)
        end
        DrawTextureRec(scarfy, frameRec, position, WHITE)
        DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, GRAY)
    EndDrawing()
end
UnloadTexture(scarfy)
CloseWindow()
