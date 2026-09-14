-------------------------------------------------------------------------------------------
--  raylib [shapes] example - Cubic-bezier lines
--  This example has been created using raylib 6.0 (www.raylib.com)
-------------------------------------------------------------------------------------------
local screenWidth, screenHeight = 800, 450
SetConfigFlags(FLAG_MSAA_4X_HINT)
InitWindow(screenWidth, screenHeight, "raylib [shapes] example - lines bezier")
local startPoint = Vector2(30, 30)
local endPoint = Vector2(screenWidth - 30, screenHeight - 30)
local moveStartPoint, moveEndPoint = false, false
SetTargetFPS(60)
while not WindowShouldClose() do
    local mouse = GetMousePosition()
    if CheckCollisionPointCircle(mouse, startPoint, 10.0) and IsMouseButtonDown(MOUSE_BUTTON_LEFT) then moveStartPoint = true
    elseif CheckCollisionPointCircle(mouse, endPoint, 10.0) and IsMouseButtonDown(MOUSE_BUTTON_LEFT) then moveEndPoint = true end
    if moveStartPoint then
        startPoint = mouse
        if IsMouseButtonReleased(MOUSE_BUTTON_LEFT) then moveStartPoint = false end
    end
    if moveEndPoint then
        endPoint = mouse
        if IsMouseButtonReleased(MOUSE_BUTTON_LEFT) then moveEndPoint = false end
    end
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawText("MOVE START-END POINTS WITH MOUSE", 15, 20, 20, GRAY)
        DrawLineBezier(startPoint, endPoint, 4.0, BLUE)
        DrawCircleV(startPoint, CheckCollisionPointCircle(mouse, startPoint, 10.0) and 14.0 or 8.0, moveStartPoint and RED or BLUE)
        DrawCircleV(endPoint, CheckCollisionPointCircle(mouse, endPoint, 10.0) and 14.0 or 8.0, moveEndPoint and RED or BLUE)
    EndDrawing()
end
CloseWindow()
