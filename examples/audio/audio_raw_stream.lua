-------------------------------------------------------------------------------------------
--
--  raylib [audio] example - raw stream
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local BUFFER_SIZE, SAMPLE_RATE = 4096, 44100
local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [audio] example - raw stream")
InitAudioDevice()
SetAudioStreamBufferSizeDefault(BUFFER_SIZE)
local stream = LoadAudioStream(SAMPLE_RATE, 32, 1)
local pan = 0.0
SetAudioStreamPan(stream, pan)
PlayAudioStream(stream)
local sineFrequency, newSineFrequency, sineIndex, sineStartTime = 440, 440, 0, 0.0
SetTargetFPS(30)

while not WindowShouldClose() do
    if IsKeyDown(KEY_UP) then newSineFrequency = newSineFrequency + 10; if newSineFrequency > 12500 then newSineFrequency = 12500 end end
    if IsKeyDown(KEY_DOWN) then newSineFrequency = newSineFrequency - 10; if newSineFrequency < 20 then newSineFrequency = 20 end end
    if IsKeyDown(KEY_LEFT) then pan = pan - 0.01; if pan < -1 then pan = -1 end; SetAudioStreamPan(stream, pan) end
    if IsKeyDown(KEY_RIGHT) then pan = pan + 0.01; if pan > 1 then pan = 1 end; SetAudioStreamPan(stream, pan) end

    if IsAudioStreamProcessed(stream) then
        local buffer = {}
        for i = 1, BUFFER_SIZE do
            local wavelength = SAMPLE_RATE // sineFrequency
            buffer[i] = math.sin(2*PI*sineIndex/wavelength)
            sineIndex = sineIndex + 1
            if sineIndex >= wavelength then
                sineFrequency = newSineFrequency
                sineIndex = 0
                sineStartTime = GetTime()
            end
        end
        UpdateAudioStream(stream, buffer, BUFFER_SIZE)
    end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText(TextFormat("sine frequency: %i", sineFrequency), screenWidth - 220, 10, 20, RED)
        DrawText(TextFormat("pan: %.2f", pan), screenWidth - 220, 30, 20, RED)
        DrawText("Up/down to change frequency", 10, 10, 20, DARKGRAY)
        DrawText("Left/right to pan", 10, 30, 20, DARKGRAY)
        local windowStart = (GetTime() - sineStartTime)*SAMPLE_RATE
        local windowSize = math.floor(0.1*SAMPLE_RATE)
        local wavelength = SAMPLE_RATE // sineFrequency
        for i = 0, screenWidth - 1 do
            local t0 = windowStart + i*windowSize/screenWidth
            local t1 = windowStart + (i + 1)*windowSize/screenWidth
            DrawLineV(Vector2(i, 250 + 50*math.sin(2*PI*t0/wavelength)), Vector2(i + 1, 250 + 50*math.sin(2*PI*t1/wavelength)), RED)
        end
    EndDrawing()
end
UnloadAudioStream(stream)
CloseAudioDevice()
CloseWindow()
