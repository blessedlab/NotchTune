import AppKit

let appDelegate = AppDelegate()

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
app.delegate = appDelegate

app.run()
