-------------------------------------------------------------------------------------------
--  raylib [core] example - Input gestures
--  This example has been created using raylib 6.0 (www.raylib.com)
-------------------------------------------------------------------------------------------
local MAX_GESTURE_STRINGS = 20
local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [core] example - input gestures")

local touchArea = Rectangle(220, 10, screenWidth - 230.0, screenHeight - 20.0)
local gestureStrings = {}
local currentGesture, lastGesture = GESTURE_NONE, GESTURE_NONE
SetTargetFPS(60)

local names = {
    [GESTURE_TAP] = "GESTURE TAP",
    [GESTURE_DOUBLETAP] = "GESTURE DOUBLETAP",
    [GESTURE_HOLD] = "GESTURE HOLD",
    [GESTURE_DRAG] = "GESTURE DRAG",
    [GESTURE_SWIPE_RIGHT] = "GESTURE SWIPE RIGHT",
    [GESTURE_SWIPE_LEFT] = "GESTURE SWIPE LEFT",
    [GESTURE_SWIPE_UP] = "GESTURE SWIPE UP",
    [GESTURE_SWIPE_DOWN] = "GESTURE SWIPE DOWN",
    [GESTURE_PINCH_IN] = "GESTURE PINCH IN",
    [GESTURE_PINCH_OUT] = "GESTURE PINCH OUT",
}

while not WindowShouldClose() do
    lastGesture = currentGesture
    currentGesture = GetGestureDetected()
    local touchPosition = GetTouchPosition(0)

    if CheckCollisionPointRec(touchPosition, touchArea) and currentGesture ~= GESTURE_NONE then
        if currentGesture ~= lastGesture then
            gestureStrings[#gestureStrings + 1] = names[currentGesture] or "GESTURE"
            if #gestureStrings >= MAX_GESTURE_STRINGS then gestureStrings = {} end
        end
    end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawRectangleRec(touchArea, GRAY)
        DrawRectangle(225, 15, screenWidth - 240, screenHeight - 30, RAYWHITE)
        DrawText("GESTURES TEST AREA", 240, 20, 20, Fade(GRAY, 0.5))
        for i, s in ipairs(gestureStrings) do
            if (i % 2) == 0 then DrawRectangle(10, 30 + 20*i, 200, 20, Fade(LIGHTGRAY, 0.5))
            else DrawRectangle(10, 30 + 20*i, 200, 20, Fade(LIGHTGRAY, 0.3)) end
            DrawText(s, 35, 36 + 20*i, 10, DARKGRAY)
        end
        DrawRectangleLines(220, 10, screenWidth - 230, screenHeight - 20, GRAY)
    EndDrawing()
end
CloseWindow()
