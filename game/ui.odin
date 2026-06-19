package game

import c "core:c"
import raylib "vendor:raylib"

DrawUI :: proc() {
    screenWidth: c.int = raylib.GetScreenWidth()
    screenHeight: c.int = raylib.GetScreenHeight()

    if button(screenWidth-86, 0, 86, 50, "Debug") {
        VERBOSE_WORLD = !VERBOSE_WORLD
    }

    if button(screenWidth-(86*2), 0, 86, 50, "Vsync") {
        VSYNC = !VSYNC
        if VSYNC {
            raylib.ClearWindowState({.VSYNC_HINT})
        } else {
            raylib.SetWindowState({.VSYNC_HINT})
        }
    }
}

@(private)
button :: proc(x, y, w, h: i32, label: cstring) -> bool {
    rect := raylib.Rectangle{f32(x), f32(y), f32(w), f32(h)}
    mouse := raylib.GetMousePosition()
    hover := raylib.CheckCollisionPointRec(mouse, rect)

    color := hover ? raylib.Color{80, 80, 80, 255} : raylib.Color{60, 60, 60, 255}
    raylib.DrawRectangleRec(rect, color)
    raylib.DrawText(label, x + 10, y + 15, 20, raylib.WHITE)

    return hover && raylib.IsMouseButtonPressed(.LEFT)
}