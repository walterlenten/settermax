import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var videoWallpaperWindow: NSWindow!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create main window
        window = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 300, height: 200),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered,
                          defer: false)
        window.title = "Video Wallpaper Setter"
        window.makeKeyAndOrderFront(nil)

        // Create button
        let button = NSButton(frame: NSRect(x: 50, y: 50, width: 200, height: 50))
        button.title = "Set Video Wallpaper"
        button.bezelStyle = .rounded
        button.target = self
        button.action = #selector(setVideoWallpaper)
        window.contentView?.addSubview(button)
    }

    @objc func setVideoWallpaper() {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["mp4"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true

        openPanel.beginSheetModal(for: window) { response in
            if response == .OK, let url = openPanel.url {
                self.createVideoWallpaper(with: url)
            }
        }
    }

    func createVideoWallpaper(with url: URL) {
        // Create a window that covers the entire screen
        let screen = NSScreen.main!
        videoWallpaperWindow = NSWindow(contentRect: screen.frame,
                                        styleMask: [.borderless],
                                        backing: .buffered,
                                        defer: false)
        videoWallpaperWindow.level = .init(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) - 1)
        videoWallpaperWindow.backgroundColor = .clear

        // Set up video player
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = screen.frame
        playerLayer?.videoGravity = .resizeAspectFill

        // Add player layer to window
        if let playerLayer = playerLayer {
            videoWallpaperWindow.contentView?.layer?.addSublayer(playerLayer)
            videoWallpaperWindow.contentView?.wantsLayer = true
        }

        // Set up looping
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
            self.player?.seek(to: CMTime.zero)
            self.player?.play()
        }

        // Show video wallpaper and start playing
        videoWallpaperWindow.makeKeyAndOrderFront(nil)
        player?.play()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Clean up
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
    }
}