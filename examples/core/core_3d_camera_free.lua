-------------------------------------------------------------------------------------------
--
--  raylib [core] example - 3d camera free
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2015-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera free")

local camera = {}
camera.position = Vector3(10.0, 10.0, 10.0)
camera.target = Vector3(0.0, 0.0, 0.0)
camera.up = Vector3(0.0, 1.0, 0.0)
camera.fovy = 45.0
camera.projection = CAMERA_PERSPECTIVE

local cubePosition = Vector3(0.0, 0.0, 0.0)

DisableCursor()
SetTargetFPS(60)

while not WindowShouldClose() do
    UpdateCamera(camera, CAMERA_FREE)

    if IsKeyPressed(KEY_Z) then camera.target = Vector3(0.0, 0.0, 0.0) end

    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(camera)

            DrawCube(cubePosition, 2.0, 2.0, 2.0, RED)
            DrawCubeWires(cubePosition, 2.0, 2.0, 2.0, MAROON)
            DrawGrid(10, 1.0)

        EndMode3D()

        DrawRectangle(10, 10, 320, 93, Fade(SKYBLUE, 0.5))
        DrawRectangleLines(10, 10, 320, 93, BLUE)
        DrawText("Free camera default controls:", 20, 20, 10, BLACK)
        DrawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, DARKGRAY)
        DrawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, DARKGRAY)
        DrawText("- Z to zoom to (0, 0, 0)", 40, 80, 10, DARKGRAY)

    EndDrawing()
end

CloseWindow()
