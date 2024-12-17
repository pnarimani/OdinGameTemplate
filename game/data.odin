package game

import "core:fmt"

Runtime :: struct {}

runtime: ^Runtime

@(export)
game_update :: proc() -> bool {
	return true
}

@(export)
game_init_window :: proc() {
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
	return false
}

@(export)
game_force_restart :: proc() -> bool {
	return false
}
