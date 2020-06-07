import Cocoa
import ScreenSaver

@NSApplicationMain
class AppDelegate: NSObject {

  @IBOutlet weak var window: NSWindow!

  var view: ScreenSaverView!

  @IBAction func showPreferences(_ sender: NSObject!) {
    window.beginSheet(view.configureSheet!, completionHandler: nil)
  }

  func setupAndStartAnimation() {
    let saverName = "LineSway"

    guard let saverBundle = loadSaverBundle(saverName) else {
      NSLog("Can't find or load bundle for saver named \(saverName).")
      return
    }
    let saverClass = saverBundle.principalClass! as! ScreenSaverView.Type

    view = saverClass.init(frame: window.contentView!.frame, isPreview: false)
    view.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]

    window.title = view.className
    window.contentView!.autoresizesSubviews = true
    window.contentView!.addSubview(view)

    view.startAnimation()

    Timer.scheduledTimer(withTimeInterval: view.animationTimeInterval, repeats: true, block: { timer in
      self.view!.animateOneFrame()
    })

  }

  private func loadSaverBundle(_ name: String) -> Bundle? {
    let myBundle = Bundle(for: AppDelegate.self)
    let saverBundleURL = myBundle.bundleURL.deletingLastPathComponent().appendingPathComponent("\(name).saver", isDirectory: true)
    let saverBundle = Bundle(url: saverBundleURL)
    saverBundle?.load()
    return saverBundle
  }

  func restartAnimation() {
    stopAnimation()
    view.startAnimation()
  }

  func stopAnimation() {
    if view.isAnimating {
      view.stopAnimation()
    }
  }

}

extension AppDelegate: NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    setupAndStartAnimation()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    stopAnimation()
  }
}


extension AppDelegate: NSWindowDelegate {
  override func awakeFromNib() {
    super.awakeFromNib()
    window.setFrame(NSMakeRect(0, 0, 1280, 720), display: true)
  }

  func windowWillClose(_ notification: Notification) {
    NSApplication.shared.terminate(window)
  }

  func windowDidResize(_ notification: Notification) {}

  func windowDidEndSheet(_ notification: Notification) {
    restartAnimation()
  }
}
