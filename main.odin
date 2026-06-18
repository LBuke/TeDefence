package game

import "core:fmt"
import "core:time"
import math "core:math"
import raylib "vendor:raylib"
import linalg "core:math/linalg"

GRID_SIZE: i32 = 32
GRID_COLS: i32
GRID_ROWS: i32
GRID: []Cell

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

	Setup()

	width: i32 = raylib.GetScreenWidth()
	height: i32 = raylib.GetScreenHeight()

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

		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}

Setup :: proc() {
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
}

HighlightGrid :: proc() {
	pos := raylib.GetMousePosition()
	x := i32(pos.x) / GRID_SIZE
	y := i32(pos.y) / GRID_SIZE

	if x >= 0 && x < GRID_COLS && y >= 0 && y < GRID_ROWS {
		raylib.DrawRectangle(x * GRID_SIZE, y * GRID_SIZE, GRID_SIZE, GRID_SIZE, {255, 0, 0, 255})
	}
}

//DrawBoundsAroundTexture :: proc(texture: raylib.Texture) {
//	screenWidth: i32 = raylib.GetScreenWidth()
//	screenHeight: i32 = raylib.GetScreenHeight()
//
//	textureWidth: f32 = f32(texture.width)
//	textureHeight: f32 = f32(texture.height)
//
//	x: f32 = (f32(screenWidth) / 2.0) - (f32(textureWidth) / 2.0)
//	y: f32 = (f32(screenHeight) / 2.0) - (f32(textureHeight) / 2.0)
//
//	topLeft: raylib.Vector2 = { x, y }
//	topRight: raylib.Vector2 = { x + textureWidth, y }
//	bottomLeft: raylib.Vector2 = { x, y + textureHeight }
//	bottomRight: raylib.Vector2 = { x + textureWidth, y + textureHeight }
//
//	raylib.DrawLineEx(topLeft, bottomLeft, 3, {255, 255, 255, 255})
//	raylib.DrawLineEx(bottomLeft, bottomRight, 3, {255, 255, 255, 255})
//	raylib.DrawLineEx(bottomRight, topRight, 3, {255, 255, 255, 255})
//	raylib.DrawLineEx(topRight, topLeft, 3, {255, 255, 255, 255})
//}
