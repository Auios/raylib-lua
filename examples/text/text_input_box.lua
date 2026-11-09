-------------------------------------------------------------------------------------------
--
--  raylib [text] example - input box
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local MAX_INPUT_CHARS = 9
local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [text] example - input box")
local name, letterCount = "", 0
local textBox = Rectangle(screenWidth/2 - 100, 180, 225, 50)
local mouseOnText, framesCounter = false, 0
SetTargetFPS(60)

while not WindowShouldClose() do
    mouseOnText = CheckCollisionPointRec(GetMousePosition(), textBox)
    if mouseOnText then
        SetMouseCursor(MOUSE_CURSOR_IBEAM)
        local key = GetCharPressed()
        while key > 0 do
            if key >= 32 and key <= 125 and letterCount < MAX_INPUT_CHARS then
                name = name .. string.char(key)
                letterCount = letterCount + 1
            end
            key = GetCharPressed()
        end
        if IsKeyPressed(KEY_BACKSPACE) then
            letterCount = letterCount - 1
            if letterCount < 0 then letterCount = 0 end
            name = string.sub(name, 1, letterCount)
        end
        framesCounter = framesCounter + 1
    else
        SetMouseCursor(MOUSE_CURSOR_DEFAULT)
        framesCounter = 0
    end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText("PLACE MOUSE OVER INPUT BOX!", 240, 140, 20, GRAY)
        DrawRectangleRec(textBox, LIGHTGRAY)
        DrawRectangleLines(textBox.x, textBox.y, textBox.width, textBox.height, mouseOnText and RED or DARKGRAY)
        DrawText(name, textBox.x + 5, textBox.y + 8, 40, MAROON)
        DrawText(TextFormat("INPUT CHARS: %i/%i", letterCount, MAX_INPUT_CHARS), 315, 250, 20, DARKGRAY)
        if mouseOnText then
            if letterCount < MAX_INPUT_CHARS then
                if (framesCounter//20) % 2 == 0 then
                    DrawText("_", textBox.x + 8 + MeasureText(name, 40), textBox.y + 12, 40, MAROON)
                end
            else DrawText("Press BACKSPACE to delete chars...", 230, 300, 20, GRAY) end
        end
    EndDrawing()
end
CloseWindow()
