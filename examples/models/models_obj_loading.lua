-------------------------------------------------------------------------------------------
--
--  raylib [models] example - loading
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [models] example - loading")
local camera = Camera(Vector3(50, 50, 50), Vector3(0, 12, 0), Vector3(0, 1, 0), 45.0, CAMERA_PERSPECTIVE)
local model = LoadModel("resources/models/obj/castle.obj")
local texture = LoadTexture("resources/models/obj/castle_diffuse.png")
SetModelTexture(model, MATERIAL_MAP_DIFFUSE, texture)
local position = Vector3(0, 0, 0)
local bounds = GetModelBoundingBox(model)
local selected = false
SetTargetFPS(60)

while not WindowShouldClose() do
    UpdateCamera(camera, CAMERA_ORBITAL)
    if IsFileDropped() then
        local droppedFiles = LoadDroppedFiles()
        if #droppedFiles == 1 then
            local path = droppedFiles[1]
            if IsFileExtension(path, ".obj") or IsFileExtension(path, ".gltf") or IsFileExtension(path, ".glb")
                or IsFileExtension(path, ".vox") or IsFileExtension(path, ".iqm") or IsFileExtension(path, ".m3d") then
                UnloadModel(model)
                model = LoadModel(path)
                SetModelTexture(model, MATERIAL_MAP_DIFFUSE, texture)
                bounds = GetModelBoundingBox(model)
                camera.position.x = bounds.max.x + 10
                camera.position.y = bounds.max.y + 10
                camera.position.z = bounds.max.z + 10
            elseif IsFileExtension(path, ".png") then
                UnloadTexture(texture)
                texture = LoadTexture(path)
                SetModelTexture(model, MATERIAL_MAP_DIFFUSE, texture)
            end
        end
    end
    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
        if GetRayCollisionBox(GetScreenToWorldRay(GetMousePosition(), camera), bounds).hit then selected = not selected
        else selected = false end
    end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        BeginMode3D(camera)
            DrawModel(model, position, 1.0, WHITE)
            DrawGrid(20, 10.0)
            if selected then DrawBoundingBox(bounds, GREEN) end
        EndMode3D()
        DrawText("Drag & drop model to load mesh/texture.", 10, GetScreenHeight() - 20, 10, DARKGRAY)
        if selected then DrawText("MODEL SELECTED", GetScreenWidth() - 110, 10, 10, GREEN) end
        DrawText("(c) Castle 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, GRAY)
        DrawFPS(10, 10)
    EndDrawing()
end
UnloadTexture(texture)
UnloadModel(model)
CloseWindow()
