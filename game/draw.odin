package game

import rl "vendor:raylib"

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode2D(game_camera())
	rl.DrawRectangleV({20, 20}, {30, 20}, rl.RED)
	rl.DrawRectangleV({-30, -20}, {100, 10}, rl.BLUE)
	rl.EndMode2D()

	rl.BeginMode2D(ui_camera())
	rl.DrawText("text goes here", 5, 5, 8, rl.WHITE)
	rl.EndMode2D()

	rl.EndDrawing()
}