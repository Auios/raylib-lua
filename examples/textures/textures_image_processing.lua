-------------------------------------------------------------------------------------------
--
--  raylib [textures] example - image processing
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local NUM_PROCESSES = 9
local NONE, COLOR_GRAYSCALE, COLOR_TINT, COLOR_INVERT, COLOR_CONTRAST = 0, 1, 2, 3, 4
local COLOR_BRIGHTNESS, GAUSSIAN_BLUR, FLIP_VERTICAL, FLIP_HORIZONTAL = 5, 6, 7, 8
local processText = {
    "NO PROCESSING", "COLOR GRAYSCALE", "COLOR TINT", "COLOR INVERT", "COLOR CONTRAST",
    "COLOR BRIGHTNESS", "GAUSSIAN BLUR", "FLIP VERTICAL", "FLIP HORIZONTAL"
}

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [textures] example - image processing")

local imOrigin = LoadImage("resources/parrots.png")
imOrigin = ImageFormat(imOrigin, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)
local texture = LoadTextureFromImage(imOrigin)
local imCopy = ImageCopy(imOrigin)
local currentProcess, textureReload, mouseHoverRec = NONE, false, -1
local toggleRecs = {}
for i = 0, NUM_PROCESSES - 1 do toggleRecs[i] = Rectangle(40, 50 + 32*i, 150, 30) end
SetTargetFPS(60)

while not WindowShouldClose() do
    for i = 0, NUM_PROCESSES - 1 do
        if CheckCollisionPointRec(GetMousePosition(), toggleRecs[i]) then
            mouseHoverRec = i
            if IsMouseButtonReleased(MOUSE_BUTTON_LEFT) then currentProcess = i; textureReload = true end
            break
        else mouseHoverRec = -1 end
    end

    if IsKeyPressed(KEY_DOWN) then
        currentProcess = currentProcess + 1
        if currentProcess > NUM_PROCESSES - 1 then currentProcess = 0 end
        textureReload = true
    elseif IsKeyPressed(KEY_UP) then
        currentProcess = currentProcess - 1
        if currentProcess < 0 then currentProcess = NUM_PROCESSES - 1 end
        textureReload = true
    end

    if textureReload then
        UnloadImage(imCopy)
        imCopy = ImageCopy(imOrigin)
        if currentProcess == COLOR_GRAYSCALE then imCopy = ImageColorGrayscale(imCopy)
        elseif currentProcess == COLOR_TINT then imCopy = ImageColorTint(imCopy, GREEN)
        elseif currentProcess == COLOR_INVERT then imCopy = ImageColorInvert(imCopy)
        elseif currentProcess == COLOR_CONTRAST then imCopy = ImageColorContrast(imCopy, -40)
        elseif currentProcess == COLOR_BRIGHTNESS then imCopy = ImageColorBrightness(imCopy, -80)
        elseif currentProcess == GAUSSIAN_BLUR then imCopy = ImageBlurGaussian(imCopy, 10)
        elseif currentProcess == FLIP_VERTICAL then imCopy = ImageFlipVertical(imCopy)
        elseif currentProcess == FLIP_HORIZONTAL then imCopy = ImageFlipHorizontal(imCopy) end
        UpdateTexture(texture, GetImageData(imCopy))
        textureReload = false
    end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText("IMAGE PROCESSING:", 40, 30, 10, DARKGRAY)
        for i = 0, NUM_PROCESSES - 1 do
            local active = (i == currentProcess) or (i == mouseHoverRec)
            DrawRectangleRec(toggleRecs[i], active and SKYBLUE or LIGHTGRAY)
            DrawRectangleLines(toggleRecs[i].x, toggleRecs[i].y, toggleRecs[i].width, toggleRecs[i].height, active and BLUE or GRAY)
            DrawText(processText[i + 1], toggleRecs[i].x + toggleRecs[i].width/2 - MeasureText(processText[i + 1], 10)/2, toggleRecs[i].y + 11, 10, active and DARKBLUE or DARKGRAY)
        end
        DrawTexture(texture, screenWidth - texture.width - 60, screenHeight/2 - texture.height/2, WHITE)
        DrawRectangleLines(screenWidth - texture.width - 60, screenHeight/2 - texture.height/2, texture.width, texture.height, BLACK)
    EndDrawing()
end
UnloadTexture(texture)
UnloadImage(imOrigin)
UnloadImage(imCopy)
CloseWindow()
