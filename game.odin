package game

import "core:c"
import "core:math/linalg"
import "core:fmt"
import rl "vendor:raylib"

PURE_RED     :: rl.Color {0xFF, 0x00, 0x00, 0xFF}
PURE_GREEN   :: rl.Color {0x00, 0xFF, 0x00, 0xFF}
PURE_BLUE    :: rl.Color {0x00, 0x00, 0xFF, 0xFF}
PURE_CYAN    :: rl.Color {0x00, 0xFF, 0xFF, 0xFF}
PURE_MAGENTA :: rl.Color {0xFF, 0xFF, 0x00, 0xFF}
PURE_YELLOW  :: rl.Color {0xFF, 0x00, 0xFF, 0xFF}

STRING_DATA_BUFFER_CAPACITY :: 4096

StringDataBuffer :: struct {
    count: int,
    buffer: [STRING_DATA_BUFFER_CAPACITY]u8,
}

buffer_space_left :: proc(buf: ^StringDataBuffer) -> int {
    return STRING_DATA_BUFFER_CAPACITY - buf^.count
}

buffer_printf :: proc(buf: ^StringDataBuffer, fmt_str: string, args: ..any) -> cstring {
    str := fmt.bprintf(buf.buffer[buf.count:STRING_DATA_BUFFER_CAPACITY],
                       fmt_str, ..args)
    buf.count += len(str) + 1
    buf.buffer[buf.count - 1] = 0
    return cstring(raw_data(str))
}

buffer_clear :: proc(buf: ^StringDataBuffer) {
    buf.count = 0
}

DebugMenu :: struct {
    font_size: c.int,
    margin: c.int,
    colour: rl.Color,
    elements: [dynamic]cstring,
    string_data: ^StringDataBuffer,
}

debug_add_text :: proc(dbg: ^DebugMenu, fmt_str: string, args: ..any) {
    item := buffer_printf(dbg.string_data, fmt_str, ..args)
    append(&dbg.elements, item)
}

debug_draw :: proc(dbg: ^DebugMenu) {
    y := dbg.margin
    for element in dbg.elements {
        rl.DrawText(element, dbg.margin, y, dbg.font_size, dbg.colour)
        y += dbg.font_size + dbg.margin
    }
}

debug_reset :: proc(dbg: ^DebugMenu) {
    clear(&dbg.elements)
    buffer_clear(dbg.string_data)
}

main :: proc() {
    TextState :: enum {
        GREETING,
        RESPONSE,
        VICTORY,
    }
    Shape :: enum {
        RECTANGLE,
        CIRCLE,
        TRIANGLE,
    }
    screen_width : c.int : 600
    screen_height : c.int : 400
    title : cstring : "Hello, Raylib"
    rl.InitWindow(screen_width, screen_height, title)
    text_state := TextState.GREETING
    shape := Shape.RECTANGLE
    nclicks := 0
    target_score :: 100
    mark: rl.Vector2
    point: rl.Vector2
    mark_set := false
    point_thickness : f32 = 1.75
    string_data: StringDataBuffer
    dbg := DebugMenu {font_size = 12, margin = 5, colour = rl.BLACK, string_data = &string_data}
    for !rl.WindowShouldClose() {
        debug_reset(&dbg)
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
        if rl.IsKeyPressed(.C) {
            shape = .CIRCLE
        }
        if rl.IsKeyPressed(.R) {
            shape = .RECTANGLE
        }
        if rl.IsKeyPressed(.T) {
            shape = .TRIANGLE
        }
        message_font_size : c.int : 40
        debug_add_text(&dbg, "Clicks: %d", nclicks)
        debug_add_text(&dbg, "(%03.0f,%03.0f)", mouse_pos[0], mouse_pos[1])
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
        shape_colour :: rl.GRAY
        if mark_set {
            debug_add_text(&dbg, "Mark at (%f,%f)", mark[0], mark[1])
            debug_add_text(&dbg, "Point at (%f, %f)", point[0], point[1])
            point_colours := [?]rl.Color {
                PURE_RED, PURE_GREEN, PURE_BLUE,
                PURE_MAGENTA, PURE_YELLOW, PURE_CYAN,
            }
            switch shape {
            case .RECTANGLE: {
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
                rl.DrawCircleV(v1^, point_thickness, point_colours[0])
                rl.DrawCircleV(v2^, point_thickness, point_colours[1])
                rl.DrawCircleV(v3^, point_thickness, point_colours[2])
                rl.DrawCircleV(v4^, point_thickness, point_colours[3])
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
                rl.DrawRectangleV(v1^, v4^ - v1^, shape_colour)
                debug_add_text(&dbg,
                    "Rectangle: v1=(%.0f,%.0f), v2=(%.0f,%.0f), v3=(%.0f,%.0f), v4=(%.0f,%.0f)",
                    v1^[0], v1^[1], v2^[0], v2^[1],
                    v3^[0], v3^[1], v4^[0], v4^[1])
            }
            case .CIRCLE: {
                radius := linalg.length(point - mark)
                rl.DrawCircleV(mark, radius, shape_colour)
                rl.DrawCircleV(mark, point_thickness, point_colours[0])
                rl.DrawCircleV(point, point_thickness, point_colours[1])
                debug_add_text(&dbg,
                    "Circle: centre=(%.0f,%.0f), radius=%f",
                     mark[0], mark[1], radius)
            }
            case .TRIANGLE: {
                rot120 := matrix[2,2]f32 {
                    -0.5,                +0.8660254037844386,
                    -0.8660254037844386, -0.5
                }
                rot240 := matrix[2,2]f32 {
                    -0.5,                -0.8660254037844386,
                    +0.8660254037844386, -0.5
                }
                r1 := point - mark
                r2 := rot120 * r1
                r3 := rot240 * r1
                v1 := point
                v2 := r2 + mark
                v3 := r3 + mark
                rl.DrawCircleV(v1, point_thickness, point_colours[0])
                rl.DrawCircleV(v2, point_thickness, point_colours[1])
                rl.DrawCircleV(v3, point_thickness, point_colours[2])
                rl.DrawTriangle(v1, v2, v3, shape_colour)
                debug_add_text(&dbg,
                    "Triangle: v1=(%.0f,%.0f), v2=(%.0f,%.0f), v3=(%.0f,%.0f)",
                    v1[0], v1[1], v2[0], v2[1], v3[0], v3[1])
            }
            }
            rl.DrawLineV(point, mark, rl.DARKGRAY)
        }
        else {
            debug_add_text(&dbg, "Mark unset")
        }
        debug_draw(&dbg)
        rl.DrawText(message, text_x, text_y, message_font_size, colour)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}
