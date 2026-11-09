-------------------------------------------------------------------------------------------
--
--  raylib [models] example - cubicmap rendering
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [models] example - cubicmap rendering")
local camera = Camera(Vector3(16, 14, 16), Vector3(0, 0, 0), Vector3(0, 1, 0), 45.0, CAMERA_PERSPECTIVE)
local image = LoadImage("resources/cubicmap.png")
local cubicmap = LoadTextureFromImage(image)
local mesh = GenMeshCubicmap(image, Vector3(1, 1, 1))
local model = LoadModelFromMesh(mesh)
local texture = LoadTexture("resources/cubicmap_atlas.png")
SetModelTexture(model, MATERIAL_MAP_DIFFUSE, texture)
local mapPosition = Vector3(-16, 0, -8)
UnloadImage(image)
local pause = false
SetTargetFPS(60)

while not WindowShouldClose() do
    if IsKeyPressed(KEY_P) then pause = not pause end
    if not pause then UpdateCamera(camera, CAMERA_ORBITAL) end
    BeginDrawing()
        ClearBackground(RAYWHITE)
        BeginMode3D(camera)
            DrawModel(model, mapPosition, 1.0, WHITE)
        EndMode3D()
        DrawTextureEx(cubicmap, Vector2(screenWidth - cubicmap.width*4 - 20, 20), 0, 4, WHITE)
        DrawRectangleLines(screenWidth - cubicmap.width*4 - 20, 20, cubicmap.width*4, cubicmap.height*4, GREEN)
        DrawText("cubicmap image used to", 658, 90, 10, GRAY)
        DrawText("generate map 3d model", 658, 104, 10, GRAY)
        DrawFPS(10, 10)
    EndDrawing()
end
UnloadTexture(cubicmap)
UnloadTexture(texture)
UnloadModel(model)
CloseWindow()
