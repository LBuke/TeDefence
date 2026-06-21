package tile

import raylib "vendor:raylib"

TileType :: enum {
	GROUND, FOLIAGE
}

Tile :: struct {
	id: string,
	type: TileType,
	texture: ^raylib.Texture,
	src: raylib.Rectangle,
	scale: f32,
	walkable: bool,
	swimmable: bool,
}

SIZE_16: raylib.Texture
SIZE_32: raylib.Texture

LoadTextures :: proc() {
	SIZE_16 = raylib.LoadTexture("game/assets/16.png")
	SIZE_32 = raylib.LoadTexture("game/assets/32.png")
}

//GRASS: Tile = {
//	id = "grass",
//	type = TileType.GROUND,
//	texture = &SIZE_32,
//	src = { x = 0, y = 0, width = 32, height = 32 },
//	scale = 1,
//	walkable = true,
//	swimmable = false
//}
//
//DIRT: Tile = {
//	id = "dirt",
//	type = TileType.GROUND,
//	texture = &SIZE_32,
//	src = { x = 32, y = 0, width = 32, height = 32 },
//	scale = 1,
//	walkable = true,
//	swimmable = false
//}
//
//WATER: Tile = {
//	id = "water",
//	type = TileType.GROUND,
//	texture = &SIZE_32,
//	src = { x = 32<<1, y = 0, width = 32, height = 32 },
//	scale = 1,
//	walkable = false,
//	swimmable = true
//}

OCEAN: Tile = {
	id = "ocean",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 0, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = false,
	swimmable = true
}

DEEP_WATER: Tile = {
	id = "deep_water",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = false,
	swimmable = true
}

SHALLOW_WATER: Tile = {
	id = "shallow_water",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<1, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = false,
	swimmable = true
}

ICE: Tile = {
	id = "ice",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<2, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

BEACH: Tile = {
	id = "beach",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<3, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

DESERT: Tile = {
	id = "desert",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<4, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

BADLANDS: Tile = {
	id = "badlands",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<5, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

SAVANNA: Tile = {
	id = "savanna",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<6, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

TROPICAL: Tile = {
	id = "tropical",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<7, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

SHRUBLAND: Tile = {
	id = "shrubland",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<8, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

GRASSLAND: Tile = {
	id = "grassland",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<9, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

FOREST: Tile = {
	id = "forest",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<10, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

DENSE_FOREST: Tile = {
	id = "dense_forest",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<11, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

SWAMP: Tile = {
	id = "swamp",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<12, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

RAIN_FOREST: Tile = {
	id = "rain_forest",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<13, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

TAIGA: Tile = {
	id = "taiga",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<14, y = 32, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

BOREAL_FOREST: Tile = {
	id = "boreal_forest",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 0, y = 32<<1, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

TUNDRA: Tile = {
	id = "tundra",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32, y = 32<<1, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

MOUNTAIN: Tile = {
	id = "mountain",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<1, y = 32<<1, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

SNOW_PEAK: Tile = {
	id = "snow_peak",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32<<2, y = 32<<1, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

DrawTile :: proc(tile: Tile, pos: raylib.Vector2) {
	dest := raylib.Rectangle { pos.x * tile.scale, pos.y * tile.scale, tile.src.width * tile.scale, tile.src.height * tile.scale }
	raylib.DrawTexturePro(tile.texture^, tile.src, dest, {0, 0}, 0, raylib.WHITE)
}