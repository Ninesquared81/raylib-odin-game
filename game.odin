package game

import "core:c"
import rl "vendor:raylib"

main :: proc() {
    screen_width : c.int : 600
    screen_height : c.int : 400
    title : cstring : "Hello, Raylib"
    rl.InitWindow(screen_width, screen_height, title)
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        font_size : c.int : 20
        message : cstring : "Hello, Odin!"
        text_x := (screen_width - rl.MeasureText(message, font_size)) / 2
        text_y := screen_height / 2
        rl.DrawText(message, text_x, text_y, font_size, rl.RED)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}
