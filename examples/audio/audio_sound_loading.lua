-------------------------------------------------------------------------------------------
--
--  raylib [audio] example - sound loading
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [audio] example - sound loading")
InitAudioDevice()
local fxWav = LoadSound("resources/sound.wav")
local fxOgg = LoadSound("resources/target.ogg")
SetTargetFPS(60)
while not WindowShouldClose() do
    if IsKeyPressed(KEY_SPACE) then PlaySound(fxWav) end
    if IsKeyPressed(KEY_ENTER) then PlaySound(fxOgg) end
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText("Press SPACE to PLAY the WAV sound!", 200, 180, 20, LIGHTGRAY)
        DrawText("Press ENTER to PLAY the OGG sound!", 200, 220, 20, LIGHTGRAY)
    EndDrawing()
end
UnloadSound(fxWav)
UnloadSound(fxOgg)
CloseAudioDevice()
CloseWindow()
