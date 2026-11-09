-------------------------------------------------------------------------------------------
--
--  raylib [shapes] example - colors palette
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local MAX_COLORS_COUNT = 21
local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [shapes] example - colors palette")

local colors = {
    DARKGRAY, MAROON, ORANGE, DARKGREEN, DARKBLUE, DARKPURPLE, DARKBROWN,
    GRAY, RED, GOLD, LIME, BLUE, VIOLET, BROWN, LIGHTGRAY, PINK, YELLOW,
    GREEN, SKYBLUE, PURPLE, BEIGE
}
local colorNames = {
    "DARKGRAY", "MAROON", "ORANGE", "DARKGREEN", "DARKBLUE", "DARKPURPLE",
    "DARKBROWN", "GRAY", "RED", "GOLD", "LIME", "BLUE", "VIOLET", "BROWN",
    "LIGHTGRAY", "PINK", "YELLOW", "GREEN", "SKYBLUE", "PURPLE", "BEIGE"
}
local colorsRecs, colorState = {}, {}
for i = 0, MAX_COLORS_COUNT - 1 do
    colorsRecs[i] = Rectangle(20 + 100*(i % 7) + 10*(i % 7), 80 + 100*(i // 7) + 10*(i / 7), 100, 100)
    colorState[i] = 0
end
SetTargetFPS(60)

while not WindowShouldClose() do
    local mousePoint = GetMousePosition()
    for i = 0, MAX_COLORS_COUNT - 1 do
        if CheckCollisionPointRec(mousePoint, colorsRecs[i]) then colorState[i] = 1 else colorState[i] = 0 end
    end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText("raylib colors palette", 28, 42, 20, BLACK)
        DrawText("press SPACE to see all colors", GetScreenWidth() - 180, GetScreenHeight() - 40, 10, GRAY)
        for i = 0, MAX_COLORS_COUNT - 1 do
            DrawRectangleRec(colorsRecs[i], Fade(colors[i + 1], colorState[i] ~= 0 and 0.6 or 1.0))
            if IsKeyDown(KEY_SPACE) or colorState[i] ~= 0 then
                DrawRectangle(colorsRecs[i].x, colorsRecs[i].y + colorsRecs[i].height - 26, colorsRecs[i].width, 20, BLACK)
                DrawRectangleLinesEx(colorsRecs[i], 6, Fade(BLACK, 0.3))
                DrawText(colorNames[i + 1], colorsRecs[i].x + colorsRecs[i].width - MeasureText(colorNames[i + 1], 10) - 12,
                    colorsRecs[i].y + colorsRecs[i].height - 20, 10, colors[i + 1])
            end
        end
    EndDrawing()
end
CloseWindow()
