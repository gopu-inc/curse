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
muts current_event = ["timeout", 0, 0, 0]

fn event(p_type: string, p_key_code: int, p_width: int, p_height: int): array {
    current_event[0] = p_type
    current_event[1] = p_key_code
    current_event[2] = p_width
    current_event[3] = p_height
    ret current_event
}

fn key_event(p_key_code: int): array { ret event("key", p_key_code, 0, 0) }

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
    if (third == 51 || third == 53) {
        lt fourth = terminal::read_byte(p_timeout_ms)
        if (fourth == 126 && third == 51) { ret key_event(KEY_DELETE) }
        if (fourth == 126 && third == 53) { ret key_event(KEY_PAGE_UP) }
    }
    if (third == 54) {
        lt fourth = terminal::read_byte(p_timeout_ms)
        if (fourth == 126) { ret key_event(KEY_PAGE_DOWN) }
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
    if (previous_width == 0 || previous_height == 0) {
        previous_width = current_width
        previous_height = current_height
        ret event("resize", 0, current_width, current_height)
    }
    if (current_width != previous_width || current_height != previous_height) {
        previous_width = current_width
        previous_height = current_height
        ret event("resize", 0, current_width, current_height)
    }
    lt input_code = terminal::read_byte(p_timeout_ms)
    ret decode_byte(input_code, 25)
}
