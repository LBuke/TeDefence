package tedefence

import c "core:c"
import "core:fmt"
import "game"

HelloWorld :: proc(x: u8) -> string {
	return fmt.tprintf("Hello World! %d", x)
}

main :: proc() {
	x: u8 = 255
	fmt.printf("%v %d\n", HelloWorld(x), 3.14)

	game.Bootstrap()
}
