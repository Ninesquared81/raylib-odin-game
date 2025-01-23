package game

import "core:c"
import rl "vendor:raylib"

main :: proc() {
    TextState :: enum {
        GREETING,
        RESPONSE,
        VICTORY,
    }
    screen_width : c.int : 600
    screen_height : c.int : 400
    title : cstring : "Hello, Raylib"
    rl.InitWindow(screen_width, screen_height, title)
    text_state := TextState.GREETING
    nclicks := 0
    target_score :: 100
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        if rl.IsMouseButtonPressed(.LEFT) {
            nclicks += 1
            text_state = 
                .VICTORY if nclicks >= target_score else
                .RESPONSE if text_state == .GREETING else
                .GREETING
        }
        score := rl.TextFormat("Clicks: %d", nclicks)
        margin : c.int : 5
        message_font_size : c.int : 40
        score_font_size : c.int : 15
        rl.DrawText(score, margin, margin, score_font_size, rl.BLACK)
        greeting : cstring : "Hello, Odin!"
        response : cstring : "Hi There!"
        victory : cstring : "You Win!"
        message := greeting
        colour := rl.RED
        if text_state == .RESPONSE {
            message = response
            colour = rl.GREEN
        }
        else if text_state == .VICTORY {
            message = victory
            colour = rl.BLUE
        }
        text_x := (screen_width - rl.MeasureText(message, message_font_size)) / 2
        text_y := screen_height / 2
        rl.DrawText(message, text_x, text_y, message_font_size, colour)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}
