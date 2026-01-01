import SwiftUI

extension Notification.Name {
    static let trayAuthenticationStateChanged = Notification.Name("TrayAuthenticationStateChanged")
}
import AppKit

/// Manager for macOS system tray functionality
@MainActor
public final class JenkinsTrayManager: NSObject, ObservableObject {
    public static let shared = JenkinsTrayManager()

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private weak var appCoordinator: AppCoordinator?

    @Published var isAuthenticated = false {
        didSet {
            updateStatusItemIcon()
            // Notify about authentication state change
            NotificationCenter.default.post(
                name: .trayAuthenticationStateChanged,
                object: nil,
                userInfo: ["isAuthenticated": isAuthenticated]
            )
        }
    }
    @Published var showPopover = false

    private override init() {
        super.init()
        setupStatusItem()
        setupPopover()
    }

    func setAppCoordinator(_ coordinator: AppCoordinator) {
        self.appCoordinator = coordinator
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        updateStatusItemIcon()
    }

    private func updateStatusItemIcon() {
        guard let button = statusItem?.button else { return }

        // Set tray icon based on authentication status
        let symbolName = isAuthenticated ? "hammer.circle.fill" : "hammer.circle"
        if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Jenkins Tray") {
            button.image = image
        }

        button.action = #selector(togglePopover)
        button.target = self
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 400)
        popover?.behavior = .transient
        // Note: ContentViewController will be set when showing the popover
        // to allow injecting the AppCoordinator from the environment
    }

    @objc private func togglePopover() {
        guard let popover = popover, let button = statusItem?.button, let appCoordinator = appCoordinator else { return }

        if popover.isShown {
            popover.performClose(nil)
            showPopover = false
        } else {
            let contentView = TrayPopoverView()
                .environmentObject(appCoordinator)

            popover.contentViewController = NSHostingController(rootView: contentView)

            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            showPopover = true
        }
    }


    public func showPopoverWithAlert() {
        guard let popover = popover, let button = statusItem?.button, let appCoordinator = appCoordinator else { return }

        // Close if already shown
        if popover.isShown {
            popover.performClose(nil)
        }

        // Show popover
        let contentView = TrayPopoverView()
            .environmentObject(appCoordinator)

        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        showPopover = true

        #if DEBUG
        print("[JenkinsTrayManager] Popover shown due to build status change")
        #endif
    }

    public func showMainWindow() {
        // Show main window
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }

        #if DEBUG
        print("[JenkinsTrayManager] Main window shown")
        #endif
    }

    func hidePopover() {
        popover?.performClose(nil)
        showPopover = false
    }

    deinit {
        // Note: NSStatusItem cleanup is handled by NSStatusBar automatically
        // when the application terminates
    }
}
