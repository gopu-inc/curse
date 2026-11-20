import .terminal as terminal

lt PRINTABLE_ASCII = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

pub fn label(text: string): array { ret ["label", text] }
pub fn button(text: string): array { ret ["button", text, false] }
pub fn input(placeholder: string): array { ret ["input", "", placeholder, false] }
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
    if (kind != "column" && kind != "row") {
        if (focusable(widget)) {
            if (widget[0] == "button") { widget[2] = state[0] == target }
            if (widget[0] == "input") { widget[3] = state[0] == target }
        }
        ret
    }
    lt children = widget[1]
    lt count = children.len()
    lt i = 0
    while (i < count) {
        if (focusable(children[i])) {
            if (children[i][0] == "button") { widget[1][i][2] = state[0] == target }
            if (children[i][0] == "input") { widget[1][i][3] = state[0] == target }
            state[0] = state[0] + 1
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

fn edit_focused(widget: array, key_code: int): bool {
    lt kind = widget[0]
    if (kind != "column" && kind != "row") {
        if (!focusable(widget) || !is_focused_widget(widget) || widget[0] != "input") { ret false }
        if (key_code == 8 || key_code == 127) {
            lt text = widget[1]
            lt text_length = text.len()
            if (text_length > 0) { widget[1] = gs_string_slice(text, "1", "" + (text_length - 1)) }
            ret true
        }
        if (key_code >= 32 && key_code <= 126) {
            widget[1] = widget[1] + PRINTABLE_ASCII[key_code - 32]
            ret true
        }
        ret false
    }
    lt children = widget[1]
    lt count = children.len()
    lt i = 0
    while (i < count) {
        lt child = children[i]
        if (focusable(child) && is_focused_widget(child) && child[0] == "input") {
            if (key_code == 8 || key_code == 127) {
                lt text = child[1]
                lt text_length = text.len()
                if (text_length > 0) {
                    widget[1][i][1] = gs_string_slice(text, "1", "" + (text_length - 1))
                }
                ret true
            }
            if (key_code >= 32 && key_code <= 126) {
                widget[1][i][1] = child[1] + PRINTABLE_ASCII[key_code - 32]
                ret true
            }
        }
        i = i + 1
    }
    ret false
}

pub fn handle_key(root: array, key_code: int): bool {
    if (key_code == 9) { ret focus_next(root) }
    ret edit_focused(root, key_code)
}

pub fn render(widget: array, x: int, y: int, width: int, height: int) {
    lt kind = widget[0]
    if (kind == "label") {
        terminal::move_to(x, y)
        terminal::write(gpm_tui_truncate(widget[1], width))
        ret
    }
    if (kind == "button") {
        terminal::move_to(x, y)
        if (widget[2]) {
            terminal::write("\033[30;46m " + widget[1] + " \033[0m")
        } else {
            terminal::write(" " + widget[1] + " ")
        }
        ret
    }
    if (kind == "input") {
        terminal::move_to(x, y)
        lt text = widget[1]
        if (text == "") { text = widget[2] }
        if (widget[3]) {
            terminal::write("\033[36m[" + gpm_tui_truncate(text, width - 2) + "]\033[0m")
        } else {
            terminal::write("[" + gpm_tui_truncate(text, width - 2) + "]")
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
                lt child_height = height / count
                lt child_y = y + i * child_height
                if (i == count - 1) { child_height = height - (count - 1) * child_height }
                render(children[i], x, child_y, width, child_height)
            } else {
                lt child_width = width / count
                lt child_x = x + i * child_width
                if (i == count - 1) { child_width = width - (count - 1) * child_width }
                render(children[i], child_x, y, child_width, height)
            }
            i = i + 1
        }
    }
}
