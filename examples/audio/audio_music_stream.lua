-------------------------------------------------------------------------------------------
--
--  raylib [audio] example - music stream
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [audio] example - music stream")
InitAudioDevice()
local music = LoadMusicStream("resources/country.mp3")
PlayMusicStream(music)
local timePlayed, pause, pan, volume = 0.0, false, 0.0, 0.8
SetMusicPan(music, pan)
SetMusicVolume(music, volume)
SetTargetFPS(30)

while not WindowShouldClose() do
    UpdateMusicStream(music)
    if IsKeyPressed(KEY_SPACE) then StopMusicStream(music); PlayMusicStream(music) end
    if IsKeyPressed(KEY_P) then
        pause = not pause
        if pause then PauseMusicStream(music) else ResumeMusicStream(music) end
    end
    if IsKeyDown(KEY_LEFT) then pan = pan - 0.05; if pan < -1 then pan = -1 end; SetMusicPan(music, pan)
    elseif IsKeyDown(KEY_RIGHT) then pan = pan + 0.05; if pan > 1 then pan = 1 end; SetMusicPan(music, pan) end
    if IsKeyDown(KEY_DOWN) then volume = volume - 0.05; if volume < 0 then volume = 0 end; SetMusicVolume(music, volume)
    elseif IsKeyDown(KEY_UP) then volume = volume + 0.05; if volume > 1 then volume = 1 end; SetMusicVolume(music, volume) end
    timePlayed = GetMusicTimePlayed(music)/GetMusicTimeLength(music)
    if timePlayed > 1 then timePlayed = 1 end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText("MUSIC SHOULD BE PLAYING!", 255, 150, 20, LIGHTGRAY)
        DrawText("LEFT-RIGHT for PAN CONTROL", 320, 74, 10, DARKBLUE)
        DrawRectangle(300, 100, 200, 12, LIGHTGRAY)
        DrawRectangleLines(300, 100, 200, 12, GRAY)
        DrawRectangle(300 + (pan + 1)/2*200 - 5, 92, 10, 28, DARKGRAY)
        DrawRectangle(200, 200, 400, 12, LIGHTGRAY)
        DrawRectangle(200, 200, timePlayed*400, 12, MAROON)
        DrawRectangleLines(200, 200, 400, 12, GRAY)
        DrawText("PRESS SPACE TO RESTART MUSIC", 215, 250, 20, LIGHTGRAY)
        DrawText("PRESS P TO PAUSE/RESUME MUSIC", 208, 280, 20, LIGHTGRAY)
        DrawText("UP-DOWN for VOLUME CONTROL", 320, 334, 10, DARKGREEN)
        DrawRectangle(300, 360, 200, 12, LIGHTGRAY)
        DrawRectangleLines(300, 360, 200, 12, GRAY)
        DrawRectangle(300 + volume*200 - 5, 352, 10, 28, DARKGRAY)
    EndDrawing()
end
UnloadMusicStream(music)
CloseAudioDevice()
CloseWindow()
