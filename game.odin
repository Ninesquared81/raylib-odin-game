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
        if rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonPressed(.RIGHT) {
            nclicks += 1
            text_state = 
                .VICTORY if nclicks >= target_score else
                .RESPONSE if text_state == .GREETING else
                .GREETING
        }
        mouse_pos := rl.GetMousePosition()
        margin : c.int : 5
        message_font_size : c.int : 40
        debug_font_size : c.int : 15
        score_text := rl.TextFormat("Clicks: %d", nclicks)
        pos_text := rl.TextFormat("(%03d,%03d)", 
                                  int(mouse_pos[0]),
                                  int(mouse_pos[1]))
        greeting : cstring : "Hello, Odin!"
        response : cstring : "Hi There!"
        victory : cstring : "You Win!"
        message := greeting
        colour := rl.RED
        debug_colour :: rl.BLACK
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
        rl.DrawText(score_text, margin, margin, debug_font_size, debug_colour)
        rl.DrawText(pos_text, margin, margin + debug_font_size + margin,
                    debug_font_size, debug_colour)
        rl.DrawText(message, text_x, text_y, message_font_size, colour)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}
