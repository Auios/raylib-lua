-------------------------------------------------------------------------------------------
--
--  raylib [models] example - heightmap rendering
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [models] example - heightmap rendering")
local camera = Camera(Vector3(18, 21, 18), Vector3(0, 0, 0), Vector3(0, 1, 0), 45.0, CAMERA_PERSPECTIVE)
local image = LoadImage("resources/heightmap.png")
local texture = LoadTextureFromImage(image)
local mesh = GenMeshHeightmap(image, Vector3(16, 8, 16))
local model = LoadModelFromMesh(mesh)
SetModelTexture(model, MATERIAL_MAP_DIFFUSE, texture)
local mapPosition = Vector3(-8, 0, -8)
UnloadImage(image)
SetTargetFPS(60)

while not WindowShouldClose() do
    UpdateCamera(camera, CAMERA_ORBITAL)
    BeginDrawing()
        ClearBackground(RAYWHITE)
        BeginMode3D(camera)
            DrawModel(model, mapPosition, 1.0, RED)
            DrawGrid(20, 1.0)
        EndMode3D()
        DrawTexture(texture, screenWidth - texture.width - 20, 20, WHITE)
        DrawRectangleLines(screenWidth - texture.width - 20, 20, texture.width, texture.height, GREEN)
        DrawFPS(10, 10)
    EndDrawing()
end
UnloadTexture(texture)
UnloadModel(model)
CloseWindow()
