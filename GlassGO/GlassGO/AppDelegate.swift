import Cocoa
import SwiftUI
import HotKey

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var popoverPanel: NSPanel?
    var escKeyMonitor: Any?
    let popoverPanelOriginKey = "popoverPanelOrigin"

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "circle", accessibilityDescription: "GlassGo")
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
        statusItem?.menu = makeMenu()
        HotKeyManager.shared.registerSavedOrDefaultHotKey(target: self, action: #selector(showPopover))
        NotificationCenter.default.addObserver(self, selector: #selector(hotKeyChanged), name: HotKeyManager.hotKeyChangedNotification, object: nil)
    }

    @objc func statusBarButtonClicked() {
        statusItem?.menu = makeMenu()
        statusItem?.button?.performClick(nil)
    }

    func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Change Hotkey (" + HotKeyManager.shared.currentHotKeyDescription() + ")", action: #selector(changeHotkey), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Reset Popover Position", action: #selector(resetPopoverPosition), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        return menu
    }

    @objc func changeHotkey() {
        let vc = HotKeyPopoverViewController()
        let popover = NSPopover()
        popover.contentViewController = vc
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 260, height: 140)
        if let button = statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    @objc func showPopover() {
        if let panel = popoverPanel, panel.isVisible {
            panel.close()
            popoverPanel = nil
            if let monitor = escKeyMonitor {
                NSEvent.removeMonitor(monitor)
                escKeyMonitor = nil
            }
            return
        }
        let contentView: AnyView
        if #available(macOS 15.0, *) {
            contentView = AnyView(MiniGlassPopover())
        } else {
            contentView = AnyView(EmptyView())
        }
        let hosting = NSHostingController(rootView: contentView)
        let panel = NSPanel(contentViewController: hosting)
        panel.styleMask = [.titled, .nonactivatingPanel, .fullSizeContentView]
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.hasShadow = false
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        let width: CGFloat = 300
        let height: CGFloat = 300
        let size = NSSize(width: width, height: height)
        if let originString = UserDefaults.standard.string(forKey: popoverPanelOriginKey) {
            let origin = NSPointFromString(originString)
            panel.setFrame(NSRect(origin: origin, size: size), display: true)
        } else if let screen = NSScreen.main {
            let x: CGFloat = screen.frame.midX - width/2
            let y: CGFloat = screen.frame.midY - height/2
            let origin = NSPoint(x: x, y: y)
            panel.setFrame(NSRect(origin: origin, size: size), display: true)
        }
        hosting.view.frame = NSRect(origin: .zero, size: size)
        hosting.view.autoresizingMask = [.width, .height]
        panel.delegate = self
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        popoverPanel = panel
        escKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC
                self?.popoverPanel?.close()
                self?.popoverPanel = nil
                if let monitor = self?.escKeyMonitor {
                    NSEvent.removeMonitor(monitor)
                    self?.escKeyMonitor = nil
                }
                return nil
            }
            return event
        }
    }

    @objc func hotKeyChanged() {
        statusItem?.menu = makeMenu()
    }

    @objc func resetPopoverPosition() {
        UserDefaults.standard.removeObject(forKey: popoverPanelOriginKey)
    }

    // NSWindowDelegate
    func windowDidMove(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == popoverPanel {
            let originString = NSStringFromPoint(window.frame.origin)
            UserDefaults.standard.set(originString, forKey: popoverPanelOriginKey)
        }
    }
} 