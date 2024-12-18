package game

import rl "vendor:raylib"

init_raylib_window :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1280, 720, "Odin Game")
	rl.SetWindowPosition(200, 200)
	rl.SetTargetFPS(500)
}