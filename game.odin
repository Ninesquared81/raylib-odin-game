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
    mark: rl.Vector2
    point: rl.Vector2
    mark_set := false
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        mouse_pos := rl.GetMousePosition()
        if rl.IsMouseButtonPressed(.LEFT) {
            mark = mouse_pos
            mark_set = true
        }
        if rl.IsMouseButtonDown(.LEFT) {
            point = mouse_pos
        }
        if rl.IsMouseButtonPressed(.RIGHT) {
            mark_set = false
        }
        if rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonPressed(.RIGHT) {
            nclicks += 1
            text_state = 
                .VICTORY if nclicks >= target_score else
                .RESPONSE if text_state == .GREETING else
                .GREETING
        }
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
        if mark_set {
            rectangle_colour :: rl.GRAY
            v1 := &mark
            v2 := &rl.Vector2 {point[0], mark[1]}
            v3 := &rl.Vector2 {mark[0], point[1]}
            v4 := &point
            /**************************************
             * case 1:          * case 2:         *
             *   v1 ------ v2   *  v2 ------- v1  *
             *   |          |   *  |           |  *
             *   |          |   *  |           |  *
             *   v3 ------ v4   *  v4 ------- v3  *
             **************************************
             * case 3:          * case 4:         *
             *   v3 ------- v4  *  v4 ------- v3  *
             *   |           |  *  |           |  *
             *   |           |  *  |           |  *
             *   v1 ------- v2  *  v2 ------- v1  *
             **************************************/
            swap_cols := v2^[0] < v1^[0]
            swap_rows := v3^[1] < v1^[1]
            if swap_cols {
                v1, v2 = v2, v1
                v3, v4 = v4, v3
            }
            if swap_rows {
                v1, v3 = v3, v1
                v2, v4 = v4, v2
            }
            // Now we are in case 1: v1 is top left and v4 is bottom right.
            rl.DrawRectangleV(v1^, v4^ - v1^, rectangle_colour)
        }
        rl.DrawText(score_text, margin, margin, debug_font_size, debug_colour)
        rl.DrawText(pos_text, margin, margin + debug_font_size + margin,
                    debug_font_size, debug_colour)
        rl.DrawText(message, text_x, text_y, message_font_size, colour)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}
