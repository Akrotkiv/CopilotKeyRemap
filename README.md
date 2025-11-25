# Copilot Key → RControl with Sticky Keys

AutoHotkey script that remaps the **Copilot key** (on Windows 11 laptops) to **Right Control (RCtrl)** with **Sticky Keys** functionality.

## What does this script do?

The script redirects the Copilot key (which normally sends the combination `LShift + LWin + F23`) to the Right Control key with two modes of operation:

### 🔹 Sticky Mode (single press)
- Press the Copilot key **once**
- RControl activates as "sticky" - it stays pressed
- Press **any other key** (e.g., `C`)
- The combination `Ctrl+C` is executed
- RControl **automatically releases**

**Use case:** Quick keyboard shortcuts without holding Control

### 🔒 Locked Mode (double press)
- Press the Copilot key **twice in quick succession**
- RControl is **locked** (stays pressed permanently)
- All subsequent keys are executed with Control
- Press Copilot again to **unlock**

**Use case:** Series of Control commands without repetition (e.g., text selection with arrows)

## Why this script?

Windows Sticky Keys don't work with remapped keys from AutoHotkey because Sticky Keys monitor only physical keys at the driver level. This script implements its own Sticky Keys functionality directly in AutoHotkey.

## Installation

1. Install [AutoHotkey v2](https://www.autohotkey.com/)
2. Save the script as `remap_copilot_key_sticky.ahk`
3. Run by double-clicking the file
4. (Optional) Add to Startup folder for automatic launch at Windows startup

## Visual and Audio Feedback

### Tooltip Messages
Displayed at the text cursor (not at the mouse):
- ⌨ **RControl sticky (1 key)** - sticky mode active
- 🔒 **RControl LOCKED** - locked mode
- ✓ **RControl released** - Control has been released

### Sound Beeps (can be disabled)
- **Single beep** (600 Hz) - sticky mode activated
- **Double beep** (800 Hz) - locked mode activated
- **Low beep** (400 Hz) - Control released

*To disable sound, set `ENABLE_SOUND := false` on line 17*

## Configuration

### Enable/Disable Sound Beeps

If you find the sound beeps annoying, you can disable them on **line 17**:

```ahk
global ENABLE_SOUND := false  ; Set to false to disable all beeps
```

Change `true` to `false` to turn off all audio feedback.

### Adjusting Double-Tap Timing

If you have trouble detecting double-tap, adjust the value on **line 14**:

```ahk
global DOUBLE_TAP_TIME := 400  ; time in milliseconds
```

- **Tapping too fast?** → Decrease to `300` or `250`
- **Tapping too slow?** → Increase to `500` or `600`

### Adding More Keys

If you want to monitor additional keys in sticky mode, add them to the list on **line 112**:

```ahk
keys := ["a","b","c",...,"Insert","PrintScreen"]
```

## How It Works Technically

1. **Capturing Copilot key**: Script intercepts the combination `LShift + LWin + F23`
2. **Releasing original modifiers**: `LShift` and `LWin` are released
3. **Pressing RControl**: Right Control is pressed instead of the original
4. **Double-tap detection**: Compares time between presses (default 400ms)
5. **Key monitoring**: Timer checks every 10ms using `GetKeyState()` if any key was pressed
6. **Automatic release**: After detecting a key in sticky mode, Control is released

## Keyboard Shortcuts

| Combination | Action |
|------------|--------|
| `Copilot` 1× | Sticky mode (one key) |
| `Copilot` 2× | Lock/Unlock mode |
| `Ctrl+Shift+Alt+R` | Reload script |

## Supported Keys

The script monitors these keys in sticky mode:
- Letters: `a-z`
- Numbers: `0-9`
- Function keys: `F1-F12`
- Navigation: `←↑↓→`, `Home`, `End`, `PgUp`, `PgDn`
- Special: `Space`, `Enter`, `Tab`, `Backspace`, `Delete`, `Escape`, `Insert`
- Punctuation: `,`, `.`, `/`, `;`, `'`, `[`, `]`, `\`, `-`, `=`

## Troubleshooting

### Double-tap not working
- Increase `DOUBLE_TAP_TIME` value (e.g., to `500` or `600`)
- Try tapping with a more consistent rhythm

### Sticky mode doesn't release
- Check if the key you're using is in the list of monitored keys
- Add it to the `keys` list if missing

### Script doesn't work after restart
- Add script to Startup folder:  
  `Win+R` → `shell:startup` → Copy script here

## Requirements

- Windows 11 (or laptop with Copilot key)
- AutoHotkey v2.0 or newer

## License

This script is freely usable and modifiable according to your needs.

## Author
Akrotkiv
Created with the help of Ai.

---

## Technical Details

### Why doesn't Windows Sticky Keys work with remapped keys?

Windows Sticky Keys operates at the keyboard driver level and only recognizes physical hardware key presses. AutoHotkey's `Send()` commands (including `SendInput`, `SendEvent`, `SendPlay`) work at a higher level - they inject events into the Windows message queue, which normal applications see, but Sticky Keys does not.

### How does this solution work?

This script implements sticky key behavior by:
1. Using `InstallKeybdHook` to intercept keys at a low level
2. Monitoring the physical state of keys using `GetKeyState()` with the "P" (Physical) flag
3. Using a timer that checks every 10ms if any key has been pressed
4. Automatically releasing the Control modifier after detecting a key press in sticky mode

### Performance Impact

The script is very lightweight:
- Memory usage: ~2-3 MB
- CPU usage: Negligible (timer runs only in sticky mode)
- No noticeable impact on system performance
