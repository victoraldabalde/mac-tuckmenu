# Tuck

A tiny macOS menu bar app that hides the menu bar icons you don't need, and brings them back with one click.

Tuck adds two things to your menu bar: an arrow and a thin divider line `|`. Every icon to the left of the line is hidden when you collapse. Click the arrow and they're back.

- No Accessibility permission needed
- Never moves other apps' icons and never changes system settings
- Quit Tuck and every icon is visible again

## Requirements

- macOS 13 Ventura or later
- Swift 5.9 or later. Installing Xcode or just the Command Line Tools gives you this:

```bash
xcode-select --install
```

## Install

Tuck is built from source on your own Mac. It takes about a minute.

```bash
git clone https://github.com/victoraldabalde/mac-toolbar.git
```

```bash
cd mac-toolbar
```

```bash
./build.sh --install
```

This builds `Tuck.app` and copies it to `~/Applications`. Open it from there:

```bash
open ~/Applications/Tuck.app
```

To build without installing, run `./build.sh` and the app ends up in `build/Tuck.app`.

## Organize your menu bar

The first time you open Tuck, it shows a short how-to. Here's the same thing step by step.

```
  hidden when collapsed          always visible
 ┌───────────────────────┐   ┌────────────────────┐
  [Dropbox] [Zoom] [Slack]  |  ›  [Wi-Fi] [Battery] [Clock]
                            ↑  ↑
                       divider  arrow
```

1. **Find Tuck's two items.** Look for a thin line `|` and an arrow `›` in your menu bar, usually just left of the system icons.
2. **Check the order.** The line must sit to the **left** of the arrow. If it doesn't, hold ⌘ and drag the line to the left of the arrow.
3. **Pick the icons to hide.** Hold ⌘, click an icon you rarely use, and drag it anywhere to the **left** of the line. Repeat for each one.
4. **Keep the important ones visible.** Hold ⌘ and drag icons you want to see all the time (Wi-Fi, Battery, a timer…) to the **right** of the line.
5. **Collapse.** Click the arrow. Everything left of the line slides out of view and the arrow flips to `‹`.
6. **Peek when you need something.** Click the arrow again to show the hidden icons, use what you need, then click to tuck them away.
7. **Make it stick (optional).** Right-click the arrow and turn on **Open at Login**, and pick an **Auto-Hide** delay so the icons tuck themselves away after you peek.

Tips:

- Changed your mind about an icon? Expand, then ⌘-drag it to the other side of the line.
- Icons of apps you open later appear wherever macOS places them, usually on the left side. ⌘-drag them where you want them.
- On a MacBook with a notch, hiding icons frees up space, so the ones you keep don't vanish behind the notch.

## Options

Right-click the arrow (or the line) for:
   - **Auto-Hide** — collapse again automatically 5, 10, 30 or 60 seconds after you expand
   - **Open at Login** — start Tuck when you log in
   - **How to Choose Hidden Icons…** — a quick reminder of the steps above
   - **Quit Tuck** — removes the arrow and line and shows every icon

Keep the line to the left of the arrow. If it ends up on the right, Tuck won't collapse (otherwise the arrow would hide itself) and will ask you to ⌘-drag it back.

## Update

```bash
cd mac-toolbar && git pull && ./build.sh --install
```

Quit Tuck and open it again to run the new version.

## Uninstall

Quit Tuck from its menu, then delete the app:

```bash
rm -rf ~/Applications/Tuck.app
```

If you turned on Open at Login, turn it off before deleting, or remove Tuck under System Settings → General → Login Items.

## How it works

The divider is a normal menu bar item. When you collapse, Tuck stretches it to be very wide, which pushes everything to its left off-screen. When you expand, it shrinks back to a thin line. Because macOS handles the layout, Tuck needs no special permissions.

## License

[MIT](LICENSE)
