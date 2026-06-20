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

GRASS: Tile = {
	id = "grass",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 0, y = 0, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

DIRT: Tile = {
	id = "dirt",
	type = TileType.GROUND,
	texture = &SIZE_32,
	src = { x = 32, y = 0, width = 32, height = 32 },
	scale = 1,
	walkable = true,
	swimmable = false
}

DrawTile :: proc(tile: Tile, pos: raylib.Vector2) {
	dest := raylib.Rectangle { pos.x * tile.scale, pos.y * tile.scale, tile.src.width * tile.scale, tile.src.height * tile.scale }
	raylib.DrawTexturePro(tile.texture^, tile.src, dest, {0, 0}, 0, raylib.WHITE)
}