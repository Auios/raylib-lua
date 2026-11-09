-------------------------------------------------------------------------------------------
--
--  raylib [core] example - Mouse input
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth = 800
local screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - input mouse")

local ballPosition = Vector2(-100.0, -100.0)
local ballColor = DARKBLUE

SetTargetFPS(60)

while not WindowShouldClose() do
    if IsKeyPressed(KEY_H) then
        if IsCursorHidden() then ShowCursor() else HideCursor() end
    end

    ballPosition = GetMousePosition()

    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then ballColor = MAROON
    elseif IsMouseButtonPressed(MOUSE_BUTTON_MIDDLE) then ballColor = LIME
    elseif IsMouseButtonPressed(MOUSE_BUTTON_RIGHT) then ballColor = DARKBLUE
    elseif IsMouseButtonPressed(MOUSE_BUTTON_SIDE) then ballColor = PURPLE
    elseif IsMouseButtonPressed(MOUSE_BUTTON_EXTRA) then ballColor = YELLOW
    elseif IsMouseButtonPressed(MOUSE_BUTTON_FORWARD) then ballColor = ORANGE
    elseif IsMouseButtonPressed(MOUSE_BUTTON_BACK) then ballColor = BEIGE
    end

    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawCircleV(ballPosition, 40, ballColor)
        DrawText("move ball with mouse and click mouse button to change color", 10, 10, 20, DARKGRAY)
        DrawText("Press 'H' to toggle cursor visibility", 10, 30, 20, DARKGRAY)

        if IsCursorHidden() then DrawText("CURSOR HIDDEN", 20, 60, 20, RED)
        else DrawText("CURSOR VISIBLE", 20, 60, 20, LIME) end

    EndDrawing()
end

CloseWindow()
