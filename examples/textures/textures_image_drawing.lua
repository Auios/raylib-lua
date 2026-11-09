-------------------------------------------------------------------------------------------
--
--  raylib [textures] example - image drawing
--
--  This example has been created using raylib 6.0 (www.raylib.com)
--
--  Copyright (c) 2014-2026 Ramon Santamaria (@raysan5)
--
-------------------------------------------------------------------------------------------

local screenWidth, screenHeight = 800, 450
InitWindow(screenWidth, screenHeight, "raylib [textures] example - image drawing")

local cat = LoadImage("resources/cat.png")
cat = ImageCrop(cat, Rectangle(100, 10, 280, 380))
cat = ImageFlipHorizontal(cat)
cat = ImageResize(cat, 150, 200)

local parrots = LoadImage("resources/parrots.png")
parrots = ImageDraw(parrots, cat, Rectangle(0, 0, cat.width, cat.height), Rectangle(30, 40, cat.width*1.5, cat.height*1.5), WHITE)
parrots = ImageCrop(parrots, Rectangle(0, 50, parrots.width, parrots.height - 100))
parrots = ImageDrawPixel(parrots, 10, 10, RAYWHITE)
parrots = ImageDrawCircleLines(parrots, 10, 10, 5, RAYWHITE)
parrots = ImageDrawRectangle(parrots, 5, 20, 10, 10, RAYWHITE)
UnloadImage(cat)

local font = LoadFont("resources/custom_jupiter_crash.png")
parrots = ImageDrawTextEx(parrots, font, "PARROTS & CAT", Vector2(300, 230), font.baseSize, -2, WHITE)
UnloadFont(font)

local texture = LoadTextureFromImage(parrots)
UnloadImage(parrots)
SetTargetFPS(60)

while not WindowShouldClose() do
    BeginDrawing()
        ClearBackground(RAYWHITE)
        DrawTexture(texture, screenWidth/2 - texture.width/2, screenHeight/2 - texture.height/2 - 40, WHITE)
        DrawRectangleLines(screenWidth/2 - texture.width/2, screenHeight/2 - texture.height/2 - 40, texture.width, texture.height, DARKGRAY)
        DrawText("We are drawing only one texture from various images composed!", 240, 350, 10, DARKGRAY)
        DrawText("Source images have been cropped, scaled, flipped and copied one over the other.", 190, 370, 10, DARKGRAY)
    EndDrawing()
end
UnloadTexture(texture)
CloseWindow()
