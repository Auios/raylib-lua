-------------------------------------------------------------------------------------------
--
--  raylib [audio] example - module playing
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local MAX_CIRCLES = 64
local screenWidth, screenHeight = 800, 450
SetConfigFlags(FLAG_MSAA_4X_HINT)
InitWindow(screenWidth, screenHeight, "raylib [audio] example - module playing")
InitAudioDevice()
local colors = { ORANGE, RED, GOLD, LIME, BLUE, VIOLET, BROWN, LIGHTGRAY, PINK, YELLOW, GREEN, SKYBLUE, PURPLE, BEIGE }
local circles = {}
for i = MAX_CIRCLES, 1, -1 do
    local radius = GetRandomValue(10, 40)
    circles[i] = {
        alpha = 0.0, radius = radius,
        position = Vector2(GetRandomValue(radius, screenWidth - radius), GetRandomValue(radius, screenHeight - radius)),
        speed = GetRandomValue(1, 100)/2000.0, color = colors[GetRandomValue(1, 14)]
    }
end
local music = LoadMusicStream("resources/mini1111.xm")
music.looping = false
local pitch, timePlayed, pause = 1.0, 0.0, false
PlayMusicStream(music)
SetTargetFPS(60)

while not WindowShouldClose() do
    UpdateMusicStream(music)
    if IsKeyPressed(KEY_SPACE) then StopMusicStream(music); PlayMusicStream(music); pause = false end
    if IsKeyPressed(KEY_P) then
        pause = not pause
        if pause then PauseMusicStream(music) else ResumeMusicStream(music) end
    end
    if IsKeyDown(KEY_DOWN) then pitch = pitch - 0.01 elseif IsKeyDown(KEY_UP) then pitch = pitch + 0.01 end
    SetMusicPitch(music, pitch)
    timePlayed = GetMusicTimePlayed(music)/GetMusicTimeLength(music)*(screenWidth - 40)
    if not pause then
        for i = MAX_CIRCLES, 1, -1 do
            local c = circles[i]
            c.alpha = c.alpha + c.speed
            c.radius = c.radius + c.speed*10
            if c.alpha > 1.0 then c.speed = c.speed * -1 end
            if c.alpha <= 0.0 then
                c.alpha = 0.0
                c.radius = GetRandomValue(10, 40)
                c.position.x = GetRandomValue(c.radius, screenWidth - c.radius)
                c.position.y = GetRandomValue(c.radius, screenHeight - c.radius)
                c.color = colors[GetRandomValue(1, 14)]
                c.speed = GetRandomValue(1, 100)/2000.0
            end
        end
    end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        for i = MAX_CIRCLES, 1, -1 do
            DrawCircleV(circles[i].position, circles[i].radius, Fade(circles[i].color, circles[i].alpha))
        end
        DrawRectangle(20, screenHeight - 32, screenWidth - 40, 12, LIGHTGRAY)
        DrawRectangle(20, screenHeight - 32, timePlayed, 12, MAROON)
        DrawRectangleLines(20, screenHeight - 32, screenWidth - 40, 12, GRAY)
        DrawRectangle(20, 20, 425, 145, WHITE)
        DrawRectangleLines(20, 20, 425, 145, GRAY)
        DrawText("PRESS SPACE TO RESTART MUSIC", 40, 40, 20, BLACK)
        DrawText("PRESS P TO PAUSE/RESUME", 40, 70, 20, BLACK)
        DrawText("PRESS UP/DOWN TO CHANGE SPEED", 40, 100, 20, BLACK)
        DrawText(TextFormat("SPEED: %f", pitch), 40, 130, 20, MAROON)
    EndDrawing()
end
UnloadMusicStream(music)
CloseAudioDevice()
CloseWindow()
