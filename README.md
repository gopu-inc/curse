# Curse

Curse is a terminal UI framework written in Goscript. Its host boundary is
limited to terminal mode, terminal dimensions, and timed byte input in the
Goscript interpreter; widgets, event decoding, layout, rendering, and the app
loop live in Goscript.

## Requirements

- A Goscript build that includes the `curse_host_*` terminal primitives.
- A POSIX terminal for interactive raw-key input.

Rebuild Goscript from `../goscript` after the runtime change:

```sh
cd ../goscript
make
```

The `gd` found in `PATH` must be that rebuilt runtime; an older installed
binary does not provide Curse's terminal primitives.

## Imports and tests

The root `__self__.gjs` is Curse's package entry point. From the directory
containing `curse/`, import the framework with `import curse`. Common functions
are available directly (`curse::inset`, `curse::input`, `curse::run`); the full
modules remain available as `curse::layout`, `curse::widgets`, `curse::events`,
`curse::terminal`, `curse::screen`, and `curse::app`.

```goscript
import curse

lt content = curse::inset(curse::rect(0, 0, 80, 24), 1, 2, 1, 2)
lt name = curse::input("Name")
```

Run the bundled interactive dashboard from the package directory with
`gd -c curse`, Goscript's equivalent of `python -m`. To install the package
and create a `curse` command from its manifest, run:

```sh
sudo golem install --local .
curse
```

The manifest declares `entry = "main.gjs"` and `command = "curse"`. Golem
installs the package and resolved dependencies under
`/usr/local/share/goscript`, then creates `/usr/local/bin/curse`. Set
`GOSCRIPT_MODULE_DIR` and `GOSCRIPT_BIN_DIR` to choose another prefix.

Run the non-interactive checks from the Curse directory with `make test`.
They use the rebuilt Goscript binary and set its standard-library path. The
foundation checks intentionally do not start the interactive event loop.
To invoke the test with `gd` directly, point it at that build first:

```sh
export PATH="../goscript/build/bin:$PATH"
export GOSCRIPT_SHARE_DIR="../goscript/lib"
gd tests/foundation.gjs
```

## Current API

- `src/terminal.gjs`: alternate screen, cursor, dimensions, raw mode and output.
- `src/event.gjs`: independent event arrays, UTF-8 text, arrow/navigation keys, Ctrl+C,
  resize, and common CSI modifier forms.
- `src/layout.gjs`: rectangles, horizontal/vertical splits, centering and inset.
- `src/widget.gjs`: labels, buttons, editable inputs, and row/column containers.
- `src/app.gjs`: render/poll/dispatch loop at 120 FPS by default, with terminal
  restoration on exit. `curse::app::run_at(root, callback, fps)` accepts 1–240 FPS.
- Tab moves focus recursively across buttons and inputs. Inputs support a visible
  cursor, insertion, left/right, Home/End, Backspace and Delete.
- Frames follow the selected cadence while key events are handled as they
  arrive. Differential output sends only changed cells, keeping idle frames
  cheap.

The widget model is array-based while the public API settles. The host assembles
UTF-8 input into complete characters, and input editing preserves UTF-8
boundaries. Text drawing uses terminal cell widths and clips against the available
rectangle. Styling remains limited to default colors, the 16/256-color ANSI
palette and a bold attribute. Mouse input, scroll containers, richer layout
constraints, and full grapheme-cluster handling are not implemented yet.

## Example

```sh
GOSCRIPT_SHARE_DIR=../goscript/lib ../goscript/build/bin/gd examples/minimal.gjs
```

For a complete interactive sample with working buttons and a text field, run:

```sh
GOSCRIPT_SHARE_DIR=../goscript/lib ../goscript/build/bin/gd examples/complete.gjs
```

The full user guide, including the single-import API, every module, and runnable
examples, is in [docs/GUIDE.md](docs/GUIDE.md).

The application callback receives `[event_type, key_code, width, height, text]`.
`text` contains a complete printable character (including multibyte UTF-8) for
text input and is empty for other events.
Arrow keys use codes `1001` through `1004`; `q` quits in the example and Ctrl+C
is emitted as a `quit` event. The callback runs for timeout events too, which
lets applications update time-based state. Return `false` to stop the loop.
Each poll returns a new event array, so values can be retained safely.
