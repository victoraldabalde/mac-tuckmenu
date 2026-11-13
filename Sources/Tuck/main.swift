import AppKit
import ServiceManagement

// Tuck: collapse the menu bar icons you don't need.
//
// How it works: Tuck adds two items to the menu bar, an arrow and a thin divider.
// Every icon to the LEFT of the divider gets hidden when you collapse, by stretching
// the divider so wide that it pushes those icons off-screen. You choose what is
// hidden by ⌘-dragging icons to either side of the divider.
//
// Tuck never moves other apps' icons itself and never changes system settings.
// When Tuck quits, the divider disappears and every icon is visible again.

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private enum Key {
        static let collapsed = "collapsed"
        static let autoCollapseSeconds = "autoCollapseSeconds"
        static let hasShownWelcome = "hasShownWelcome"
    }

    private let defaults = UserDefaults.standard
    private var toggleItem: NSStatusItem!
    private var dividerItem: NSStatusItem!
    private var autoCollapseTimer: Timer?

    private let dividerWidth: CGFloat = 14
    private let collapsedWidth: CGFloat = 10_000

    private var isCollapsed = false
    private var autoCollapseSeconds: Int {
        get { defaults.integer(forKey: Key.autoCollapseSeconds) }
        set { defaults.set(newValue, forKey: Key.autoCollapseSeconds) }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // New status items appear to the left of existing ones, so the arrow is
        // created first (it ends up on the right) and the divider second.
        toggleItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        toggleItem.autosaveName = "tuck.toggle"
        toggleItem.behavior = []  // can't be ⌘-dragged off the bar by accident
        if let button = toggleItem.button {
            button.target = self
            button.action = #selector(toggleClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.toolTip = "Click to show or hide icons. Right-click for options."
        }

        dividerItem = NSStatusBar.system.statusItem(withLength: dividerWidth)
        dividerItem.autosaveName = "tuck.divider"
        dividerItem.behavior = []
        if let button = dividerItem.button {
            button.image = Self.dividerImage()
            button.target = self
            button.action = #selector(dividerClicked(_:))
            button.sendAction(on: [.rightMouseUp])
            button.toolTip = "Icons to the left of this line are hidden when collapsed. ⌘-drag icons across it."
        }

        render()

        if !defaults.bool(forKey: Key.hasShownWelcome) {
            defaults.set(true, forKey: Key.hasShownWelcome)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.showHowTo() }
        } else if defaults.bool(forKey: Key.collapsed) {
            // Give the menu bar a moment to place the items before measuring them.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.setCollapsed(true) }
        }
    }

    // MARK: Collapse / expand

    private func setCollapsed(_ collapsed: Bool) {
        autoCollapseTimer?.invalidate()
        autoCollapseTimer = nil

        if collapsed && !dividerIsLeftOfToggle() {
            // Collapsing now would hide the arrow too, leaving no way back.
            isCollapsed = false
            render()
            showMisplacedDividerAlert()
            return
        }

        isCollapsed = collapsed
        defaults.set(collapsed, forKey: Key.collapsed)
        render()

        if !collapsed && autoCollapseSeconds > 0 {
            autoCollapseTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(autoCollapseSeconds), repeats: false) { [weak self] _ in
                MainActor.assumeIsolated { self?.setCollapsed(true) }
            }
        }
    }

    private func render() {
        dividerItem.length = isCollapsed ? collapsedWidth : dividerWidth
        dividerItem.button?.image = isCollapsed ? nil : Self.dividerImage()
        let symbol = isCollapsed ? "chevron.left" : "chevron.right"
        let label = isCollapsed ? "Show hidden icons" : "Hide icons"
        toggleItem.button?.image = NSImage(systemSymbolName: symbol, accessibilityDescription: label)
    }

    private func dividerIsLeftOfToggle() -> Bool {
        guard let divider = dividerItem.button?.window?.frame,
              let toggle = toggleItem.button?.window?.frame else { return true }
        return divider.minX < toggle.minX
    }

    // MARK: Clicks

    @objc private func toggleClicked(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showMenu(from: toggleItem)
        } else {
            setCollapsed(!isCollapsed)
        }
    }

    @objc private func dividerClicked(_ sender: NSStatusBarButton) {
        if !isCollapsed { showMenu(from: dividerItem) }
    }

    // MARK: Menu

    private func showMenu(from item: NSStatusItem) {
        let menu = NSMenu()

        menu.addItem(withTitle: isCollapsed ? "Show Hidden Icons" : "Hide Icons",
                     action: #selector(menuToggle), keyEquivalent: "").target = self
        menu.addItem(.separator())

        let autoItem = NSMenuItem(title: "Auto-Hide", action: nil, keyEquivalent: "")
        let autoMenu = NSMenu()
        for (title, seconds) in [("Off", 0), ("After 5 seconds", 5), ("After 10 seconds", 10), ("After 30 seconds", 30), ("After 1 minute", 60)] {
            let entry = NSMenuItem(title: title, action: #selector(setAutoCollapse(_:)), keyEquivalent: "")
            entry.target = self
            entry.tag = seconds
            entry.state = seconds == autoCollapseSeconds ? .on : .off
            autoMenu.addItem(entry)
        }
        autoItem.submenu = autoMenu
        menu.addItem(autoItem)

        let login = NSMenuItem(title: "Open at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        login.target = self
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(login)

        menu.addItem(.separator())
        menu.addItem(withTitle: "How to Choose Hidden Icons…", action: #selector(showHowTo), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Tuck (shows all icons)", action: #selector(quit), keyEquivalent: "q").target = self

        item.menu = menu
        item.button?.performClick(nil)
        item.menu = nil  // so left-click keeps toggling instead of opening the menu
    }

    @objc private func menuToggle() { setCollapsed(!isCollapsed) }

    @objc private func setAutoCollapse(_ sender: NSMenuItem) {
        autoCollapseSeconds = sender.tag
        if !isCollapsed { setCollapsed(false) }  // restart the timer with the new value
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Couldn't change Open at Login"
            alert.informativeText = "\(error.localizedDescription)\n\nMove Tuck.app to your Applications folder and try again."
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
    }

    @objc private func showHowTo() {
        if isCollapsed { setCollapsed(false) }
        let alert = NSAlert()
        alert.messageText = "Choose which icons to hide"
        alert.informativeText = """
        Tuck added an arrow and a thin line | to your menu bar.

        • Hold ⌘ and drag any icon to the LEFT of the line to hide it.
        • Keep icons to the RIGHT of the line to always see them.
        • Click the arrow to hide or show the icons on the left.

        Keep the line to the left of the arrow. Quit Tuck any time and every icon comes back.
        """
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    private func showMisplacedDividerAlert() {
        let alert = NSAlert()
        alert.messageText = "Move the line to the left of the arrow"
        alert.informativeText = "Hold ⌘ and drag the thin line | so it sits to the left of Tuck's arrow, then try again. Otherwise the arrow itself would be hidden."
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    @objc private func quit() { NSApp.terminate(nil) }

    func applicationWillTerminate(_ notification: Notification) {
        // Status items vanish with the app anyway; this just keeps the saved state sane.
        dividerItem?.length = dividerWidth
    }

    // MARK: Drawing

    private static func dividerImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 2, height: 16), flipped: false) { rect in
            NSColor.black.setFill()
            NSBezierPath(roundedRect: rect, xRadius: 1, yRadius: 1).fill()
            return true
        }
        image.isTemplate = true  // follows light/dark menu bar automatically
        image.accessibilityDescription = "Tuck divider"
        return image
    }
}

let app = NSApplication.shared
let delegate = MainActor.assumeIsolated { AppDelegate() }
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
