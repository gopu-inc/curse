import .layout as layout
import .widget as widgets
import .event as events

muts failed = false

lt horizontal = layout::split_horizontal([2, 3, 10, 8], 4)
lt left = horizontal[0]
lt right = horizontal[1]
if (left[2] != 4 || right[0] != 6 || right[2] != 6) {
    print("FAIL horizontal split")
    failed = true
} else {
    print("OK horizontal split")
}

lt vertical = layout::split_vertical([1, 2, 12, 9], 3)
lt top = vertical[0]
lt bottom = vertical[1]
if (top[3] != 3 || bottom[1] != 5 || bottom[3] != 6) {
    print("FAIL vertical split")
    failed = true
} else {
    print("OK vertical split")
}

lt centered = layout::center([0, 0, 20, 10], 8, 4)
if (centered[0] != 6 || centered[1] != 3) {
    print("FAIL center")
    failed = true
} else {
    print("OK center")
}

lt field = widgets::input("Name")
widgets::focus(field, true)
lt title = widgets::label("Curse")
if (field[2] != "Name" || field[3] != true || widgets::value(field) != "" || title[1] != "Curse") {
    print("FAIL widget state")
    failed = true
} else {
    print("OK widget state")
}

lt first_input = widgets::input("First")
lt action = widgets::button("Save")
lt second_input = widgets::input("Second")
lt form = widgets::column([widgets::label("Form"), first_input, action, second_input])
lt first_focus = widgets::focus_first(form)
lt nested_mutation = [[false]]
nested_mutation[0][0] = true
if (!first_focus || !form[1][1][3] || form[1][2][2] || form[1][3][3]) {
    print("FAIL initial focus")
    failed = true
} else {
    print("OK initial focus")
}
if (!widgets::input_focused(form)) {
    print("FAIL focused input query")
    failed = true
} else {
    print("OK focused input query")
}
widgets::handle_key(form, 65)
widgets::handle_key(form, 98)
widgets::handle_key(form, 127)
if (widgets::value(form[1][1]) != "A") {
    print("FAIL input editing")
    failed = true
} else {
    print("OK input editing")
}
widgets::handle_key(form, 9)
if (!form[1][2][2] || form[1][1][3] || form[1][3][3]) {
    print("FAIL next focus")
    failed = true
} else {
    print("OK next focus")
}
widgets::handle_key(form, 9)
if (!form[1][3][3] || form[1][2][2]) {
    print("FAIL nested focus")
    failed = true
} else {
    print("OK nested focus")
}
widgets::handle_key(form, 9)
if (!form[1][1][3] || form[1][3][3]) {
    print("FAIL focus wrap")
    failed = true
} else {
    print("OK focus wrap")
}

lt key = events::decode_byte(65, 0)
if (key[0] != "key" || key[1] != 65) {
    print("FAIL key event")
    failed = true
} else {
    print("OK key event")
}

lt quit = events::decode_byte(3, 0)
if (quit[0] != "quit") {
    print("FAIL quit key")
    failed = true
} else {
    print("OK quit key")
}

lt closed = events::decode_byte(-2, 0)
if (closed[0] != "closed") {
    print("FAIL closed input")
    failed = true
} else {
    print("OK closed input")
}

if (failed) { exit(1) }

