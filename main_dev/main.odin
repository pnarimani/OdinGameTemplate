package main_dev

import "core:c/libc"
import "core:dynlib"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"

main :: proc() {
	context.logger = log.create_console_logger()

	default_allocator := context.allocator
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, default_allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)

	files_changed := false

	watch_dir([]string{"game"}, &files_changed, proc(p: string, data: rawptr) {
		(^bool)(data)^ = true
	})

	build_game("game", 0)

	version := 0
	api, ok := load_game_api(version)

	if !ok {
		fmt.println("Failed to load Game API")
		return
	}

	api.init_window()
	api.init()

	window_open := true
	for window_open {
		window_open = api.update()
		force_reload := api.force_reload()
		force_restart := api.force_restart()
		should_reload := files_changed || force_reload || force_restart

		if should_reload {
			files_changed = false

			version += 1
			build_game("game", version)

			old_api := api
			api, _ = load_game_api(version)

			if force_restart {
				old_api.shutdown()
				reset_tracking_allocator(&tracking_allocator)
				api.init()
			} else {
				api.hot_reloaded(old_api.memory())
			}

			unload_game_api(&old_api)
		}

		if len(tracking_allocator.bad_free_array) > 0 {
			for b in tracking_allocator.bad_free_array {
				log.errorf("Bad free at: %v", b.location)
			}
		}

		free_all(context.temp_allocator)
	}

	free_all(context.temp_allocator)
	api.shutdown()
	reset_tracking_allocator(&tracking_allocator)

	api.shutdown_window()
	unload_game_api(&api)
	mem.tracking_allocator_destroy(&tracking_allocator)
}


reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) -> bool {
	err := false

	for _, value in a.allocation_map {
		fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
		err = true
	}

	mem.tracking_allocator_clear(a)
	return err
}

// make game use good GPU on laptops etc

@(export)
NvOptimusEnablement: u32 = 1

@(export)
AmdPowerXpressRequestHighPerformance: i32 = 1