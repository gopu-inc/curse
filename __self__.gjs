import .src.app as app
import .src.event as events
import .src.layout as layout
import .src.screen as screen
import .src.terminal as terminal
import .src.widget as widgets

// Short aliases for common functions; grouped modules expose the full API.
pub fn run(root: array, on_event): bool { ret app::run(root, on_event) }

pub fn rect(left: int, top: int, width: int, height: int): array {
    ret layout::rect(left, top, width, height)
}
pub fn split_horizontal(area: array, first_width: int): array {
    ret layout::split_horizontal(area, first_width)
}
pub fn split_vertical(area: array, first_height: int): array {
    ret layout::split_vertical(area, first_height)
}
pub fn center(area: array, width: int, height: int): array {
    ret layout::center(area, width, height)
}
pub fn inset(area: array, top: int, right: int, bottom: int, left: int): array {
    ret layout::inset(area, top, right, bottom, left)
}

pub fn label(text: string): array { ret widgets::label(text) }
pub fn button(text: string): array { ret widgets::button(text) }
pub fn input(placeholder: string): array { ret widgets::input(placeholder) }
pub fn column(children: array): array { ret widgets::column(children) }
pub fn row(children: array): array { ret widgets::row(children) }
pub fn focus(widget: array, focused: bool): array { ret widgets::focus(widget, focused) }
pub fn is_focused(widget: array): bool { ret widgets::is_focused(widget) }
pub fn value(widget: array): string { ret widgets::value(widget) }
pub fn input_focused(root: array): bool { ret widgets::input_focused(root) }
pub fn focus_first(root: array): bool { ret widgets::focus_first(root) }
pub fn focus_next(root: array): bool { ret widgets::focus_next(root) }
pub fn handle_key(root: array, key_code: int): bool { ret widgets::handle_key(root, key_code) }
pub fn handle_text(root: array, text: string): bool { ret widgets::handle_text(root, text) }
pub fn render(widget: array, buffer: array, x: int, y: int, width: int, height: int) {
    widgets::render(widget, buffer, x, y, width, height)
}

pub fn poll(timeout_ms: int): array { ret events::poll(timeout_ms) }
pub fn decode_byte(key_code: int, timeout_ms: int): array {
    ret events::decode_byte(key_code, timeout_ms)
}

pub fn terminal_width(): int { ret terminal::width() }
pub fn terminal_height(): int { ret terminal::height() }
pub fn terminal_size(): array { ret terminal::size() }
pub fn terminal_start(): bool { ret terminal::start() }
pub fn terminal_stop() { terminal::stop() }
pub fn terminal_clear() { terminal::clear() }
pub fn terminal_show_cursor() { terminal::show_cursor() }
pub fn terminal_hide_cursor() { terminal::hide_cursor() }
pub fn terminal_reset_style() { terminal::reset_style() }
pub fn terminal_move_to(x: int, y: int) { terminal::move_to(x, y) }
pub fn terminal_write(text: string) { terminal::write(text) }
pub fn terminal_flush(): bool { ret terminal::flush() }
pub fn terminal_write_frame(frame: string): bool { ret terminal::write_frame(frame) }
pub fn terminal_take_resize(): bool { ret terminal::take_resize() }
pub fn terminal_truecolor(): bool { ret terminal::truecolor() }
pub fn terminal_color256(): bool { ret terminal::color256() }
pub fn terminal_unicode(): bool { ret terminal::unicode() }
pub fn terminal_utf8_length(text: string, byte_offset: int): int {
    ret terminal::utf8_length(text, byte_offset)
}
pub fn terminal_cell_width(text: string, byte_offset: int): int {
    ret terminal::cell_width(text, byte_offset)
}
pub fn terminal_read_byte(timeout_ms: int): int { ret terminal::read_byte(timeout_ms) }
pub fn terminal_read_utf8_char(first_byte: int, timeout_ms: int): string {
    ret terminal::read_utf8_char(first_byte, timeout_ms)
}
pub fn terminal_now_ms(): int { ret terminal::now_ms() }

pub fn screen_create(width: int, height: int): array { ret screen::create(width, height) }
pub fn screen_width(buffer: array): int { ret screen::width(buffer) }
pub fn screen_height(buffer: array): int { ret screen::height(buffer) }
pub fn screen_begin_frame(buffer: array) { screen::begin_frame(buffer) }
pub fn screen_invalidate(buffer: array) { screen::invalidate(buffer) }
pub fn screen_cell(buffer: array, x: int, y: int): array { ret screen::cell(buffer, x, y) }
pub fn screen_put(buffer: array, x: int, y: int, glyph: string, foreground: int,
                  background: int, attributes: int, cell_width: int) {
    screen::put(buffer, x, y, glyph, foreground, background, attributes, cell_width)
}
pub fn screen_put_text(buffer: array, x: int, y: int, text: string, max_width: int,
                       foreground: int, background: int, attributes: int) {
    screen::put_text(buffer, x, y, text, max_width, foreground, background, attributes)
}
pub fn screen_build_frame(buffer: array): string { ret screen::build_frame(buffer) }
pub fn screen_present(buffer: array): bool { ret screen::present(buffer) }
