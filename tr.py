
"""
PURETUI - Minimal terminal UI framework
100% Python standard library, no external dependencies.

Python 3.8+
"""

import sys
import os
import time
import shutil
import tty
import termios
import select


# ==================================================
# TERMINAL ENGINE
# ==================================================

class Terminal:

    ESC = "\033["

    def __init__(self):
        self.old_settings = None
        self.width = 80
        self.height = 24

    def size(self):
        size = shutil.get_terminal_size((80, 24))
        self.width = size.columns
        self.height = size.lines
        return self.width, self.height

    def enter(self):
        if sys.stdin.isatty():
            self.old_settings = termios.tcgetattr(sys.stdin)
            tty.setcbreak(sys.stdin.fileno())

        sys.stdout.write("\033[?1049h")
        sys.stdout.write("\033[?25l")
        sys.stdout.flush()

    def exit(self):
        if self.old_settings is not None:
            termios.tcsetattr(
                sys.stdin,
                termios.TCSADRAIN,
                self.old_settings
            )

        sys.stdout.write("\033[?25h")
        sys.stdout.write("\033[?1049l")
        sys.stdout.flush()

    def clear(self):
        sys.stdout.write("\033[2J\033[H")

    def move(self, x, y):
        sys.stdout.write(f"\033[{y};{x}H")

    def color(self, fg=None, bg=None, bold=False):
        codes = []

        if bold:
            codes.append("1")

        if fg is not None:
            codes.append(str(fg))

        if bg is not None:
            codes.append(str(bg))

        if codes:
            sys.stdout.write(
                "\033[" + ";".join(codes) + "m"
            )

    def reset(self):
        sys.stdout.write("\033[0m")

    def write(self, text):
        sys.stdout.write(str(text))

    def refresh(self):
        sys.stdout.flush()

    def read_key(self):
        if not sys.stdin.isatty():
            return sys.stdin.read(1)

        ready, _, _ = select.select([sys.stdin], [], [], 0.1)

        if not ready:
            return None

        char = sys.stdin.read(1)

        if char == "\x1b":
            ready, _, _ = select.select(
                [sys.stdin], [], [], 0.02
            )

            if ready:
                char += sys.stdin.read(1)

                if char == "\x1b[":
                    ready, _, _ = select.select(
                        [sys.stdin], [], [], 0.02
                    )

                    if ready:
                        char += sys.stdin.read(1)

        return char


# ==================================================
# BASE WIDGET
# ==================================================

class Widget:

    def __init__(self):
        self.x = 1
        self.y = 1
        self.width = 20
        self.height = 1
        self.visible = True
        self.focused = False
        self.parent = None

    def render(self, terminal):
        pass

    def on_key(self, key):
        pass

    def focus(self):
        self.focused = True

    def blur(self):
        self.focused = False


# ==================================================
# LABEL
# ==================================================

class Label(Widget):

    def __init__(self, text):
        super().__init__()
        self.text = text

    def render(self, terminal):
        if self.visible:
            terminal.move(self.x, self.y)
            terminal.write(self.text)


# ==================================================
# BUTTON
# ==================================================

class Button(Widget):

    def __init__(self, text, callback=None):
        super().__init__()
        self.text = text
        self.callback = callback

    def render(self, terminal):
        if not self.visible:
            return

        terminal.move(self.x, self.y)

        if self.focused:
            terminal.color(30, 107, True)
        else:
            terminal.color(37, 40)

        terminal.write(f"  {self.text}  ")
        terminal.reset()

    def on_key(self, key):
        if key in ("\r", "\n", " "):
            if self.callback:
                self.callback()


# ==================================================
# INPUT
# ==================================================

class Input(Widget):

    def __init__(self, placeholder="Enter text"):
        super().__init__()
        self.value = ""
        self.placeholder = placeholder

    def render(self, terminal):
        if not self.visible:
            return

        terminal.move(self.x, self.y)

        value = self.value or self.placeholder

        terminal.write("[ ")
        terminal.color(36 if self.focused else 37)
        terminal.write(value[:self.width])
        terminal.reset()
        terminal.write(" ]")

    def on_key(self, key):
        if key in ("\x7f", "\b"):
            self.value = self.value[:-1]

        elif key and len(key) == 1:
            if key.isprintable():
                self.value += key


# ==================================================
# CONTAINERS
# ==================================================

class Container(Widget):

    def __init__(self, *children):
        super().__init__()
        self.children = list(children)

        for child in self.children:
            child.parent = self

    def add(self, widget):
        widget.parent = self
        self.children.append(widget)

    def render(self, terminal):
        for child in self.children:
            if child.visible:
                child.render(terminal)


class Vertical(Container):

    def render(self, terminal):
        y = self.y

        for child in self.children:
            child.x = self.x
            child.y = y
            child.render(terminal)
            y += child.height + 1


class Horizontal(Container):

    def render(self, terminal):
        x = self.x

        for child in self.children:
            child.x = x
            child.y = self.y
            child.render(terminal)
            x += child.width + 2


# ==================================================
# APPLICATION ENGINE
# ==================================================

class App:

    def __init__(self):
        self.terminal = Terminal()
        self.children = []
        self.running = False
        self.focus_index = 0
        self.title = "PureTUI"
        self.fps = 20

    def add(self, widget):
        self.children.append(widget)

    def widgets(self):
        result = []

        def collect(widget):
            if not widget.visible:
                return

            if isinstance(widget, (Button, Input)):
                result.append(widget)

            if isinstance(widget, Container):
                for child in widget.children:
                    collect(child)

        for child in self.children:
            collect(child)

        return result

    def focus(self):
        widgets = self.widgets()

        for widget in widgets:
            widget.blur()

        if widgets:
            self.focus_index %= len(widgets)
            widgets[self.focus_index].focus()

    def render(self):
        terminal = self.terminal
        terminal.clear()

        width, height = terminal.size()

        terminal.move(1, 1)
        terminal.color(36, bold=True)
        terminal.write(f" {self.title}")
        terminal.reset()

        terminal.move(1, 2)
        terminal.write("─" * max(1, width))

        y = 4

        for child in self.children:
            child.x = 3
            child.y = y
            child.render(terminal)

            if isinstance(child, Container):
                y += len(child.children) + 2
            else:
                y += 2

        terminal.move(1, height)
        terminal.color(90)
        terminal.write(" TAB: Navigate | ENTER: Select | CTRL+C: Quit")
        terminal.reset()

        terminal.refresh()

    def on_key(self, key):
        if key == "\t":
            self.focus_index += 1
            self.focus()

        elif key == "\x03":
            self.running = False

        else:
            widgets = self.widgets()

            if widgets:
                widgets[self.focus_index % len(widgets)].on_key(key)

    def compose(self):
        pass

    def run(self):
        self.compose()
        self.focus()

        self.running = True
        self.terminal.enter()

        try:
            while self.running:
                self.render()

                key = self.terminal.read_key()

                if key:
                    self.on_key(key)

                time.sleep(1 / self.fps)

        except KeyboardInterrupt:
            pass

        finally:
            self.running = False
            self.terminal.exit()


# ==================================================
# EXAMPLE APPLICATION
# ==================================================

class MyApp(App):

    def compose(self):

        self.title = "My First TUI"

        self.add(
            Label("Welcome to PureTUI!")
        )

        self.add(
            Label("A terminal framework written in pure Python.")
        )

        self.name = Input("Your name")
        self.add(self.name)

        self.add(
            Button(
                "Say Hello",
                self.say_hello
            )
        )

        self.add(
            Button(
                "Exit",
                self.stop
            )
        )

    def say_hello(self):
        print_message = self.name.value or "Developer"
        self.add(Label("Hello, " + print_message + "!"))

    def stop(self):
        self.running = False


if __name__ == "__main__":
    MyApp().run()

