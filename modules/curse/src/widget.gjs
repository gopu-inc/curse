import .screen as screen
import .terminal as terminal

lt PRINTABLE_ASCII = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
fn number(value: int): string { ret "" + value }
muts terminal_cache = []
muts terminal_cache_cursor = 0

pub fn label(text: string): array { ret ["label", text] }
pub fn button(text: string): array { ret ["button", text, false] }
pub fn input(placeholder: string): array { ret ["input", "", placeholder, false, 0] }
pub fn column(children: array): array { ret ["column", children] }
pub fn row(children: array): array { ret ["row", children] }

pub fn focus(widget: array, focused: bool): array {
    if (widget[0] == "button") { widget[2] = focused }
    if (widget[0] == "input") { widget[3] = focused }
    ret widget
}

pub fn value(widget: array): string {
    if (widget[0] == "input") { ret widget[1] }
    ret ""
}

fn focusable(widget: array): bool {
    ret widget[0] == "button" || widget[0] == "input"
}

fn is_focused_widget(widget: array): bool {
    if (widget[0] == "button") { ret widget[2] }
    if (widget[0] == "input") { ret widget[3] }
    ret false
}

pub fn is_focused(widget: array): bool { ret is_focused_widget(widget) }

fn contains_focused_input(widget: array): bool {
    lt kind = widget[0]
    if (kind == "input") { ret widget[3] }
    if (kind == "column" || kind == "row") {
        lt children = widget[1]
        lt count = children.len()
        lt i = 0
        while (i < count) {
            if (contains_focused_input(children[i])) { ret true }
            i = i + 1
        }
    }
    ret false
}

pub fn input_focused(root: array): bool { ret contains_focused_input(root) }

fn scan_focus(widget: array, state: array) {
    if (focusable(widget)) {
        if (is_focused_widget(widget)) { state[1] = state[0] }
        state[0] = state[0] + 1
        ret
    }
    lt kind = widget[0]
    if (kind == "column" || kind == "row") {
        lt children = widget[1]
        lt count = children.len()
        lt i = 0
        while (i < count) {
            scan_focus(children[i], state)
            i = i + 1
        }
    }
}

fn apply_focus(widget: array, state: array, target: int) {
    lt kind = widget[0]
    if (focusable(widget)) {
        if (widget[0] == "button") { widget[2] = state[0] == target }
        if (widget[0] == "input") {
            widget[3] = state[0] == target
        }
        state[0] = state[0] + 1
        ret
    }
    if (kind != "column" && kind != "row") { ret }
    lt children = widget[1]
    lt count = children.len()
    lt i = 0
    while (i < count) {
        if (focusable(children[i])) {
            if (children[i][0] == "button") { widget[1][i][2] = state[0] == target }
            if (children[i][0] == "input") { widget[1][i][3] = state[0] == target }
            state[0] = state[0] + 1
        } else if (children[i][0] == "column" || children[i][0] == "row") {
            apply_focus(children[i], state, target)
        }
        i = i + 1
    }
}

fn set_focus_at(root: array, target: int): bool {
    lt state = [0, -1]
    scan_focus(root, state)
    if (state[0] < 1) { ret false }
    if (target < 0 || target >= state[0]) { target = 0 }
    state[0] = 0
    apply_focus(root, state, target)
    ret true
}

pub fn focus_first(root: array): bool { ret set_focus_at(root, 0) }

pub fn focus_next(root: array): bool {
    lt state = [0, -1]
    scan_focus(root, state)
    if (state[0] < 1) { ret false }
    lt target = state[1] + 1
    if (target >= state[0]) { target = 0 }
    state[0] = 0
    apply_focus(root, state, target)
    ret true
}

fn previous_boundary(text: string, cursor: int): int {
    muts offset = 0
    muts previous = 0
    while (offset < cursor) {
        previous = offset
        lt count = terminal::utf8_length(text, offset)
        if (count < 1) { ret previous }
        offset = offset + count
    }
    ret previous
}

fn next_boundary(text: string, cursor: int): int {
    lt count = terminal::utf8_length(text, cursor)
    if (count < 1) { ret cursor }
    ret cursor + count
}

fn edit_input(widget: array, key_code: int, text: string): array {
    lt content = widget[1]
    lt length = content.len()
    lt cursor = widget[4]
    if (key_code == 1004) {
        if (cursor > 0) { cursor = previous_boundary(content, cursor) }
        ret [true, content, cursor]
    }
    if (key_code == 1003) {
        if (cursor < length) { cursor = next_boundary(content, cursor) }
        ret [true, content, cursor]
    }
    if (key_code == 1005 || key_code == 1) {
        ret [true, content, 0]
    }
    if (key_code == 1006 || key_code == 5) {
        ret [true, content, length]
    }
    if (key_code == 8 || key_code == 127) {
        if (cursor > 0) {
            lt start = previous_boundary(content, cursor)
            content = gs_string_slice(content, "1", "" + start) + gs_string_slice(content, "" + (cursor + 1), "")
            cursor = start
        }
        ret [true, content, cursor]
    }
    if (key_code == 1007) {
        if (cursor < length) { content = gs_string_slice(content, "1", "" + cursor) + gs_string_slice(content, "" + (next_boundary(content, cursor) + 1), "") }
        ret [true, content, cursor]
    }
    if (text != "") {
        content = gs_string_slice(content, "1", "" + cursor) + text + gs_string_slice(content, "" + (cursor + 1), "")
        cursor = cursor + text.len()
        ret [true, content, cursor]
    }
    ret [false, content, cursor]
}

fn edit_focused(widget: array, key_code: int, text: string): bool {
    lt kind = widget[0]
    if (kind == "input" && is_focused_widget(widget)) {
        lt update = edit_input(widget, key_code, text)
        widget[1] = update[1]
        widget[4] = update[2]
        ret update[0]
    }
    if (kind != "column" && kind != "row") { ret false }
    lt children = widget[1]
    lt count = children.len()
    lt i = 0
    while (i < count) {
        if (children[i][0] == "input" && is_focused_widget(children[i])) {
            lt update = edit_input(children[i], key_code, text)
            widget[1][i][1] = update[1]
            widget[1][i][4] = update[2]
            if (update[0]) { ret true }
        } else if (children[i][0] == "column" || children[i][0] == "row") {
            if (edit_focused(widget[1][i], key_code, text)) { ret true }
        }
        i = i + 1
    }
    ret false
}

pub fn handle_key(root: array, key_code: int): bool {
    if (key_code == 9) { ret focus_next(root) }
    if (key_code >= 32 && key_code <= 126) { ret handle_text(root, PRINTABLE_ASCII[key_code - 32]) }
    ret edit_focused(root, key_code, "")
}

pub fn handle_text(root: array, text: string): bool { ret edit_focused(root, 0, text) }

fn natural_height(widget: array): int {
    lt kind = widget[0]
    if (kind != "column" && kind != "row") { ret 1 }
    lt children = widget[1]
    lt count = children.len()
    if (kind == "row") {
        muts largest = 1
        muts i = 0
        while (i < count) {
            lt child_height = natural_height(children[i])
            if (child_height > largest) { largest = child_height }
            i = i + 1
        }
        ret largest
    }
    muts total = 0
    muts i = 0
    while (i < count) {
        total = total + natural_height(children[i])
        i = i + 1
    }
    ret total
}

pub fn render(widget: array, buffer: array, x: int, y: int, width: int, height: int) {
    if (width <= 0 || height <= 0) { ret }
    lt kind = widget[0]
    if (kind == "label") {
        screen::put_text(buffer, x, y, widget[1], width, -1, -1, 0)
        ret
    }
    if (kind == "button") {
        if (widget[2]) {
            screen::put_text(buffer, x, y, " " + widget[1] + " ", width, 0, 6, 1)
        } else {
            screen::put_text(buffer, x, y, " " + widget[1] + " ", width, -1, -1, 0)
        }
        ret
    }
    if (kind == "input") {
        lt text = widget[1]
        lt input_length = widget[1].len()
        if (text == "") { text = widget[2] }
        if (widget[3]) {
            lt cursor = widget[4]
            if (cursor > input_length) { cursor = input_length }
            if (widget[1] == "") { cursor = 0 }
            lt shown = "[" + gs_string_slice(text, "1", "" + cursor) + "|" + gs_string_slice(text, "" + (cursor + 1), "") + "]"
            screen::put_text(buffer, x, y, shown, width, 6, -1, 0)
        } else {
            screen::put_text(buffer, x, y, "[" + text + "]", width, -1, -1, 0)
        }
        ret
    }
    if (kind == "column" || kind == "row") {
        lt children = widget[1]
        lt count = children.len()
        if (count < 1) { ret }
        lt i = 0
        while (i < count) {
            if (kind == "column") {
                lt base_height = height / count
                lt remaining = height - (count * base_height)
                lt child_height = natural_height(children[i])
                if (child_height > base_height) { child_height = base_height }
                if (i < remaining) { child_height = child_height + 1 }
                if (child_height > height) { child_height = height }
                muts child_y = y
                muts before = 0
                while (before < i) {
                    lt before_height = natural_height(children[before])
                    if (before_height > base_height) { before_height = base_height }
                    if (before < remaining) { before_height = before_height + 1 }
                    if (before_height > height) { before_height = height }
                    child_y = child_y + before_height
                    before = before + 1
                }
                render(children[i], buffer, x, child_y, width, child_height)
            } else {
                lt child_width = width / count
                lt child_x = x + i * child_width
                if (i == count - 1) { child_width = width - (count - 1) * child_width }
                render(children[i], buffer, child_x, y, child_width, height)
            }
            i = i + 1
        }
    }
}

fn render_terminal_node(widget: array, x: int, y: int, width: int, height: int): string {
    if (width <= 0 || height <= 0 || y < 0) { ret "" }
    lt kind = widget[0]
    if (kind == "label" || kind == "button" || kind == "input") {
        muts text = ""
        muts style = ""
        if (kind == "label") { text = widget[1] }
        if (kind == "button") {
            text = " " + widget[1] + " "
            if (widget[2]) { style = "\033[0;30;46;1m" }
        }
        if (kind == "input") {
            text = widget[1]
            if (text == "") { text = widget[2] }
            if (widget[3]) {
                lt cursor = widget[4]
                if (cursor > widget[1].len()) { cursor = widget[1].len() }
                if (widget[1] == "") { cursor = 0 }
                text = "[" + gs_string_slice(widget[1], "1", "" + cursor) + "|" +
                       gs_string_slice(text, "" + (cursor + 1), "") + "]"
                style = "\033[0;36m"
            } else { text = "[" + text + "]" }
        }
        lt cache_key = number(x) + ":" + number(y) + ":" + number(width) + ":" + style + text
        lt cache_index = terminal_cache_cursor
        terminal_cache_cursor = terminal_cache_cursor + 1
        if (cache_index < terminal_cache.len()) {
            if (terminal_cache[cache_index] == cache_key) { ret "" }
            terminal_cache[cache_index] = cache_key
        } else {
            terminal_cache = terminal_cache.push(cache_key)
        }
        lt fitted = screen::fit_text(text, width)
        muts padding = width - fitted[1]
        if (padding < 0) { padding = 0 }
        lt spaces = gpm_tui_repeat(" ", padding)
        muts output = "\033[" + number(y + 1) + ";" + number(x + 1) + "H"
        output = output + style + fitted[0]
        if (style != "") { output = output + "\033[0m" }
        output = output + spaces
        ret output
    }
    if (kind != "column" && kind != "row") { ret "" }
    lt children = widget[1]
    lt count = children.len()
    if (count < 1) { ret "" }
    muts output = ""
    muts i = 0
    if (kind == "column") {
        lt base_height = height / count
        lt remaining = height - count * base_height
        muts child_y = y
        while (i < count) {
            lt natural = natural_height(children[i])
            muts child_height = natural
            if (child_height > base_height) { child_height = base_height }
            if (i < remaining) { child_height = child_height + 1 }
            if (child_height > height) { child_height = height }
            output = output + render_terminal_node(children[i], x, child_y, width, child_height)
            child_y = child_y + child_height
            i = i + 1
        }
        ret output
    }
    lt child_width = width / count
    while (i < count) {
        muts current_width = child_width
        if (i == count - 1) { current_width = width - (count - 1) * child_width }
        output = output + render_terminal_node(children[i], x + i * child_width, y, current_width, height)
        i = i + 1
    }
    ret output
}

pub fn render_terminal(root: array, width: int, height: int): string {
    terminal_cache_cursor = 0
    ret render_terminal_node(root, 0, 0, width, height)
}

pub fn invalidate_terminal(root: array) {
    terminal_cache = []
    terminal_cache_cursor = 0
}
