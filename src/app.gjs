import .terminal as terminal
import .event as events
import .widget as widgets

pub fn run(root: array, on_event) {
    if (!terminal::start()) {
        print("curse: interactive input requires a terminal")
        ret false
    }
    widgets::focus_first(root)
    terminal::clear()
    widgets::render(root, 0, 0, terminal::width(), terminal::height())
    muts running = true
    try {
        while (running) {
            lt event = events::poll(80)
            if (event[0] == "quit") {
                running = false
            } else if (event[0] == "closed") {
                running = false
            } else if (event[0] != "timeout") {
                if (event[0] == "key") {
                    widgets::handle_key(root, event[1])
                }
                running = on_event(event, root)
                if (running) {
                    terminal::clear()
                    widgets::render(root, 0, 0, terminal::width(), terminal::height())
                }
            }
        }
    } catch (error) {
        throw error
    } finally {
        terminal::stop()
    }
    ret true
}
