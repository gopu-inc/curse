import .terminal as terminal

lt KEY_UP = 1001
lt KEY_DOWN = 1002
lt KEY_RIGHT = 1003
lt KEY_LEFT = 1004
lt KEY_HOME = 1005
lt KEY_END = 1006
lt KEY_DELETE = 1007
lt KEY_PAGE_UP = 1008
lt KEY_PAGE_DOWN = 1009

muts previous_width = 0
muts previous_height = 0
fn event(p_type: string, p_key_code: int, p_width: int, p_height: int): array {
    ret [p_type, p_key_code, p_width, p_height, ""]
}

fn key_event(p_key_code: int): array {
    lt result = event("key", p_key_code, 0, 0)
    if (p_key_code >= 32 && p_key_code <= 126) {
        lt printable = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
        result[4] = printable[p_key_code - 32]
    }
    ret result
}

fn decode_escape(p_timeout_ms: int): array {
    lt second = terminal::read_byte(p_timeout_ms)
    if (second != 91 && second != 79) { ret key_event(27) }
    lt third = terminal::read_byte(p_timeout_ms)
    if (third == 65) { ret key_event(KEY_UP) }
    if (third == 66) { ret key_event(KEY_DOWN) }
    if (third == 67) { ret key_event(KEY_RIGHT) }
    if (third == 68) { ret key_event(KEY_LEFT) }
    if (third == 72) { ret key_event(KEY_HOME) }
    if (third == 70) { ret key_event(KEY_END) }
    if (third >= 49 && third <= 57) {
        muts next = terminal::read_byte(p_timeout_ms)
        while ((next >= 48 && next <= 57) || next == 59) {
            next = terminal::read_byte(p_timeout_ms)
        }
        if (next == 126) {
            if (third == 51) { ret key_event(KEY_DELETE) }
            if (third == 53) { ret key_event(KEY_PAGE_UP) }
            if (third == 54) { ret key_event(KEY_PAGE_DOWN) }
        }
        if (next == 65) { ret key_event(KEY_UP) }
        if (next == 66) { ret key_event(KEY_DOWN) }
        if (next == 67) { ret key_event(KEY_RIGHT) }
        if (next == 68) { ret key_event(KEY_LEFT) }
        if (next == 72) { ret key_event(KEY_HOME) }
        if (next == 70) { ret key_event(KEY_END) }
    }
    ret key_event(27)
}

pub fn decode_byte(p_key_code: int, p_timeout_ms: int): array {
    if (p_key_code == 27) { ret decode_escape(p_timeout_ms) }
    if (p_key_code == -1) { ret event("timeout", 0, 0, 0) }
    if (p_key_code < -1) { ret event("closed", 0, 0, 0) }
    if (p_key_code == 3) { ret event("quit", p_key_code, 0, 0) }
    ret key_event(p_key_code)
}

pub fn poll(p_timeout_ms: int): array {
    lt current_width = terminal::width()
    lt current_height = terminal::height()
    lt resized = terminal::take_resize()
    if (previous_width == 0 || previous_height == 0) {
        previous_width = current_width
        previous_height = current_height
        ret event("resize", 0, current_width, current_height)
    }
    if (resized || current_width != previous_width || current_height != previous_height) {
        previous_width = current_width
        previous_height = current_height
        ret event("resize", 0, current_width, current_height)
    }
    lt input_code = terminal::read_byte(p_timeout_ms)
    if (input_code >= 128) {
        lt character = terminal::read_utf8_char(input_code, p_timeout_ms)
        lt result = key_event(input_code)
        result[4] = character
        ret result
    }
    ret decode_byte(input_code, p_timeout_ms)
}
