-------------------------------------------------------------------------------------------
--
--  raylib [shaders] example - custom uniform
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local GLSL_VERSION = 330
local screenWidth, screenHeight = 800, 450
SetConfigFlags(FLAG_MSAA_4X_HINT)
InitWindow(screenWidth, screenHeight, "raylib [shaders] example - custom uniform")
local camera = Camera(Vector3(8, 8, 8), Vector3(0, 1.5, 0), Vector3(0, 1, 0), 45.0, CAMERA_PERSPECTIVE)
local model = LoadModel("resources/models/barracks.obj")
local texture = LoadTexture("resources/models/barracks_diffuse.png")
SetModelTexture(model, MATERIAL_MAP_DIFFUSE, texture)
local position = Vector3(0, 0, 0)
local shader = LoadShader(nil, TextFormat("resources/shaders/glsl%i/swirl.fs", GLSL_VERSION))
local swirlCenterLoc = GetShaderLocation(shader, "center")
local swirlCenter = { screenWidth/2, screenHeight/2 }
local target = LoadRenderTexture(screenWidth, screenHeight)
SetTargetFPS(60)

while not WindowShouldClose() do
    UpdateCamera(camera, CAMERA_ORBITAL)
    local mousePosition = GetMousePosition()
    swirlCenter[1] = mousePosition.x
    swirlCenter[2] = screenHeight - mousePosition.y
    SetShaderValue(shader, swirlCenterLoc, swirlCenter, SHADER_UNIFORM_VEC2)

    BeginTextureMode(target)
        ClearBackground(RAYWHITE)
        BeginMode3D(camera)
            DrawModel(model, position, 0.5, WHITE)
            DrawGrid(10, 1.0)
        EndMode3D()
        DrawText("TEXT DRAWN IN RENDER TEXTURE", 200, 10, 30, RED)
    EndTextureMode()

    BeginDrawing()
        ClearBackground(RAYWHITE)
        BeginShaderMode(shader)
            DrawTextureRec(target.texture, Rectangle(0, 0, target.texture.width, -target.texture.height), Vector2(0, 0), WHITE)
        EndShaderMode()
        DrawText("(c) Barracks 3D model by Alberto Cano", screenWidth - 220, screenHeight - 20, 10, GRAY)
        DrawFPS(10, 10)
    EndDrawing()
end
UnloadShader(shader)
UnloadTexture(texture)
UnloadModel(model)
UnloadRenderTexture(target)
CloseWindow()
