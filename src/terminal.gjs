lt ESC = "\033"

pub fn width(): int { ret curse_host_width() }
pub fn height(): int { ret curse_host_height() }
pub fn size(): array { ret [width(), height()] }

pub fn start(): bool { ret curse_host_start() == 1 }

pub fn stop() { curse_host_stop() }

pub fn clear() { print(ESC + "[2J" + ESC + "[H") }
pub fn show_cursor() { print(ESC + "[?25h") }
pub fn hide_cursor() { print(ESC + "[?25l") }
pub fn reset_style() { print(ESC + "[0m") }

pub fn move_to(x: int, y: int) {
    print(ESC + "[" + "" + (y + 1) + ";" + "" + (x + 1) + "H")
}

pub fn write(text: string) { print(text) }
pub fn flush(): bool { ret curse_host_flush() == 1 }
pub fn write_frame(frame: string): bool { ret curse_host_write_frame(frame) == 1 }
pub fn take_resize(): bool { ret curse_host_take_resize() == 1 }
pub fn truecolor(): bool { ret curse_host_capability(0) == 1 }
pub fn color256(): bool { ret curse_host_capability(1) == 1 }
pub fn unicode(): bool { ret curse_host_capability(2) == 1 }
pub fn utf8_length(text: string, byte_offset: int): int {
    ret curse_host_utf8_length(text, byte_offset)
}
pub fn cell_width(text: string, byte_offset: int): int {
    ret curse_host_unicode_width(text, byte_offset)
}
pub fn read_byte(timeout_ms: int): int { ret curse_host_read_byte(timeout_ms) }
pub fn read_utf8_char(first_byte: int, timeout_ms: int): string {
    ret curse_host_read_utf8_char(first_byte, timeout_ms)
}
pub fn now_ms(): int { ret curse_host_monotonic_ms() }
