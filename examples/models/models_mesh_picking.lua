-------------------------------------------------------------------------------------------
--
--  raylib [models] example - mesh picking
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [models] example - mesh picking")
local camera = Camera(Vector3(20, 20, 20), Vector3(0, 8, 0), Vector3(0, 1.6, 0), 45.0, CAMERA_PERSPECTIVE)
local tower = LoadModel("resources/models/obj/turret.obj")
local texture = LoadTexture("resources/models/obj/turret_diffuse.png")
SetModelTexture(tower, MATERIAL_MAP_DIFFUSE, texture)
local towerPos = Vector3(0, 0, 0)
local towerBBox = GetModelBoundingBox(tower)
local g0, g1, g2, g3 = Vector3(-50, 0, -50), Vector3(-50, 0, 50), Vector3(50, 0, 50), Vector3(50, 0, -50)
local ta, tb, tc = Vector3(-25, 0.5, 0), Vector3(-4, 2.5, 1), Vector3(-8, 6.5, 0)
local bary = Vector3(0, 0, 0)
local sp, sr = Vector3(-30, 5, 5), 4.0
SetTargetFPS(60)

while not WindowShouldClose() do
    if IsCursorHidden() then UpdateCamera(camera, CAMERA_FIRST_PERSON) end
    if IsMouseButtonPressed(MOUSE_BUTTON_RIGHT) then
        if IsCursorHidden() then EnableCursor() else DisableCursor() end
    end

    local collision = { hit = false, distance = math.huge, point = Vector3(0, 0, 0), normal = Vector3(0, 0, 0) }
    local hitObjectName, cursorColor = "None", WHITE
    local ray = GetScreenToWorldRay(GetMousePosition(), camera)

    local groundHitInfo = GetRayCollisionQuad(ray, g0, g1, g2, g3)
    if groundHitInfo.hit and groundHitInfo.distance < collision.distance then
        collision = groundHitInfo; cursorColor = GREEN; hitObjectName = "Ground"
    end
    local triHitInfo = GetRayCollisionTriangle(ray, ta, tb, tc)
    if triHitInfo.hit and triHitInfo.distance < collision.distance then
        collision = triHitInfo; cursorColor = PURPLE; hitObjectName = "Triangle"
        bary = Vector3Barycenter(collision.point, ta, tb, tc)
    end
    local sphereHitInfo = GetRayCollisionSphere(ray, sp, sr)
    if sphereHitInfo.hit and sphereHitInfo.distance < collision.distance then
        collision = sphereHitInfo; cursorColor = ORANGE; hitObjectName = "Sphere"
    end
    local boxHitInfo = GetRayCollisionBox(ray, towerBBox)
    local meshHitInfo = { hit = false }
    if boxHitInfo.hit and boxHitInfo.distance < collision.distance then
        collision = boxHitInfo; cursorColor = ORANGE; hitObjectName = "Box"
        for m = 0, tower.meshCount - 1 do
            meshHitInfo = GetRayCollisionMesh(ray, GetModelMesh(tower, m), tower.transform)
            if meshHitInfo.hit then
                if (not collision.hit) or (collision.distance > meshHitInfo.distance) then collision = meshHitInfo end
                break
            end
        end
        if meshHitInfo.hit then
            collision = meshHitInfo; cursorColor = ORANGE; hitObjectName = "Mesh"
        end
    end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        BeginMode3D(camera)
            DrawModel(tower, towerPos, 1.0, WHITE)
            DrawLine3D(ta, tb, PURPLE); DrawLine3D(tb, tc, PURPLE); DrawLine3D(tc, ta, PURPLE)
            DrawSphereWires(sp, sr, 8, 8, PURPLE)
            if boxHitInfo.hit then DrawBoundingBox(towerBBox, LIME) end
            if collision.hit then
                DrawCube(collision.point, 0.3, 0.3, 0.3, cursorColor)
                DrawCubeWires(collision.point, 0.3, 0.3, 0.3, RED)
                DrawLine3D(collision.point, Vector3(collision.point.x + collision.normal.x, collision.point.y + collision.normal.y, collision.point.z + collision.normal.z), RED)
            end
            DrawRay(ray, MAROON)
            DrawGrid(10, 10.0)
        EndMode3D()
        DrawText(TextFormat("Hit Object: %s", hitObjectName), 10, 50, 10, BLACK)
        if collision.hit then
            DrawText(TextFormat("Distance: %3.2f", collision.distance), 10, 70, 10, BLACK)
            DrawText(TextFormat("Hit Pos: %3.2f %3.2f %3.2f", collision.point.x, collision.point.y, collision.point.z), 10, 85, 10, BLACK)
            DrawText(TextFormat("Hit Norm: %3.2f %3.2f %3.2f", collision.normal.x, collision.normal.y, collision.normal.z), 10, 100, 10, BLACK)
            if triHitInfo.hit and hitObjectName == "Triangle" then
                DrawText(TextFormat("Barycenter: %3.2f %3.2f %3.2f", bary.x, bary.y, bary.z), 10, 115, 10, BLACK)
            end
        end
        DrawText("Right click mouse to toggle camera controls", 10, 430, 10, GRAY)
        DrawText("(c) Turret 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, GRAY)
        DrawFPS(10, 10)
    EndDrawing()
end
UnloadModel(tower)
UnloadTexture(texture)
CloseWindow()
