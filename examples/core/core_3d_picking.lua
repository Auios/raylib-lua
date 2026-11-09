-------------------------------------------------------------------------------------------
--
--  raylib [core] example - 3d picking
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2015-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d picking")

local camera = {}
camera.position = Vector3(10.0, 10.0, 10.0)
camera.target = Vector3(0.0, 0.0, 0.0)
camera.up = Vector3(0.0, 1.0, 0.0)
camera.fovy = 45.0
camera.projection = CAMERA_PERSPECTIVE

local cubePosition = Vector3(0.0, 1.0, 0.0)
local cubeSize = Vector3(2.0, 2.0, 2.0)
local ray = Ray(Vector3(0, 0, 0), Vector3(0, 0, 0))
local collision = { hit = false, distance = 0, point = Vector3(0, 0, 0), normal = Vector3(0, 0, 0) }

SetTargetFPS(60)

while not WindowShouldClose() do
    if IsCursorHidden() then UpdateCamera(camera, CAMERA_FIRST_PERSON) end

    if IsMouseButtonPressed(MOUSE_BUTTON_RIGHT) then
        if IsCursorHidden() then EnableCursor() else DisableCursor() end
    end

    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
        if not collision.hit then
            ray = GetScreenToWorldRay(GetMousePosition(), camera)
            collision = GetRayCollisionBox(ray, BoundingBox(
                Vector3(cubePosition.x - cubeSize.x/2, cubePosition.y - cubeSize.y/2, cubePosition.z - cubeSize.z/2),
                Vector3(cubePosition.x + cubeSize.x/2, cubePosition.y + cubeSize.y/2, cubePosition.z + cubeSize.z/2)))
        else
            collision.hit = false
        end
    end

    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(camera)

            if collision.hit then
                DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, RED)
                DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, MAROON)
                DrawCubeWires(cubePosition, cubeSize.x + 0.2, cubeSize.y + 0.2, cubeSize.z + 0.2, GREEN)
            else
                DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, GRAY)
                DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, DARKGRAY)
            end

            DrawRay(ray, MAROON)
            DrawGrid(10, 1.0)

        EndMode3D()

        DrawText("Try clicking on the box with your mouse!", 240, 10, 20, DARKGRAY)
        if collision.hit then
            DrawText("BOX SELECTED", (screenWidth - MeasureText("BOX SELECTED", 30))/2, screenHeight*0.1, 30, GREEN)
        end
        DrawText("Right click mouse to toggle camera controls", 10, 430, 10, GRAY)
        DrawFPS(10, 10)

    EndDrawing()
end

CloseWindow()
