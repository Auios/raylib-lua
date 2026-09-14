-------------------------------------------------------------------------------------------
--
--  raylib [core] example - Drop files
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2015-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - drop files")

local filePaths = {}

SetTargetFPS(60)

while not WindowShouldClose() do
    if IsFileDropped() then
        local dropped = LoadDroppedFiles()
        for i = 1, #dropped do
            filePaths[#filePaths + 1] = dropped[i]
        end
    end

    BeginDrawing()

        ClearBackground(RAYWHITE)

        if #filePaths == 0 then
            DrawText("Drop your files to this window!", 100, 40, 20, DARKGRAY)
        else
            DrawText("Dropped files:", 100, 40, 20, DARKGRAY)
            for i = 1, #filePaths do
                if (i % 2) == 1 then DrawRectangle(0, 85 + 40*(i-1), screenWidth, 40, Fade(LIGHTGRAY, 0.5))
                else DrawRectangle(0, 85 + 40*(i-1), screenWidth, 40, Fade(LIGHTGRAY, 0.3)) end
                DrawText(filePaths[i], 120, 100 + 40*(i-1), 10, GRAY)
            end
            DrawText("Drop new files...", 100, 110 + 40*#filePaths, 20, DARKGRAY)
        end

    EndDrawing()
end

CloseWindow()
