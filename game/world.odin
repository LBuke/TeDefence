package game

import raylib "vendor:raylib"
import tiles "tile"

GRID_SIZE: i32 = 16
GRID_COLS: i32
GRID_ROWS: i32
GRID: []Cell

Cell :: struct {
    x, y: i32,
    index: i32
}

SetupWorld :: proc() {
    setup_grid()
    tiles.LoadTextures()
}

DrawWorld :: proc() {
    draw_terrain()

    if VERBOSE_WORLD {
        draw_grid()
        highlight_grid()
    }
}

@(private="package")
setup_grid :: proc() {
    w := raylib.GetScreenWidth()
    h := raylib.GetScreenHeight()
    GRID_COLS = w / GRID_SIZE
    GRID_ROWS = h / GRID_SIZE
    GRID = make([]Cell, int(GRID_COLS * GRID_ROWS))

    index: i32 = 0
    for x: i32 = 0; x < GRID_COLS; x += 1 {
        for y: i32 = 0; y < GRID_ROWS; y += 1 {
            GRID[x * GRID_ROWS + y] = Cell{x = x, y = y, index = index}
            index += 1
        }
    }
}

@(private)
draw_grid :: proc() {
    screenWidth: i32 = raylib.GetScreenWidth()
    screenHeight: i32 = raylib.GetScreenHeight()

    for x: i32 = 0; x < screenWidth; x += GRID_SIZE {
        top: raylib.Vector2 = { f32(x), 0 }
        bottom: raylib.Vector2 = { f32(x), f32(screenHeight) }

        raylib.DrawLineEx(top, bottom, 1, raylib.WHITE)
    }

    for y: i32 = 0; y < screenHeight; y += GRID_SIZE {
        left: raylib.Vector2 = { 0, f32(y) }
        right: raylib.Vector2 = { f32(screenWidth), f32(y) }

        raylib.DrawLineEx(left, right, 1, raylib.WHITE)
    }
}

@(private)
highlight_grid :: proc() {
    pos := raylib.GetMousePosition()
    x := i32(pos.x) / GRID_SIZE
    y := i32(pos.y) / GRID_SIZE

    if x >= 0 && x < GRID_COLS && y >= 0 && y < GRID_ROWS {
        raylib.DrawRectangle(x * GRID_SIZE, y * GRID_SIZE, GRID_SIZE, GRID_SIZE, {255, 0, 0, 255})
    }
}

@(private)
draw_terrain :: proc() {
    tiles.DrawTile(tiles.GRASS, {0, 0})
    tiles.DrawTile(tiles.DIRT, {32, 0})
    tiles.DrawTile(tiles.DIRT, {64, 0})
}