-------------------------------------------------------------------------------------------
--
--  raylib [models] example - box collisions
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [models] example - box collisions")
local camera = Camera(Vector3(0, 10, 10), Vector3(0, 0, 0), Vector3(0, 1, 0), 45.0)
local playerPosition, playerSize, playerColor = Vector3(0, 1, 2), Vector3(1, 2, 1), GREEN
local enemyBoxPos, enemyBoxSize = Vector3(-4, 1, 0), Vector3(2, 2, 2)
local enemySpherePos, enemySphereSize = Vector3(4, 0, 0), 1.5
SetTargetFPS(60)

while not WindowShouldClose() do
    if IsKeyDown(KEY_RIGHT) then playerPosition.x = playerPosition.x + 0.2
    elseif IsKeyDown(KEY_LEFT) then playerPosition.x = playerPosition.x - 0.2
    elseif IsKeyDown(KEY_DOWN) then playerPosition.z = playerPosition.z + 0.2
    elseif IsKeyDown(KEY_UP) then playerPosition.z = playerPosition.z - 0.2 end

    local playerBox = BoundingBox(
        Vector3(playerPosition.x - playerSize.x/2, playerPosition.y - playerSize.y/2, playerPosition.z - playerSize.z/2),
        Vector3(playerPosition.x + playerSize.x/2, playerPosition.y + playerSize.y/2, playerPosition.z + playerSize.z/2))
    local enemyBox = BoundingBox(
        Vector3(enemyBoxPos.x - enemyBoxSize.x/2, enemyBoxPos.y - enemyBoxSize.y/2, enemyBoxPos.z - enemyBoxSize.z/2),
        Vector3(enemyBoxPos.x + enemyBoxSize.x/2, enemyBoxPos.y + enemyBoxSize.y/2, enemyBoxPos.z + enemyBoxSize.z/2))
    local collision = CheckCollisionBoxes(playerBox, enemyBox) or CheckCollisionBoxSphere(playerBox, enemySpherePos, enemySphereSize)
    playerColor = collision and RED or GREEN

    BeginDrawing()
        ClearBackground(RAYWHITE)
        BeginMode3D(camera)
            DrawCube(enemyBoxPos, enemyBoxSize.x, enemyBoxSize.y, enemyBoxSize.z, GRAY)
            DrawCubeWires(enemyBoxPos, enemyBoxSize.x, enemyBoxSize.y, enemyBoxSize.z, DARKGRAY)
            DrawSphere(enemySpherePos, enemySphereSize, GRAY)
            DrawSphereWires(enemySpherePos, enemySphereSize, 16, 16, DARKGRAY)
            DrawCubeV(playerPosition, playerSize, playerColor)
            DrawGrid(10, 1.0)
        EndMode3D()
        DrawText("Move player with arrow keys to collide", 220, 40, 20, GRAY)
        DrawFPS(10, 10)
    EndDrawing()
end
CloseWindow()
