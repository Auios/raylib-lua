-------------------------------------------------------------------------------------------
--
--  raylib [core] example - 2d camera
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2016-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local MAX_BUILDINGS = 100
local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera")

local player = Rectangle(400, 280, 40, 40)
local buildings, buildColors = {}, {}
local spacing = 0

for i = 1, MAX_BUILDINGS do
    local width = GetRandomValue(50, 200)
    local height = GetRandomValue(100, 800)
    buildings[i] = Rectangle(-6000.0 + spacing, screenHeight - 130.0 - height, width, height)
    spacing = spacing + width
    buildColors[i] = Color(GetRandomValue(200, 240), GetRandomValue(200, 240), GetRandomValue(200, 250), 255)
end

local camera = {}
camera.target = Vector2(player.x + 20.0, player.y + 20.0)
camera.offset = Vector2(screenWidth/2.0, screenHeight/2.0)
camera.rotation = 0.0
camera.zoom = 1.0

SetTargetFPS(60)

while not WindowShouldClose() do
    if IsKeyDown(KEY_RIGHT) then player.x = player.x + 2
    elseif IsKeyDown(KEY_LEFT) then player.x = player.x - 2 end

    camera.target = Vector2(player.x + 20, player.y + 20)

    if IsKeyDown(KEY_A) then camera.rotation = camera.rotation - 1
    elseif IsKeyDown(KEY_S) then camera.rotation = camera.rotation + 1 end

    if camera.rotation > 40 then camera.rotation = 40
    elseif camera.rotation < -40 then camera.rotation = -40 end

    camera.zoom = math.exp(math.log(camera.zoom) + GetMouseWheelMove()*0.1)
    if camera.zoom > 3.0 then camera.zoom = 3.0
    elseif camera.zoom < 0.1 then camera.zoom = 0.1 end

    if IsKeyPressed(KEY_R) then
        camera.zoom = 1.0
        camera.rotation = 0.0
    end

    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode2D(camera)

            DrawRectangle(-6000, 320, 13000, 8000, DARKGRAY)
            for i = 1, MAX_BUILDINGS do DrawRectangleRec(buildings[i], buildColors[i]) end
            DrawRectangleRec(player, RED)
            DrawLine(camera.target.x, -screenHeight*10, camera.target.x, screenHeight*10, GREEN)
            DrawLine(-screenWidth*10, camera.target.y, screenWidth*10, camera.target.y, GREEN)

        EndMode2D()

        DrawText("SCREEN AREA", 640, 10, 20, RED)
        DrawRectangle(0, 0, screenWidth, 5, RED)
        DrawRectangle(0, 5, 5, screenHeight - 10, RED)
        DrawRectangle(screenWidth - 5, 5, 5, screenHeight - 10, RED)
        DrawRectangle(0, screenHeight - 5, screenWidth, 5, RED)
        DrawRectangle(10, 10, 250, 113, Fade(SKYBLUE, 0.5))
        DrawRectangleLines(10, 10, 250, 113, BLUE)
        DrawText("Free 2d camera controls:", 20, 20, 10, BLACK)
        DrawText("- Right/Left to move Offset", 40, 40, 10, DARKGRAY)
        DrawText("- Mouse Wheel to Zoom in-out", 40, 60, 10, DARKGRAY)
        DrawText("- A / S to Rotate", 40, 80, 10, DARKGRAY)
        DrawText("- R to reset Zoom and Rotation", 40, 100, 10, DARKGRAY)

    EndDrawing()
end

CloseWindow()
