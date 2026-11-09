-------------------------------------------------------------------------------------------
--
--  raylib [shaders] example - postprocessing
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local GLSL_VERSION = 330
local MAX_POSTPRO_SHADERS = 12
local postproShaderText = {
    "GRAYSCALE", "POSTERIZATION", "DREAM_VISION", "PIXELIZER", "CROSS_HATCHING",
    "CROSS_STITCHING", "PREDATOR_VIEW", "SCANLINES", "FISHEYE", "SOBEL", "BLOOM", "BLUR"
}
local names = { "grayscale", "posterization", "dream_vision", "pixelizer", "cross_hatching",
    "cross_stitching", "predator", "scanlines", "fisheye", "sobel", "bloom", "blur" }

local screenWidth, screenHeight = 800, 450
SetConfigFlags(FLAG_MSAA_4X_HINT)
InitWindow(screenWidth, screenHeight, "raylib [shaders] example - postprocessing")
local camera = Camera(Vector3(2, 3, 2), Vector3(0, 1, 0), Vector3(0, 1, 0), 45.0, CAMERA_PERSPECTIVE)
local model = LoadModel("resources/models/church.obj")
local texture = LoadTexture("resources/models/church_diffuse.png")
SetModelTexture(model, MATERIAL_MAP_DIFFUSE, texture)
local position = Vector3(0, 0, 0)
local shaders = {}
for i, n in ipairs(names) do
    shaders[i] = LoadShader(nil, TextFormat("resources/shaders/glsl%i/%s.fs", GLSL_VERSION, n))
end
local currentShader = 1
local target = LoadRenderTexture(screenWidth, screenHeight)
SetTargetFPS(60)

while not WindowShouldClose() do
    UpdateCamera(camera, CAMERA_ORBITAL)
    if IsKeyPressed(KEY_RIGHT) then currentShader = currentShader + 1
    elseif IsKeyPressed(KEY_LEFT) then currentShader = currentShader - 1 end
    if currentShader > MAX_POSTPRO_SHADERS then currentShader = 1
    elseif currentShader < 1 then currentShader = MAX_POSTPRO_SHADERS end

    BeginTextureMode(target)
        ClearBackground(RAYWHITE)
        BeginMode3D(camera)
            DrawModel(model, position, 0.1, WHITE)
            DrawGrid(10, 1.0)
        EndMode3D()
    EndTextureMode()

    BeginDrawing()
        ClearBackground(RAYWHITE)
        BeginShaderMode(shaders[currentShader])
            DrawTextureRec(target.texture, Rectangle(0, 0, target.texture.width, -target.texture.height), Vector2(0, 0), WHITE)
        EndShaderMode()
        DrawRectangle(0, 9, 580, 30, Fade(LIGHTGRAY, 0.7))
        DrawText("(c) Church 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, GRAY)
        DrawText("CURRENT POSTPRO SHADER:", 10, 15, 20, BLACK)
        DrawText(postproShaderText[currentShader], 330, 15, 20, RED)
        DrawText("< >", 540, 10, 30, DARKBLUE)
        DrawFPS(700, 15)
    EndDrawing()
end
for i = 1, MAX_POSTPRO_SHADERS do UnloadShader(shaders[i]) end
UnloadTexture(texture)
UnloadModel(model)
UnloadRenderTexture(target)
CloseWindow()
