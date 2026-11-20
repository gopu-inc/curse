lt ESC = "\033"

pub fn width(): int { ret curse_host_width() }
pub fn height(): int { ret curse_host_height() }
pub fn size(): array { ret [width(), height()] }

pub fn start(): bool {
    if (curse_host_raw(1) != 1) { ret false }
    print(ESC + "[?1049h" + ESC + "[?25l" + ESC + "[2J" + ESC + "[H")
    ret true
}

pub fn stop() {
    print(ESC + "[0m" + ESC + "[?25h" + ESC + "[?1049l")
    curse_host_raw(0)
}

pub fn clear() { print(ESC + "[2J" + ESC + "[H") }
pub fn show_cursor() { print(ESC + "[?25h") }
pub fn hide_cursor() { print(ESC + "[?25l") }
pub fn reset_style() { print(ESC + "[0m") }

pub fn move_to(x: int, y: int) {
    print(ESC + "[" + "" + (y + 1) + ";" + "" + (x + 1) + "H")
}

pub fn write(text: string) { print(text) }
pub fn read_byte(timeout_ms: int): int { ret curse_host_read_byte(timeout_ms) }
