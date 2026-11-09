-------------------------------------------------------------------------------------------
--
--  raylib [core] example - World to screen
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2015-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - world screen")

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
    UpdateCamera(camera, CAMERA_THIRD_PERSON)
    local cubeScreenPosition = GetWorldToScreen(Vector3(cubePosition.x, cubePosition.y + 2.5, cubePosition.z), camera)

    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(camera)
            DrawCube(cubePosition, 2.0, 2.0, 2.0, RED)
            DrawCubeWires(cubePosition, 2.0, 2.0, 2.0, MAROON)
            DrawGrid(10, 1.0)
        EndMode3D()

        DrawText("Enemy: 100/100", cubeScreenPosition.x - MeasureText("Enemy: 100/100", 20)/2, cubeScreenPosition.y, 20, BLACK)
        DrawText(TextFormat("Cube position in screen space coordinates: [%i, %i]", cubeScreenPosition.x, cubeScreenPosition.y), 10, 10, 20, LIME)
        DrawText("Text 2d should be always on top of the cube", 10, 40, 20, GRAY)

    EndDrawing()
end

CloseWindow()
