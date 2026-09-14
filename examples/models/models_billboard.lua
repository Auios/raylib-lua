-------------------------------------------------------------------------------------------
--
--  raylib [models] example - billboard rendering
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [models] example - billboard rendering")
local camera = Camera(Vector3(5, 4, 5), Vector3(0, 2, 0), Vector3(0, 1, 0), 45.0, CAMERA_PERSPECTIVE)
local bill = LoadTexture("resources/billboard.png")
local billPositionStatic, billPositionRotating = Vector3(0, 2, 0), Vector3(1, 2, 1)
local source = Rectangle(0, 0, bill.width, bill.height)
local billUp = Vector3(0, 1, 0)
local size = Vector2(source.width/source.height, 1.0)
local origin = Vector2Scale(size, 0.5)
local rotation = 0.0
SetTargetFPS(60)

while not WindowShouldClose() do
    UpdateCamera(camera, CAMERA_ORBITAL)
    rotation = rotation + 0.4
    local distanceStatic = Vector3Distance(camera.position, billPositionStatic)
    local distanceRotating = Vector3Distance(camera.position, billPositionRotating)
    BeginDrawing()
        ClearBackground(RAYWHITE)
        BeginMode3D(camera)
            DrawGrid(10, 1.0)
            if distanceStatic > distanceRotating then
                DrawBillboard(camera, bill, billPositionStatic, 2.0, WHITE)
                DrawBillboardPro(camera, bill, source, billPositionRotating, billUp, size, origin, rotation, WHITE)
            else
                DrawBillboardPro(camera, bill, source, billPositionRotating, billUp, size, origin, rotation, WHITE)
                DrawBillboard(camera, bill, billPositionStatic, 2.0, WHITE)
            end
        EndMode3D()
        DrawFPS(10, 10)
    EndDrawing()
end
UnloadTexture(bill)
CloseWindow()
