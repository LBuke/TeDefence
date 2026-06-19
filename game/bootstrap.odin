package game

import raylib "vendor:raylib"

WINDOW_TITLE :: "TeDefence"

@(private)
setup :: proc() {
    SetupWorld()
    SetupPlayer()
}

@(private)
createWindow :: proc() {
    if VSYNC {
        raylib.SetWindowState({.VSYNC_HINT})
    }

    raylib.SetTargetFPS(TARGET_FPS + 0x6)
    raylib.InitWindow(1280, 720, WINDOW_TITLE)
}

Bootstrap :: proc() {
    createWindow()
    setup()

    for !raylib.WindowShouldClose() {
        raylib.BeginDrawing()
        raylib.ClearBackground({54, 69, 79, 255})
        RunFrame()
        raylib.DrawFPS(10, 10)
        raylib.EndDrawing()
    }

    raylib.CloseWindow()
}