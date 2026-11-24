import .screen as screen
import .terminal as terminal
terminal::start()
println("SIZE " + ("" + terminal::width()) + " " + ("" + terminal::height()))
lt frame = screen::create(80, 24)
println("CREATED")
screen::put_text(frame, 0, 0, "Hello", 10, -1, -1, 0)
println("DRAWN")
terminal::write_frame(screen::build_frame(frame))
while (true) {
    lt code = terminal::read_byte(100)
    if (code == 3) { break }
}
terminal::stop()
