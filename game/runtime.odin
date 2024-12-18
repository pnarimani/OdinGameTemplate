package game

import "core:math/linalg"
import "core:fmt"
import rl "vendor:raylib"

Runtime :: struct {}

runtime: ^Runtime

@(export)
game_update :: proc() -> bool {
	draw()
	return !rl.WindowShouldClose()
}

@(export)
game_init_window :: proc() {
	init_raylib_window()
}

@(export)
game_init :: proc() {
	runtime = new(Runtime)

	runtime^ = Runtime{}

	game_hot_reloaded(runtime)
}

@(export)
game_shutdown :: proc() {
	free(runtime)
}

@(export)
game_shutdown_window :: proc() {
	rl.CloseWindow()
}

@(export)
game_memory :: proc() -> rawptr {
	return runtime
}

@(export)
game_memory_size :: proc() -> int {
	return size_of(Runtime)
}

@(export)
game_hot_reloaded :: proc(mem: rawptr) {
	runtime = (^Runtime)(mem)
}

@(export)
game_force_reload :: proc() -> bool {
	return rl.IsKeyPressed(.F5)
}

@(export)
game_force_restart :: proc() -> bool {
	return rl.IsKeyPressed(.F6)
}
