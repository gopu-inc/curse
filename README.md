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
containing `curse/`, import the framework with `import curse`, then use
`curse::app`, `curse::events`, `curse::layout`, `curse::terminal`, and
`curse::widgets`.

Run the non-interactive checks from the Curse directory with `make test`.
They use the rebuilt Goscript binary and set its standard-library path. The
foundation checks intentionally do not start the interactive event loop.
To invoke the test with `gd` directly, point it at that build first:

```sh
export PATH="../goscript/build/bin:$PATH"
export GOSCRIPT_SHARE_DIR="../goscript/lib"
gd tests/foundation.gjs
```

## Current foundation

- `src/terminal.gjs`: alternate screen, cursor, dimensions, raw mode and output.
- `src/event.gjs`: byte/key events, arrow/navigation keys, Ctrl+C and resize.
- `src/layout.gjs`: rectangles, horizontal/vertical splits and centering.
- `src/widget.gjs`: labels, buttons, inputs and row/column containers.
- `src/app.gjs`: render/poll/dispatch loop with terminal restoration on exit.
- Tab moves focus across buttons and inputs; backspace and printable keys edit
  the focused input.
- The app redraws only after input or resize events, so idle polling does not
  repeatedly clear the screen.

The initial widget model is array-based and intentionally small while the
public API settles. Input events currently expose terminal bytes, not decoded
Unicode code points. Resize is detected during polling. More advanced focus
management, input editing, styling, clipping and differential rendering are
not part of this first foundation.

## Example

```sh
GOSCRIPT_SHARE_DIR=../goscript/lib ../goscript/build/bin/gd examples/minimal.gjs
```

The application callback receives `[event_type, key_code, width, height]`.
Arrow keys use codes `1001` through `1004`; `q` quits in the example and
Ctrl+C is emitted as a `quit` event. Apps should also return `false` from
their callback to stop the loop. The event array is reused between polls;
copy out values that need to outlive the callback.
