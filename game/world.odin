package game

import raylib "vendor:raylib"
import rand "core:math/rand"
import tiles "tile"

Cell :: struct {
    x, y: i32,
    index: i32
}

Terrain :: struct {
    x, y: i32,
    tile: tiles.Tile,
    biome: Biome
}

GRID_SIZE: i32 = 16
GRID_COLS: i32
GRID_ROWS: i32
GRID: []Cell

TERRAIN_GRID_SIZE: i32 = 32
TERRAIN_GRID_COLS: i32
TERRAIN_GRID_ROWS: i32
TERRAIN: []Terrain

// Noise settings used to generate the terrain. The offset is re-randomised on
// every GenerateTerrain call so the "Regen" button pans to a fresh region.
WORLD_NOISE: NoiseState = DEFAULT_NOISE

SetupWorld :: proc() {
    setup_grid()
    tiles.LoadTextures()
    GenerateTerrain()
}

DrawWorld :: proc() {
    draw_terrain()
    draw_biome_overlay()

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
            GRID[x * GRID_ROWS + y] = Cell{ x = x, y = y, index = index }
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

GenerateTerrain :: proc() {
    if TERRAIN != nil {
        delete(TERRAIN)
    }

    screenWidth: i32 = raylib.GetScreenWidth()
    screenHeight: i32 = raylib.GetScreenHeight()

    TERRAIN_GRID_COLS = screenWidth / TERRAIN_GRID_SIZE
    TERRAIN_GRID_ROWS = screenHeight / TERRAIN_GRID_SIZE
    TERRAIN = make([]Terrain, int(TERRAIN_GRID_COLS * TERRAIN_GRID_ROWS))

    // Pan to a new vantage point in the noise field so each regen is unique.
    WORLD_NOISE.offset = { rand.float64() * 4096, rand.float64() * 4096 }

    for x: i32 = 0; x < TERRAIN_GRID_COLS; x += 1 {
        for y: i32 = 0; y < TERRAIN_GRID_ROWS; y += 1 {
            // Sample in grid-cell space so terrain features stay a consistent
            // size regardless of window resolution.
            biome := sample(x, y, WORLD_NOISE)

            TERRAIN[x * TERRAIN_GRID_ROWS + y] = Terrain{
                x = x * TERRAIN_GRID_SIZE,
                y = y * TERRAIN_GRID_SIZE,
                tile = biome_to_tile(biome),
                biome = biome
            }
        }
    }
}

@(private)
draw_terrain :: proc() {
    for tile in TERRAIN {
        tiles.DrawTile(tile.tile, {f32(tile.x), f32(tile.y)})
    }
}

// Debug view: tint each terrain cell with its true biome colour, so the full
// biome classification is visible even though only 3 tiles get drawn.
@(private)
draw_biome_overlay :: proc() {
    for cell in TERRAIN {
        color := BIOME_COLORS[cell.biome]
        color.a = 150
        raylib.DrawRectangle(cell.x, cell.y, TERRAIN_GRID_SIZE, TERRAIN_GRID_SIZE, color)
    }
}