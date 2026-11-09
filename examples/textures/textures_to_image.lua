-------------------------------------------------------------------------------------------
--  raylib [textures] example - Texture to image
--  This example has been created using raylib 6.0 (www.raylib.com)
-------------------------------------------------------------------------------------------
local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [textures] example - to image")
local image = LoadImage("resources/raylib_logo.png")
local texture = LoadTextureFromImage(image)
UnloadImage(image)
image = LoadImageFromTexture(texture)
UnloadTexture(texture)
texture = LoadTextureFromImage(image)
UnloadImage(image)
SetTargetFPS(60)
while not WindowShouldClose() do
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawTexture(texture, screenWidth/2 - texture.width/2, screenHeight/2 - texture.height/2, WHITE)
        DrawText("this IS a texture loaded from an image!", 300, 370, 10, GRAY)
    EndDrawing()
end
UnloadTexture(texture)
CloseWindow()
