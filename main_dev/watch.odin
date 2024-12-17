package main_dev

import "core:fmt"
import "core:io"
import "core:os"
import "core:path/filepath"
import "core:thread"
import "core:time"

Watch_Callback :: #type proc(changed_file: string, user_data: rawptr)

watch_dir :: proc(root: []string, user_data: rawptr, callback: Watch_Callback) {
	thread.create_and_start_with_poly_data3(root, user_data, callback, watch_thread)

	watch_thread :: proc(root: []string, user_data: rawptr, callback: Watch_Callback) {
		all_paths: [dynamic]string
		write_times: [dynamic]os.File_Time
        should_scan := true

		for {
            if should_scan {
                should_scan = false

                if all_paths != nil {
					delete(all_paths)
				}
				if write_times != nil {
					delete(write_times)
				}

				all_paths = get_all_paths(root)
				write_times = get_initial_write_times(all_paths)
            }

			should_scan = watch_files(all_paths, write_times, user_data, callback)

			time.sleep(100)
		}
	}
}

@(private = "file")
watch_files :: proc(
	all_paths: [dynamic]string,
	write_times: [dynamic]os.File_Time,
    user_data: rawptr,
	callback: Watch_Callback,
) -> (
	should_scan: bool,
) {
	should_scan = false

	for path, index in all_paths {
		last_time := write_times[index]
		curr_time, err := os.last_write_time_by_name(path)

		if err != os.ERROR_NONE {
			should_scan = true
			continue
		}

		if last_time == curr_time {
			continue
		}

        fmt.println()
		callback(path, user_data)
		write_times[index] = curr_time

		if os.is_dir(path) {
			should_scan = true
		}
	}

	return
}

@(private = "file")
get_all_paths :: proc(root: []string) -> [dynamic]string {
	all_paths := make([dynamic]string)

	walk_callback := proc(
		info: os.File_Info,
		in_err: os.Error,
		user_data: rawptr,
	) -> (
		err: os.Error,
		skip_dir: bool,
	) {
		append((^[dynamic]string)(user_data), info.fullpath)
		return
	}

	for r in root {
		filepath.walk(r, walk_callback, &all_paths)
	}
	return all_paths
}

@(private = "file")
get_initial_write_times :: proc(all_paths: [dynamic]string) -> [dynamic]os.File_Time {
	write_times := make([dynamic]os.File_Time, 0, len(all_paths))

	for p in all_paths {
		write, err := os.last_write_time_by_name(p)
		if err != os.ERROR_NONE {
			fmt.println("Error getting last write time: ", err)
			continue
		}

		append(&write_times, write)
	}

	return write_times
}
