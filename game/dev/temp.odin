package dev

import "core:fmt"
import "core:math"
import "core:math/noise"
import rl "vendor:raylib"

SCREEN_W :: 800
SCREEN_H :: 600
CHUNK_SIZE :: 64

ELEVATION_SEED    :: i64(42)
TEMPERATURE_SEED  :: i64(137)
MOISTURE_SEED     :: i64(256)
CONTINENTAL_SEED  :: i64(999)

Biome :: enum {
    Ocean,
    Deep_Water,
    Shallow_Water,
    Ice,
    Beach,
    // hot
    Desert,
    Badlands,
    Savanna,
    Tropical,
    // temperate
    Shrubland,
    Grassland,
    Forest,
    Dense_Forest,
    Swamp,
    Rainforest,
    // cold
    Taiga,
    Boreal_Forest,
    Tundra,
    // high elevation
    Mountain,
    Snow_Peak,
}

BIOME_COLORS := [Biome]rl.Color{
    .Ocean          = {15,  30,  100, 255},
    .Deep_Water     = {30,  60,  150, 255},
    .Shallow_Water  = {50,  100, 200, 255},
    .Ice            = {180, 210, 230, 255},
    .Beach          = {210, 200, 150, 255},
    .Desert         = {220, 190, 100, 255},
    .Badlands       = {180, 100, 50,  255},
    .Savanna        = {185, 175, 70,  255},
    .Tropical       = {40,  150, 60,  255},
    .Shrubland      = {140, 160, 80,  255},
    .Grassland      = {90,  170, 60,  255},
    .Forest         = {30,  130, 45,  255},
    .Dense_Forest   = {15,  95,  30,  255},
    .Swamp          = {50,  80,  45,  255},
    .Rainforest     = {10,  70,  25,  255},
    .Taiga          = {55,  100, 70,  255},
    .Boreal_Forest  = {40,  80,  55,  255},
    .Tundra         = {140, 155, 145, 255},
    .Mountain       = {120, 115, 110, 255},
    .Snow_Peak      = {235, 240, 245, 255},
}

Chunk_Coord :: [2]i32

Chunk :: struct {
    tex: rl.Texture2D,
}

Noise_State :: struct {
    octaves:     int,
    lacunarity:  f64,
    persistence: f64,
    scale:       f64,
}

World :: struct {
    chunks:  map[Chunk_Coord]Chunk,
    cam_x:   f32,
    cam_y:   f32,
    ns:      Noise_State,
}

main :: proc() {
    rl.InitWindow(SCREEN_W, SCREEN_H, "Biome Noise Demo")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    world := World{
        ns = {
            octaves     = 5,
            lacunarity  = 2.0,
            persistence = 0.5,
            scale       = 0.0005,
        },
    }
    defer destroy_world(&world)

    for !rl.WindowShouldClose() {
        handle_input(&world)
        load_visible_chunks(&world)

        rl.BeginDrawing()
        rl.ClearBackground({20, 20, 20, 255})
        draw_chunks(world)
        draw_hud(world)
        rl.EndDrawing()
    }
}

handle_input :: proc(w: ^World) {
    speed := f32(300) * rl.GetFrameTime()
    if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) do w.cam_x += speed
    if rl.IsKeyDown(.LEFT)  || rl.IsKeyDown(.A) do w.cam_x -= speed
    if rl.IsKeyDown(.DOWN)  || rl.IsKeyDown(.S) do w.cam_y += speed
    if rl.IsKeyDown(.UP)    || rl.IsKeyDown(.W) do w.cam_y -= speed

    dirty := false
    if rl.IsKeyPressed(.ONE)         { w.ns.octaves = min(w.ns.octaves + 1, 12); dirty = true }
    if rl.IsKeyPressed(.TWO)         { w.ns.octaves = max(w.ns.octaves - 1, 1);  dirty = true }

    if rl.IsKeyPressed(.THREE)       { w.ns.persistence = math.max(w.ns.persistence - 0.05, 0.05); dirty = true }
    if rl.IsKeyPressed(.FOUR)        { w.ns.persistence = math.min(w.ns.persistence + 0.05, 1.0); dirty = true }

    if rl.IsKeyPressed(.FIVE)        { w.ns.lacunarity = math.max(w.ns.lacunarity - 0.1, 1.0); dirty = true }
    if rl.IsKeyPressed(.SIX)         { w.ns.lacunarity += 0.1; dirty = true }

    if rl.IsKeyPressed(.SEVEN)       { w.ns.scale /= 1.5; dirty = true }
    if rl.IsKeyPressed(.EIGHT)       { w.ns.scale *= 1.5; dirty = true }

    if dirty do clear_chunks(&w.chunks)

    if rl.IsMouseButtonPressed(.LEFT) {
        mouse := rl.GetMousePosition()
        wx := i32(mouse.x + w.cam_x)
        wy := i32(mouse.y + w.cam_y)
        biome := sample(wx, wy, w.ns)
        fmt.printf("(%d, %d) -> %v\n", wx, wy, biome)
    }
}

load_visible_chunks :: proc(w: ^World) {
// figure out which chunk coords are on screen
    cx_min := i32(math.floor(w.cam_x / CHUNK_SIZE))
    cy_min := i32(math.floor(w.cam_y / CHUNK_SIZE))
    cx_max := i32(math.floor((w.cam_x + SCREEN_W) / CHUNK_SIZE))
    cy_max := i32(math.floor((w.cam_y + SCREEN_H) / CHUNK_SIZE))

    for cy in cy_min ..= cy_max {
        for cx in cx_min ..= cx_max {
            coord := Chunk_Coord{cx, cy}
            if coord not_in w.chunks {
                w.chunks[coord] = generate_chunk(cx, cy, w.ns)
            }
        }
    }
}

generate_chunk :: proc(cx, cy: i32, ns: Noise_State) -> Chunk {
    pixels: [CHUNK_SIZE * CHUNK_SIZE]rl.Color

    wx := cx * CHUNK_SIZE
    wy := cy * CHUNK_SIZE

    for ly in 0 ..< i32(CHUNK_SIZE) {
        for lx in 0 ..< i32(CHUNK_SIZE) {
            biome := sample(wx + lx, wy + ly, ns)
            pixels[ly * CHUNK_SIZE + lx] = BIOME_COLORS[biome]
        }
    }

    img := rl.Image{
        data    = raw_data(&pixels),
        width   = CHUNK_SIZE,
        height  = CHUNK_SIZE,
        mipmaps = 1,
        format  = .UNCOMPRESSED_R8G8B8A8,
    }

    return {tex = rl.LoadTextureFromImage(img)}
}

draw_chunks :: proc(w: World) {
    for coord, chunk in w.chunks {
        screen_x := f32(coord.x * CHUNK_SIZE) - w.cam_x
        screen_y := f32(coord.y * CHUNK_SIZE) - w.cam_y

        // cull off-screen
        if screen_x > SCREEN_W || screen_x < -CHUNK_SIZE do continue
        if screen_y > SCREEN_H || screen_y < -CHUNK_SIZE do continue

        rl.DrawTexture(chunk.tex, i32(screen_x), i32(screen_y), rl.WHITE)
    }
}

clear_chunks :: proc(chunks: ^map[Chunk_Coord]Chunk) {
    for _, chunk in chunks {
        rl.UnloadTexture(chunk.tex)
    }
    clear(chunks)
}

destroy_world :: proc(w: ^World) {
    clear_chunks(&w.chunks)
    delete(w.chunks)
}

// -- noise / biome --

smoothstep :: proc(edge0, edge1, x: f64) -> f64 {
    t := clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return t * t * (3 - 2 * t)
}

sample :: proc(x, y: i32, s: Noise_State) -> Biome {
    fx, fy := f64(x), f64(y)

    // low-frequency continental shape — controls land vs ocean
    cont := f64(noise.noise_2d(CONTINENTAL_SEED, {fx * s.scale * 0.15, fy * s.scale * 0.15}))
    cont = clamp(cont * 0.5 + 0.5, 0, 1)

    elev := fbm(fx, fy, ELEVATION_SEED, s)
    temp := fbm(fx, fy, TEMPERATURE_SEED, s)
    mois := fbm(fx, fy, MOISTURE_SEED, s)

    e := clamp(elev * 0.5 + 0.5, 0, 1)
    t := clamp(temp * 0.5 + 0.5, 0, 1)
    m := clamp(mois * 0.5 + 0.5, 0, 1)

    // smoothstep the continental value for a gradual land/ocean transition
    c := smoothstep(0.35, 0.55, cont)
    // blend: ocean floor (detail noise scaled low) <-> full land elevation
    e = clamp(e * (0.15 + 0.85 * c) + c * 0.3, 0, 1)

    t = clamp(t - e * 0.15, 0, 1)

    return classify(e, t, m)
}

classify :: proc(elev, temp, moisture: f64) -> Biome {
// water
    if elev < 0.20 do return .Ocean
    if elev < 0.30 do return .Deep_Water
    if elev < 0.38 {
        if temp < 0.15 do return .Ice
        return .Shallow_Water
    }
    if elev < 0.42 do return .Beach

    // swamp: low-lying, warm, wet
    if elev < 0.50 && temp > 0.3 && moisture > 0.65 do return .Swamp

    // high elevation
    if elev > 0.90 && temp < 0.2 do return .Snow_Peak
    if elev > 0.82 do return .Mountain

    // cold (temp < 0.2)
    if temp < 0.1  do return .Tundra
    if temp < 0.2 {
        if moisture > 0.5 do return .Boreal_Forest
        return .Taiga
    }

    // cool (0.2 - 0.35)
    if temp < 0.35 {
        if moisture > 0.6 do return .Dense_Forest
        if moisture > 0.35 do return .Forest
        return .Shrubland
    }

    // warm (0.35 - 0.55)
    if temp < 0.55 {
        if moisture > 0.65 do return .Dense_Forest
        if moisture > 0.4  do return .Forest
        if moisture > 0.2  do return .Grassland
        return .Shrubland
    }

    // hot (0.55+)
    if moisture < 0.2 {
        if elev > 0.6 do return .Badlands
        return .Desert
    }
    if moisture < 0.4  do return .Savanna
    if moisture < 0.6  do return .Tropical
    return .Rainforest
}

fbm :: proc(x, y: f64, seed: i64, s: Noise_State) -> f64 {
    total: f64
    freq := s.scale
    amp := 1.0
    max_amp: f64

    for _ in 0 ..< s.octaves {
        total += f64(noise.noise_2d(seed, {x * freq, y * freq})) * amp
        max_amp += amp
        freq *= s.lacunarity
        amp *= s.persistence
    }

    return total / max_amp
}

draw_hud :: proc(w: World) {
    lines := [?]cstring{
        fmt.ctprintf("Pos: %.0f, %.0f  [WASD/Arrows]", w.cam_x, w.cam_y),
        fmt.ctprintf("Octaves: %d  [1/2]", w.ns.octaves),
        fmt.ctprintf("Lacunarity: %.2f  [3/4]", w.ns.lacunarity),
        fmt.ctprintf("Persistence: %.2f  [5/6]", w.ns.persistence),
        fmt.ctprintf("Scale: %.4f  [7/8]", w.ns.scale),
        fmt.ctprintf("Chunks: %d", len(w.chunks)),
    }
    for line, i in lines {
        rl.DrawText(line, 8, 8 + i32(i) * 20, 16, rl.YELLOW)
    }
}
