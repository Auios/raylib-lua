-------------------------------------------------------------------------------------------
--  raylib [shapes] example - raylib logo animation
--  This example has been created using raylib 6.0 (www.raylib.com)
-------------------------------------------------------------------------------------------
local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [shapes] example - logo raylib anim")
local logoPositionX, logoPositionY = screenWidth/2 - 128, screenHeight/2 - 128
local framesCounter, lettersCount = 0, 0
local topSideRecWidth, leftSideRecHeight = 16, 16
local bottomSideRecWidth, rightSideRecHeight = 16, 16
local state, alpha = 0, 1.0
SetTargetFPS(60)
while not WindowShouldClose() do
    if state == 0 then
        framesCounter = framesCounter + 1
        if framesCounter == 120 then state = 1; framesCounter = 0 end
    elseif state == 1 then
        topSideRecWidth = topSideRecWidth + 4
        leftSideRecHeight = leftSideRecHeight + 4
        if topSideRecWidth == 256 then state = 2 end
    elseif state == 2 then
        bottomSideRecWidth = bottomSideRecWidth + 4
        rightSideRecHeight = rightSideRecHeight + 4
        if bottomSideRecWidth == 256 then state = 3 end
    elseif state == 3 then
        framesCounter = framesCounter + 1
        if framesCounter/12 >= 1 then lettersCount = lettersCount + 1; framesCounter = 0 end
        if lettersCount >= 10 then
            alpha = alpha - 0.02
            if alpha <= 0.0 then alpha = 0.0; state = 4 end
        end
    elseif state == 4 then
        if IsKeyPressed(KEY_R) then
            framesCounter, lettersCount = 0, 0
            topSideRecWidth, leftSideRecHeight = 16, 16
            bottomSideRecWidth, rightSideRecHeight = 16, 16
            alpha, state = 1.0, 0
        end
    end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        if state == 0 then
            if (framesCounter//15)%2 == 1 then DrawRectangle(logoPositionX, logoPositionY, 16, 16, BLACK) end
        elseif state == 1 then
            DrawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, BLACK)
            DrawRectangle(logoPositionX, logoPositionY, 16, leftSideRecHeight, BLACK)
        elseif state == 2 then
            DrawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, BLACK)
            DrawRectangle(logoPositionX, logoPositionY, 16, leftSideRecHeight, BLACK)
            DrawRectangle(logoPositionX + 240, logoPositionY, 16, rightSideRecHeight, BLACK)
            DrawRectangle(logoPositionX, logoPositionY + 240, bottomSideRecWidth, 16, BLACK)
        elseif state == 3 then
            DrawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, Fade(BLACK, alpha))
            DrawRectangle(logoPositionX, logoPositionY + 16, 16, leftSideRecHeight - 32, Fade(BLACK, alpha))
            DrawRectangle(logoPositionX + 240, logoPositionY + 16, 16, rightSideRecHeight - 32, Fade(BLACK, alpha))
            DrawRectangle(logoPositionX, logoPositionY + 240, bottomSideRecWidth, 16, Fade(BLACK, alpha))
            DrawRectangle(GetScreenWidth()/2 - 112, GetScreenHeight()/2 - 112, 224, 224, Fade(RAYWHITE, alpha))
            DrawText(TextSubtext("raylib", 0, lettersCount), GetScreenWidth()/2 - 44, GetScreenHeight()/2 + 48, 50, Fade(BLACK, alpha))
        elseif state == 4 then
            DrawText("[R] REPLAY", 340, 200, 20, GRAY)
        end
    EndDrawing()
end
CloseWindow()
