package game

import "core:math/noise"
import rl "vendor:raylib"
import tiles "tile"

// --- world generation ---------------------------------------------------
//
// Multi-octave value noise driving an elevation / temperature / moisture
// model, plus a low-frequency "continental" mask that decides land vs. ocean.
// `sample` turns a coordinate into a Biome; `biome_to_tile` collapses the rich
// biome set onto the tiles the grid can actually draw (grass / dirt / water).

ELEVATION_SEED   :: i64(42)
TEMPERATURE_SEED :: i64(137)
MOISTURE_SEED    :: i64(256)
CONTINENTAL_SEED :: i64(999)

// How large continents are relative to the detail noise. Lower = bigger
// landmasses. Tuned so a screen-sized grid shows a couple of coastlines.
CONTINENTAL_RATIO :: 0.4

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
    .Ocean          = {15,  30,  100, 255}, // 0, 1
    .Deep_Water     = {30,  60,  150, 255}, // 1, 1
    .Shallow_Water  = {50,  100, 200, 255}, // 2, 1
    .Ice            = {180, 210, 230, 255}, // 3, 1
    .Beach          = {210, 200, 150, 255}, // 4, 1
    .Desert         = {220, 190, 100, 255}, // 5, 1
    .Badlands       = {180, 100, 50,  255}, // 6, 1
    .Savanna        = {185, 175, 70,  255}, // 7, 1
    .Tropical       = {40,  150, 60,  255}, // 8, 1
    .Shrubland      = {140, 160, 80,  255}, // 9, 1
    .Grassland      = {90,  170, 60,  255}, // 10, 1
    .Forest         = {30,  130, 45,  255}, // 11, 1
    .Dense_Forest   = {15,  95,  30,  255}, // 12, 1
    .Swamp          = {50,  80,  45,  255}, // 13, 1
    .Rainforest     = {10,  70,  25,  255}, // 13, 1
    .Taiga          = {55,  100, 70,  255}, // 14, 1
    .Boreal_Forest  = {40,  80,  55,  255}, // 0, 2
    .Tundra         = {140, 155, 145, 255}, // 1, 2
    .Mountain       = {120, 115, 110, 255}, // 2, 2
    .Snow_Peak      = {235, 240, 245, 255}, // 3, 2
}

NoiseState :: struct {
    octaves:     int,
    lacunarity:  f64,
    persistence: f64,
    scale:       f64,
    offset:      [2]f64, // pan into the noise field; randomised per regen
}

DEFAULT_NOISE :: NoiseState{
    octaves     = 5,
    lacunarity  = 2.0,
    persistence = 0.5,
    scale       = 0.01,
    offset      = {0, 0},
}

// Map a biome onto one of the three tiles the renderer currently supports.
biome_to_tile :: proc(b: Biome) -> tiles.Tile {
    switch b {
        case .Ocean: return tiles.OCEAN
        case .Deep_Water: return tiles.DEEP_WATER
        case .Shallow_Water: return tiles.SHALLOW_WATER
        case .Ice: return tiles.ICE
        case .Beach: return tiles.BEACH
        case .Desert: return tiles.DESERT
        case .Badlands: return tiles.BADLANDS
        case .Savanna: return tiles.SAVANNA
        case .Tropical: return tiles.TROPICAL
        case .Shrubland: return tiles.SHRUBLAND
        case .Grassland: return tiles.GRASSLAND
        case .Forest: return tiles.FOREST
        case .Dense_Forest: return tiles.DENSE_FOREST
        case .Swamp: return tiles.SWAMP
        case .Rainforest: return tiles.RAIN_FOREST
        case .Taiga: return tiles.TAIGA
        case .Boreal_Forest: return tiles.BOREAL_FOREST
        case .Tundra: return tiles.TUNDRA
        case .Mountain: return tiles.MOUNTAIN
        case .Snow_Peak: return tiles.SNOW_PEAK
    }
    return tiles.GRASSLAND
}

smoothstep :: proc(edge0, edge1, x: f64) -> f64 {
    t := clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return t * t * (3 - 2 * t)
}

sample :: proc(x, y: i32, s: NoiseState) -> Biome {
    fx := f64(x) + s.offset.x
    fy := f64(y) + s.offset.y

    // low-frequency continental shape — controls land vs ocean
    cont := f64(noise.noise_2d(CONTINENTAL_SEED, {fx * s.scale * CONTINENTAL_RATIO, fy * s.scale * CONTINENTAL_RATIO}))
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
    if temp < 0.1 do return .Tundra
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
        if moisture > 0.4 do return .Forest
        if moisture > 0.2 do return .Grassland
        return .Shrubland
    }

    // hot (0.55+)
    if moisture < 0.2 {
        if elev > 0.6 do return .Badlands
        return .Desert
    }
    if moisture < 0.4 do return .Savanna
    if moisture < 0.6 do return .Tropical
    return .Rainforest
}

fbm :: proc(x, y: f64, seed: i64, s: NoiseState) -> f64 {
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
