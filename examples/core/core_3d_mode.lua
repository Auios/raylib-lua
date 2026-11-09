-------------------------------------------------------------------------------------------
--
--  raylib [core] example - 3d camera mode
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera mode")

local camera = {}
camera.position = Vector3(0.0, 10.0, 10.0)
camera.target = Vector3(0.0, 0.0, 0.0)
camera.up = Vector3(0.0, 1.0, 0.0)
camera.fovy = 45.0
camera.projection = CAMERA_PERSPECTIVE

local cubePosition = Vector3(0.0, 0.0, 0.0)

SetTargetFPS(60)

while not WindowShouldClose() do
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(camera)

            DrawCube(cubePosition, 2.0, 2.0, 2.0, RED)
            DrawCubeWires(cubePosition, 2.0, 2.0, 2.0, MAROON)
            DrawGrid(10, 1.0)

        EndMode3D()

        DrawText("Welcome to the third dimension!", 10, 40, 20, DARKGRAY)
        DrawFPS(10, 10)

    EndDrawing()
end

CloseWindow()
