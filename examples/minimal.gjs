import .src.app as app
import .src.widget as widgets

fn handle_event(event, root): bool {
    if (event[0] == "key" && event[1] == 113) { ret false }
    ret true
}

lt root = widgets::column([
    widgets::label("Curse terminal framework"),
    widgets::label("Press q to quit."),
    widgets::button("Ready")
])

app::run(root, handle_event)
