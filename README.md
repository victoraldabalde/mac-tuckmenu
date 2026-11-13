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

## Usage

1. **Choose what to hide.** Hold ⌘ and drag any menu bar icon to the left of the thin line to hide it. Icons to the right of the line always stay visible.
2. **Collapse or expand.** Click the arrow.
3. **Options.** Right-click the arrow (or the line) for:
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
