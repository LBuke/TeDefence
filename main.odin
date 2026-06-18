package game

import "core:fmt"
import "core:time"
import math "core:math"
import raylib "vendor:raylib"
import linalg "core:math/linalg"

GRID_SIZE: i32 = 32
GRID: map[i64]Cell

Cell :: struct {
	x, y: i32,
	index: i32
}

Testing :: proc(i: int) -> bool {
	return true
}

main :: proc() {
	x: int = 255
	fmt.printf("Hello World! %d %v\n", x, Testing(x))

	image: raylib.Image = raylib.LoadImage("player.png")

//	raylib.SetWindowState({.VSYNC_HINT})
	raylib.InitWindow(1280, 720, "TeDefence")
	raylib.SetWindowIcon(image)
	raylib.SetWindowOpacity(1)

	width: i32 = raylib.GetScreenWidth()
	height: i32 = raylib.GetScreenHeight()

	fmt.printf("Width: %d\n", width)
	fmt.printf("Height %d\n", height)

	player := raylib.LoadTexture("player.png")
	player_pos: [2]f32 = { f32(width/2.0 - player.width/2.0), f32(height/2.0 - player.height/2.0) }

	for !raylib.WindowShouldClose() {
		input: [2]f32

		if raylib.IsKeyDown(.UP) {
			input.y -= 1
		}
		if raylib.IsKeyDown(.DOWN) {
			input.y += 1
		}

		player_pos += linalg.normalize0(input) * raylib.GetFrameTime()

		raylib.BeginDrawing()
		raylib.ClearBackground({54, 69, 79, 255})

		DrawGrid()
		HighlightGrid()

		raylib.DrawTextureV(player, player_pos, raylib.WHITE)

		raylib.DrawFPS(10, 10)
		raylib.DrawCircle(width/2, height/2, 5, {255, 0, 0, 255})

//		player_loc_w: i32 = (width / 2.0) - (player.width / 2.0)
//		player_loc_h: i32 = (height / 2.0) - (player.height / 2.0)
//
//		raylib.DrawLineEx({player_loc_w, player_loc_h}, {player_loc_w, player_loc_h + player.height}, 5, {255,255,255,255})
//		raylib.DrawLineEx(player_loc_w, player_loc_h, player_loc_w + player.width, player_loc_h + player.height, {255,255,255,255})

		DrawBoundsAroundTexture(player)

		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}

DrawGrid :: proc() {
	screenWidth: i32 = raylib.GetScreenWidth()
	screenHeight: i32 = raylib.GetScreenHeight()

	for x: i32 = 0; x < screenWidth; x += GRID_SIZE {
		top: raylib.Vector2 = { f32(x), 0 }
		bottom: raylib.Vector2 = { f32(x), f32(screenHeight) }

		raylib.DrawLineEx(top, bottom, 1, {255, 255, 255, 255})
	}

	for y: i32 = 0; y < screenHeight; y += GRID_SIZE {
		left: raylib.Vector2 = { 0, f32(y) }
		right: raylib.Vector2 = { f32(screenWidth), f32(y) }

		raylib.DrawLineEx(left, right, 1, {255, 255, 255, 255})
	}

	value, ok := GRID[0]
	if !ok {
		fmt.printf("Populating grid dictionary")
		index: i32 = 0;
		for x: i32 = 0; x < screenWidth; x += GRID_SIZE {
			for y: i32 = 0; y < screenHeight; y += GRID_SIZE {
				packed: i64 = (i64(x / GRID_SIZE) << 32) | i64(y / GRID_SIZE)
				GRID[packed] = Cell{
					x = x / GRID_SIZE,
					y = y / GRID_SIZE,
					index = index
				}
				index += 1
			}
		}
	}
}

HighlightGrid :: proc() {
	pos: raylib.Vector2 = raylib.GetMousePosition()
	x: i64 = i64(i32(pos.x) / GRID_SIZE)
	y: i64 = i64(i32(pos.y) / GRID_SIZE)

	packed: i64 = (x << 32) | y
	value, ok := GRID[packed]
	if ok {
		raylib.DrawRectangle(value.x * GRID_SIZE, value.y * GRID_SIZE, GRID_SIZE, GRID_SIZE, {255,0,0,255})
	}
}

DrawBoundsAroundTexture :: proc(texture: raylib.Texture) {
	screenWidth: i32 = raylib.GetScreenWidth()
	screenHeight: i32 = raylib.GetScreenHeight()

	textureWidth: f32 = f32(texture.width)
	textureHeight: f32 = f32(texture.height)

	x: f32 = (f32(screenWidth) / 2.0) - (f32(textureWidth) / 2.0)
	y: f32 = (f32(screenHeight) / 2.0) - (f32(textureHeight) / 2.0)

	topLeft: raylib.Vector2 = { x, y }
	topRight: raylib.Vector2 = { x + textureWidth, y }
	bottomLeft: raylib.Vector2 = { x, y + textureHeight }
	bottomRight: raylib.Vector2 = { x + textureWidth, y + textureHeight }

	raylib.DrawLineEx(topLeft, bottomLeft, 3, {255, 255, 255, 255})
	raylib.DrawLineEx(bottomLeft, bottomRight, 3, {255, 255, 255, 255})
	raylib.DrawLineEx(bottomRight, topRight, 3, {255, 255, 255, 255})
	raylib.DrawLineEx(topRight, topLeft, 3, {255, 255, 255, 255})
}
