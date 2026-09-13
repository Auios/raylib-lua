-------------------------------------------------------------------------------------------
--
--  raylib [text] example - sprite fonts
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local MAX_FONTS = 8
local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [text] example - sprite fonts")
local fonts = {
    LoadFont("resources/sprite_fonts/alagard.png"),
    LoadFont("resources/sprite_fonts/pixelplay.png"),
    LoadFont("resources/sprite_fonts/mecha.png"),
    LoadFont("resources/sprite_fonts/setback.png"),
    LoadFont("resources/sprite_fonts/romulus.png"),
    LoadFont("resources/sprite_fonts/pixantiqua.png"),
    LoadFont("resources/sprite_fonts/alpha_beta.png"),
    LoadFont("resources/sprite_fonts/jupiter_crash.png"),
}
local messages = {
    "ALAGARD FONT designed by Hewett Tsoi",
    "PIXELPLAY FONT designed by Aleksander Shevchuk",
    "MECHA FONT designed by Captain Falcon",
    "SETBACK FONT designed by Brian Kent (AEnigma)",
    "ROMULUS FONT designed by Hewett Tsoi",
    "PIXANTIQUA FONT designed by Gerhard Grossmann",
    "ALPHA_BETA FONT designed by Brian Kent (AEnigma)",
    "JUPITER_CRASH FONT designed by Brian Kent (AEnigma)",
}
local spacings = { 2, 4, 8, 4, 3, 4, 4, 1 }
local colors = { MAROON, ORANGE, DARKGREEN, DARKBLUE, DARKPURPLE, LIME, GOLD, RED }
local positions = {}
for i = 1, MAX_FONTS do
    positions[i] = Vector2(
        screenWidth/2 - MeasureTextEx(fonts[i], messages[i], fonts[i].baseSize*2.0, spacings[i]).x/2,
        60 + fonts[i].baseSize + 45*(i - 1))
end
positions[4].y = positions[4].y + 8
positions[5].y = positions[5].y + 2
positions[8].y = positions[8].y - 8
SetTargetFPS(60)

while not WindowShouldClose() do
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText("free sprite fonts included with raylib", 220, 20, 20, DARKGRAY)
        DrawLine(220, 50, 600, 50, DARKGRAY)
        for i = 1, MAX_FONTS do
            DrawTextEx(fonts[i], messages[i], positions[i], fonts[i].baseSize*2.0, spacings[i], colors[i])
        end
    EndDrawing()
end
for i = 1, MAX_FONTS do UnloadFont(fonts[i]) end
CloseWindow()
