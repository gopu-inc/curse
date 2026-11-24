import .terminal as terminal

fn number(value: int): string { ret "" + value }

fn color_code(color: int, foreground: bool): string {
    if (color < 0) {
        if (foreground) { ret "39" }
        ret "49"
    }
    if (color < 8) {
        if (foreground) { ret number(30 + color) }
        ret number(40 + color)
    }
    if (color < 16) {
        if (foreground) { ret number(90 + color - 8) }
        ret number(100 + color - 8)
    }
    if (foreground) { ret "38;5;" + number(color) }
    ret "48;5;" + number(color)
}

fn style_code(foreground: int, background: int, attributes: int): string {
    muts code = "\033[0"
    if (attributes == 1) { code = code + ";1" }
    code = code + ";" + color_code(foreground, true)
    code = code + ";" + color_code(background, false) + "m"
    ret code
}

pub fn create(width: int, height: int): array {
    lt safe_width = width
    lt safe_height = height
    if (safe_width < 1) { safe_width = 1 }
    if (safe_height < 1) { safe_height = 1 }
    muts glyphs = []
    muts foregrounds = []
    muts backgrounds = []
    muts attributes = []
    muts widths = []
    muts old_glyphs = []
    muts old_foregrounds = []
    muts old_backgrounds = []
    muts old_attributes = []
    muts old_widths = []
    muts active_indices = []
    muts previous_indices = []
    muts seen_frame = []
    muts count = safe_width * safe_height
    muts i = 0
    while (i < count) {
        glyphs = glyphs.push(" ")
        foregrounds = foregrounds.push(-1)
        backgrounds = backgrounds.push(-1)
        attributes = attributes.push(0)
        widths = widths.push(1)
        old_glyphs = old_glyphs.push(" ")
        old_foregrounds = old_foregrounds.push(-1)
        old_backgrounds = old_backgrounds.push(-1)
        old_attributes = old_attributes.push(0)
        old_widths = old_widths.push(1)
        active_indices = active_indices.push(0)
        previous_indices = previous_indices.push(0)
        seen_frame = seen_frame.push(-1)
        i = i + 1
    }
    ret [safe_width, safe_height, glyphs, foregrounds, backgrounds, attributes, widths,
         old_glyphs, old_foregrounds, old_backgrounds, old_attributes, old_widths,
         active_indices, previous_indices, 0, 0, seen_frame, 0]
}

pub fn width(buffer: array): int { ret buffer[0] }
pub fn height(buffer: array): int { ret buffer[1] }

pub fn invalidate(buffer: array) {
    muts i = 0
    while (i < buffer[15]) {
        lt index = buffer[13][i]
        buffer[7][index] = ""
        buffer[8][index] = -999
        buffer[9][index] = -999
        buffer[10][index] = -999
        buffer[11][index] = -999
        i = i + 1
    }
    i = 0
    while (i < buffer[14]) {
        lt index = buffer[12][i]
        buffer[7][index] = ""
        buffer[8][index] = -999
        buffer[9][index] = -999
        buffer[10][index] = -999
        buffer[11][index] = -999
        i = i + 1
    }
}

pub fn begin_frame(buffer: array) {
    muts i = 0
    while (i < buffer[14]) {
        lt index = buffer[12][i]
        buffer[2][index] = " "
        buffer[3][index] = -1
        buffer[4][index] = -1
        buffer[5][index] = 0
        buffer[6][index] = 1
        buffer[13][i] = index
        i = i + 1
    }
    buffer[15] = buffer[14]
    buffer[14] = 0
    if (buffer[17] >= 2000000000) { buffer[17] = 0 }
    else { buffer[17] = buffer[17] + 1 }
}

pub fn cell(buffer: array, x: int, y: int): array {
    if (x < 0 || y < 0 || x >= buffer[0] || y >= buffer[1]) { ret ["", -1, -1, 0, 0] }
    lt index = y * buffer[0] + x
    ret [buffer[2][index], buffer[3][index], buffer[4][index], buffer[5][index], buffer[6][index]]
}

fn mark_active(buffer: array, index: int) {
    if (buffer[16][index] != buffer[17]) {
        buffer[12][buffer[14]] = index
        buffer[14] = buffer[14] + 1
        buffer[16][index] = buffer[17]
    }
}

pub fn put(buffer: array, x: int, y: int, glyph: string, foreground: int, background: int, attributes: int, cell_width: int) {
    if (x < 0 || y < 0 || x >= buffer[0] || y >= buffer[1]) { ret }
    if (cell_width < 1) { ret }
    if (cell_width == 2 && x + 1 >= buffer[0]) { ret }
    lt index = y * buffer[0] + x
    buffer[2][index] = glyph
    buffer[3][index] = foreground
    buffer[4][index] = background
    buffer[5][index] = attributes
    buffer[6][index] = cell_width
    mark_active(buffer, index)
    if (cell_width == 2) {
        buffer[2][index + 1] = ""
        buffer[3][index + 1] = foreground
        buffer[4][index + 1] = background
        buffer[5][index + 1] = attributes
        buffer[6][index + 1] = -1
        mark_active(buffer, index + 1)
    }
}

pub fn put_text(buffer: array, x: int, y: int, text: string, max_width: int, foreground: int, background: int, attributes: int) {
    if (y < 0 || y >= buffer[1] || max_width <= 0) { ret }
    muts byte_offset = 0
    muts column = x
    muts end_column = x + max_width
    if (end_column > buffer[0]) { end_column = buffer[0] }
    if (end_column <= 0) { ret }
    muts last_index = -1
    muts join_next = false
    lt byte_count = text.len()
    while (byte_offset < byte_count) {
        lt glyph_length = terminal::utf8_length(text, byte_offset)
        if (glyph_length < 1) { break }
        lt glyph = gs_string_slice(text, number(byte_offset + 1), number(byte_offset + glyph_length))
        lt glyph_width = terminal::cell_width(text, byte_offset)
        if (glyph_width == 0) {
            if (last_index >= 0) { buffer[2][last_index] = buffer[2][last_index] + glyph }
            if (glyph == "‍") { join_next = true }
        } else {
            if (join_next && last_index >= 0) {
                buffer[2][last_index] = buffer[2][last_index] + glyph
                join_next = false
            } else {
                if (column + glyph_width > end_column) { break }
                put(buffer, column, y, glyph, foreground, background, attributes, glyph_width)
                if (column >= 0) { last_index = y * buffer[0] + column }
                else { last_index = -1 }
                column = column + glyph_width
            }
        }
        byte_offset = byte_offset + glyph_length
    }
}

pub fn fit_text(text: string, max_width: int): array {
    if (max_width <= 0) { ret ["", 0] }
    muts output = ""
    muts column = 0
    muts byte_offset = 0
    muts join_next = false
    lt byte_count = text.len()
    while (byte_offset < byte_count) {
        lt glyph_length = terminal::utf8_length(text, byte_offset)
        if (glyph_length < 1) { break }
        lt glyph = gs_string_slice(text, number(byte_offset + 1), number(byte_offset + glyph_length))
        lt glyph_width = terminal::cell_width(text, byte_offset)
        if (glyph_width == 0) {
            output = output + glyph
            if (glyph == "‍") { join_next = true }
        } else if (join_next) {
            output = output + glyph
            join_next = false
        } else {
            if (column + glyph_width > max_width) { break }
            output = output + glyph
            column = column + glyph_width
        }
        byte_offset = byte_offset + glyph_length
    }
    ret [output, column]
}

fn diff_cell(buffer: array, index: int, active_style: array): string {
    if (buffer[2][index] == buffer[7][index] &&
        buffer[3][index] == buffer[8][index] &&
        buffer[4][index] == buffer[9][index] &&
        buffer[5][index] == buffer[10][index] &&
        buffer[6][index] == buffer[11][index]) { ret "" }
    lt width = buffer[0]
    lt cell_width = buffer[6][index]
    muts output = ""
    if (cell_width != -1) {
        lt x = index % width
        lt y = index / width
        output = "\033[" + number(y + 1) + ";" + number(x + 1) + "H"
        if (active_style[0] != buffer[3][index] ||
            active_style[1] != buffer[4][index] ||
            active_style[2] != buffer[5][index]) {
            output = output + style_code(buffer[3][index], buffer[4][index], buffer[5][index])
            active_style[0] = buffer[3][index]
            active_style[1] = buffer[4][index]
            active_style[2] = buffer[5][index]
        }
        output = output + buffer[2][index]
    }
    buffer[7][index] = buffer[2][index]
    buffer[8][index] = buffer[3][index]
    buffer[9][index] = buffer[4][index]
    buffer[10][index] = buffer[5][index]
    buffer[11][index] = buffer[6][index]
    ret output
}

pub fn build_frame(buffer: array): string {
    muts frame = ""
    muts active_style = [-999, -999, -999]
    muts i = 0
    while (i < buffer[15]) {
        frame = frame + diff_cell(buffer, buffer[13][i], active_style)
        i = i + 1
    }
    i = 0
    while (i < buffer[14]) {
        frame = frame + diff_cell(buffer, buffer[12][i], active_style)
        i = i + 1
    }
    i = 0
    while (i < buffer[14]) {
        buffer[13][i] = buffer[12][i]
        i = i + 1
    }
    buffer[15] = buffer[14]
    if (frame != "") { ret frame + "\033[0m" }
    ret ""
}

pub fn present(buffer: array): bool {
    lt frame = build_frame(buffer)
    if (frame == "") { ret true }
    ret terminal::write_frame(frame)
}
