-------------------------------------------------------------------------------------------
--
--  raylib [shaders] example - model shader
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local GLSL_VERSION = 330
local screenWidth, screenHeight = 800, 450
SetConfigFlags(FLAG_MSAA_4X_HINT)
InitWindow(screenWidth, screenHeight, "raylib [shaders] example - model shader")
local camera = Camera(Vector3(4, 4, 4), Vector3(0, 1, -1), Vector3(0, 1, 0), 45.0, CAMERA_PERSPECTIVE)
local model = LoadModel("resources/models/watermill.obj")
local texture = LoadTexture("resources/models/watermill_diffuse.png")
local shader = LoadShader(nil, TextFormat("resources/shaders/glsl%i/grayscale.fs", GLSL_VERSION))
SetModelShader(model, shader)
SetModelTexture(model, MATERIAL_MAP_DIFFUSE, texture)
local position = Vector3(0, 0, 0)
DisableCursor()
SetTargetFPS(60)

while not WindowShouldClose() do
    UpdateCamera(camera, CAMERA_FREE)
    BeginDrawing()
        ClearBackground(RAYWHITE)
        BeginMode3D(camera)
            DrawModel(model, position, 0.2, WHITE)
            DrawGrid(10, 1.0)
        EndMode3D()
        DrawText("(c) Watermill 3D model by Alberto Cano", screenWidth - 210, screenHeight - 20, 10, GRAY)
        DrawFPS(10, 10)
    EndDrawing()
end
UnloadShader(shader)
UnloadTexture(texture)
UnloadModel(model)
CloseWindow()
