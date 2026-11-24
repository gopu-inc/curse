import .terminal as terminal
import .event as events
import .widget as widgets

fn draw(root: array): bool {
    lt frame = widgets::render_terminal(root, terminal::width(), terminal::height())
    ret terminal::write_frame(frame)
}

pub fn run(root: array, on_event) {
    ret run_at(root, on_event, 120)
}

pub fn run_at(root: array, on_event, fps: int) {
    muts target_fps = fps
    if (target_fps < 1) { target_fps = 1 }
    if (target_fps > 240) { target_fps = 240 }
    lt frame_interval = 1000 / target_fps
    if (frame_interval < 4) { frame_interval = 4 }
    if (!terminal::start()) {
        print("curse: interactive input requires a terminal")
        ret false
    }
    try {
        widgets::invalidate_terminal(root)
        widgets::focus_first(root)
        if (!draw(root)) { throw "curse: failed to write initial frame" }
        muts running = true
        muts last_frame = terminal::now_ms()
        while (running) {
            lt now = terminal::now_ms()
            muts elapsed = now - last_frame
            if (elapsed < 0) { elapsed = elapsed + 2000000000 }
            muts wait_ms = frame_interval - elapsed
            if (wait_ms < 0) { wait_ms = 0 }
            lt event = events::poll(wait_ms)
            if (event[0] == "quit") {
                running = false
            } else if (event[0] == "closed") {
                running = false
            } else {
                if (event[0] == "key") {
                    if (event[4] != "") { widgets::handle_text(root, event[4]) }
                    else { widgets::handle_key(root, event[1]) }
                }
                running = on_event(event, root)
                lt after_event = terminal::now_ms()
                muts frame_elapsed = after_event - last_frame
                if (frame_elapsed < 0) { frame_elapsed = frame_elapsed + 2000000000 }
                if (running && frame_elapsed >= frame_interval) {
                    if (event[0] == "resize") {
                        terminal::clear()
                        widgets::invalidate_terminal(root)
                    }
                    if (!draw(root)) { throw "curse: failed to write frame" }
                    last_frame = terminal::now_ms()
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
