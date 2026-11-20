import .terminal as terminal

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
