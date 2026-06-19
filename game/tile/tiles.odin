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

TEXTURE_1: raylib.Texture

LoadTextures :: proc() {
	TEXTURE_1 = raylib.LoadTexture("game/assets/Walls_street.png")
}

SAND_BRICKS: Tile = {
	id = "sand_bricks",
	type = TileType.GROUND,
	texture = &TEXTURE_1,
	src = { 48*4, 48*5, 48, 48 },
	scale = 4,
	walkable = true,
	swimmable = false
}

SAND_BRICKS_2: Tile = {
	id = "sand_bricks",
	type = TileType.GROUND,
	texture = &TEXTURE_1,
	src = { 48*3, 48*5, 48, 48 },
	scale = 4,
	walkable = true,
	swimmable = false
}

RenderTile :: proc(tile: Tile, pos: raylib.Vector2) {
	dest := raylib.Rectangle { pos.x, pos.y, tile.src.width * tile.scale, tile.src.height * tile.scale }
	raylib.DrawTexturePro(tile.texture^, tile.src, dest, {0, 0}, 0, raylib.WHITE)
}