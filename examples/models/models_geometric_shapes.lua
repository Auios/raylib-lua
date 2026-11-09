-------------------------------------------------------------------------------------------
--
--  raylib [models] example - geometric shapes
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [models] example - geometric shapes")
local camera = Camera(Vector3(0, 10, 10), Vector3(0, 0, 0), Vector3(0, 1, 0), 45.0, CAMERA_PERSPECTIVE)
SetTargetFPS(60)
while not WindowShouldClose() do
    BeginDrawing()
        ClearBackground(RAYWHITE)
        BeginMode3D(camera)
            DrawCube(Vector3(-4, 0, 2), 2, 5, 2, RED)
            DrawCubeWires(Vector3(-4, 0, 2), 2, 5, 2, GOLD)
            DrawCubeWires(Vector3(-4, 0, -2), 3, 6, 2, MAROON)
            DrawSphere(Vector3(-1, 0, -2), 1, GREEN)
            DrawSphereWires(Vector3(1, 0, 2), 2, 16, 16, LIME)
            DrawCylinder(Vector3(4, 0, -2), 1, 2, 3, 4, SKYBLUE)
            DrawCylinderWires(Vector3(4, 0, -2), 1, 2, 3, 4, DARKBLUE)
            DrawCylinderWires(Vector3(4.5, -1, 2), 1, 1, 2, 6, BROWN)
            DrawCylinder(Vector3(1, 0, -4), 0, 1.5, 3, 8, GOLD)
            DrawCylinderWires(Vector3(1, 0, -4), 0, 1.5, 3, 8, PINK)
            DrawCapsule(Vector3(-3, 1.5, -4), Vector3(-4, -1, -4), 1.2, 8, 8, VIOLET)
            DrawCapsuleWires(Vector3(-3, 1.5, -4), Vector3(-4, -1, -4), 1.2, 8, 8, PURPLE)
            DrawGrid(10, 1.0)
        EndMode3D()
        DrawFPS(10, 10)
    EndDrawing()
end
CloseWindow()
