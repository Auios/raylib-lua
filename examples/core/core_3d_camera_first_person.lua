-------------------------------------------------------------------------------------------
--
--  raylib [core] example - 3d camera first person
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2015-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local MAX_COLUMNS = 20
local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera first person")

local camera = {}
camera.position = Vector3(0.0, 2.0, 4.0)
camera.target = Vector3(0.0, 2.0, 0.0)
camera.up = Vector3(0.0, 1.0, 0.0)
camera.fovy = 60.0
camera.projection = CAMERA_PERSPECTIVE

local cameraMode = CAMERA_FIRST_PERSON
local heights, positions, colors = {}, {}, {}

for i = 1, MAX_COLUMNS do
    heights[i] = GetRandomValue(1, 12)
    positions[i] = Vector3(GetRandomValue(-15, 15), heights[i]/2.0, GetRandomValue(-15, 15))
    colors[i] = Color(GetRandomValue(20, 255), GetRandomValue(10, 55), 30, 255)
end

DisableCursor()
SetTargetFPS(60)

while not WindowShouldClose() do
    if IsKeyPressed(KEY_ONE) then
        cameraMode = CAMERA_FREE
        camera.up = Vector3(0.0, 1.0, 0.0)
    end
    if IsKeyPressed(KEY_TWO) then
        cameraMode = CAMERA_FIRST_PERSON
        camera.up = Vector3(0.0, 1.0, 0.0)
    end
    if IsKeyPressed(KEY_THREE) then
        cameraMode = CAMERA_THIRD_PERSON
        camera.up = Vector3(0.0, 1.0, 0.0)
    end
    if IsKeyPressed(KEY_FOUR) then
        cameraMode = CAMERA_ORBITAL
        camera.up = Vector3(0.0, 1.0, 0.0)
    end

    if IsKeyPressed(KEY_P) then
        if camera.projection == CAMERA_PERSPECTIVE then
            cameraMode = CAMERA_THIRD_PERSON
            camera.position = Vector3(0.0, 2.0, -100.0)
            camera.target = Vector3(0.0, 2.0, 0.0)
            camera.up = Vector3(0.0, 1.0, 0.0)
            camera.projection = CAMERA_ORTHOGRAPHIC
            camera.fovy = 20.0
        else
            cameraMode = CAMERA_THIRD_PERSON
            camera.position = Vector3(0.0, 2.0, 10.0)
            camera.target = Vector3(0.0, 2.0, 0.0)
            camera.up = Vector3(0.0, 1.0, 0.0)
            camera.projection = CAMERA_PERSPECTIVE
            camera.fovy = 60.0
        end
    end

    UpdateCamera(camera, cameraMode)

    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(camera)

            DrawPlane(Vector3(0.0, 0.0, 0.0), Vector2(32.0, 32.0), LIGHTGRAY)
            DrawCube(Vector3(-16.0, 2.5, 0.0), 1.0, 5.0, 32.0, BLUE)
            DrawCube(Vector3(16.0, 2.5, 0.0), 1.0, 5.0, 32.0, LIME)
            DrawCube(Vector3(0.0, 2.5, 16.0), 32.0, 5.0, 1.0, GOLD)

            for i = 1, MAX_COLUMNS do
                DrawCube(positions[i], 2.0, heights[i], 2.0, colors[i])
                DrawCubeWires(positions[i], 2.0, heights[i], 2.0, MAROON)
            end

            if cameraMode == CAMERA_THIRD_PERSON then
                DrawCube(camera.target, 0.5, 0.5, 0.5, PURPLE)
                DrawCubeWires(camera.target, 0.5, 0.5, 0.5, DARKPURPLE)
            end

        EndMode3D()

        DrawRectangle(5, 5, 330, 100, Fade(SKYBLUE, 0.5))
        DrawRectangleLines(5, 5, 330, 100, BLUE)
        DrawText("Camera controls:", 15, 15, 10, BLACK)
        DrawText("- Move keys: W, A, S, D, Space, Left-Ctrl", 15, 30, 10, BLACK)
        DrawText("- Look around: arrow keys or mouse", 15, 45, 10, BLACK)
        DrawText("- Camera mode keys: 1, 2, 3, 4", 15, 60, 10, BLACK)
        DrawText("- Zoom keys: num-plus, num-minus or mouse scroll", 15, 75, 10, BLACK)
        DrawText("- Camera projection key: P", 15, 90, 10, BLACK)

        DrawRectangle(600, 5, 195, 100, Fade(SKYBLUE, 0.5))
        DrawRectangleLines(600, 5, 195, 100, BLUE)
        DrawText("Camera status:", 610, 15, 10, BLACK)
        local modeName = "CUSTOM"
        if cameraMode == CAMERA_FREE then modeName = "FREE"
        elseif cameraMode == CAMERA_FIRST_PERSON then modeName = "FIRST_PERSON"
        elseif cameraMode == CAMERA_THIRD_PERSON then modeName = "THIRD_PERSON"
        elseif cameraMode == CAMERA_ORBITAL then modeName = "ORBITAL" end
        DrawText(TextFormat("- Mode: %s", modeName), 610, 30, 10, BLACK)
        local projName = "PERSPECTIVE"
        if camera.projection == CAMERA_ORTHOGRAPHIC then projName = "ORTHOGRAPHIC" end
        DrawText(TextFormat("- Projection: %s", projName), 610, 45, 10, BLACK)
        DrawText(TextFormat("- Position: (%06.3f, %06.3f, %06.3f)", camera.position.x, camera.position.y, camera.position.z), 610, 60, 10, BLACK)
        DrawText(TextFormat("- Target: (%06.3f, %06.3f, %06.3f)", camera.target.x, camera.target.y, camera.target.z), 610, 75, 10, BLACK)
        DrawText(TextFormat("- Up: (%06.3f, %06.3f, %06.3f)", camera.up.x, camera.up.y, camera.up.z), 610, 90, 10, BLACK)

    EndDrawing()
end

CloseWindow()
