package main_dev

import "core:fmt"
import "core:strings"
import "core:c/libc"
import "core:os"

build_game :: proc(module: string, version: int) {
    if !os.exists("bin") {
        os.make_directory("bin")
    }

    if !os.exists("bin/pdbs") {
        os.make_directory("bin/pdbs")
    }

    cmd := fmt.tprintf("odin build game -debug -build-mode:dll -out:./bin/game_%d.dll -o:none -pdb-name:./bin/pdbs/game_%d.pdb > nul", version, version)
    cmd_cstring := strings.unsafe_string_to_cstring(cmd)
    libc.system(cmd_cstring)
}
