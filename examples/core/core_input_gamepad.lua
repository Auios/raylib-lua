-------------------------------------------------------------------------------------------
--  raylib [core] example - Gamepad input
--  This example has been created using raylib 6.0 (www.raylib.com)
-------------------------------------------------------------------------------------------
local screenWidth, screenHeight = 800, 450
SetConfigFlags(FLAG_MSAA_4X_HINT)
InitWindow(screenWidth, screenHeight, "raylib [core] example - input gamepad")
local gamepad = 0
SetTargetFPS(60)

while not WindowShouldClose() do
    if IsKeyPressed(KEY_LEFT) and gamepad > 0 then gamepad = gamepad - 1 end
    if IsKeyPressed(KEY_RIGHT) then gamepad = gamepad + 1 end

    BeginDrawing()
        ClearBackground(RAYWHITE)
        if IsGamepadAvailable(gamepad) then
            DrawText(TextFormat("GP%d: %s", gamepad, GetGamepadName(gamepad)), 10, 10, 10, BLACK)
            DrawText(TextFormat("DETECTED AXIS: %i", GetGamepadAxisCount(gamepad)), 10, 50, 10, MAROON)
            for i = 0, GetGamepadAxisCount(gamepad) - 1 do
                DrawText(TextFormat("AXIS %i: %.02f", i, GetGamepadAxisMovement(gamepad, i)), 20, 70 + 20*i, 10, DARKGRAY)
            end
            if GetGamepadButtonPressed() ~= GAMEPAD_BUTTON_UNKNOWN then
                DrawText(TextFormat("DETECTED BUTTON: %i", GetGamepadButtonPressed()), 10, 430, 10, RED)
            else
                DrawText("DETECTED BUTTON: NONE", 10, 430, 10, GRAY)
            end
        else
            DrawText(TextFormat("GP%d: NOT DETECTED", gamepad), 10, 10, 10, GRAY)
            DrawText("Use LEFT/RIGHT to change gamepad id", 10, 30, 10, DARKGRAY)
        end
    EndDrawing()
end
CloseWindow()
