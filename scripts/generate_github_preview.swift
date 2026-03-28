import AppKit
import Foundation

let fileManager = FileManager.default
let root = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let resourcesDirectory = root.appendingPathComponent("Resources", isDirectory: true)
let outputURL = resourcesDirectory.appendingPathComponent("GitHubPreview.png")

let size = NSSize(width: 1280, height: 640)
let image = NSImage(size: size)
image.lockFocus()

let canvas = NSRect(origin: .zero, size: size)
let background = NSGradient(
    colors: [
        NSColor(calibratedRed: 0.98, green: 0.95, blue: 0.90, alpha: 1),
        NSColor(calibratedRed: 0.95, green: 0.88, blue: 0.80, alpha: 1),
    ]
)!
background.draw(in: canvas, angle: 315)

let glowRect = NSRect(x: 780, y: 320, width: 380, height: 220)
NSColor(calibratedRed: 1.0, green: 0.56, blue: 0.32, alpha: 0.18).setFill()
NSBezierPath(ovalIn: glowRect).fill()

let windowRect = NSRect(x: 90, y: 110, width: 720, height: 420)
let windowPath = NSBezierPath(roundedRect: windowRect, xRadius: 28, yRadius: 28)
NSColor.white.withAlphaComponent(0.96).setFill()
windowPath.fill()

let headerRect = NSRect(x: windowRect.minX, y: windowRect.maxY - 82, width: windowRect.width, height: 82)
let headerPath = NSBezierPath(roundedRect: headerRect, xRadius: 28, yRadius: 28)
NSColor(calibratedRed: 0.98, green: 0.97, blue: 0.95, alpha: 1).setFill()
headerPath.fill()

let trafficColors: [NSColor] = [
    NSColor(calibratedRed: 0.99, green: 0.36, blue: 0.31, alpha: 1),
    NSColor(calibratedRed: 0.98, green: 0.76, blue: 0.20, alpha: 1),
    NSColor(calibratedRed: 0.19, green: 0.79, blue: 0.35, alpha: 1),
]

for (index, color) in trafficColors.enumerated() {
    color.setFill()
    NSBezierPath(ovalIn: NSRect(x: 120 + CGFloat(index) * 26, y: 410, width: 14, height: 14)).fill()
}

let searchRect = NSRect(x: 470, y: 395, width: 250, height: 34)
NSColor(calibratedRed: 0.93, green: 0.92, blue: 0.90, alpha: 1).setFill()
NSBezierPath(roundedRect: searchRect, xRadius: 16, yRadius: 16).fill()

let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .left

func drawText(_ text: String, in rect: NSRect, size: CGFloat, weight: NSFont.Weight, color: NSColor) {
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: paragraph,
    ]
    text.draw(in: rect, withAttributes: attributes)
}

drawText("Cclips", in: NSRect(x: 160, y: 392, width: 200, height: 34), size: 17, weight: .bold, color: .black)
drawText("Search clipboard history", in: NSRect(x: 488, y: 402, width: 190, height: 18), size: 13, weight: .regular, color: .gray)

let sidebarRect = NSRect(x: 110, y: 130, width: 180, height: 250)
NSColor(calibratedRed: 0.98, green: 0.97, blue: 0.95, alpha: 1).setFill()
NSBezierPath(roundedRect: sidebarRect, xRadius: 20, yRadius: 20).fill()

let listRect = NSRect(x: 320, y: 130, width: 210, height: 250)
NSColor(calibratedRed: 0.99, green: 0.99, blue: 0.98, alpha: 1).setFill()
NSBezierPath(roundedRect: listRect, xRadius: 20, yRadius: 20).fill()

let detailRect = NSRect(x: 560, y: 130, width: 220, height: 250)
NSColor(calibratedRed: 1.0, green: 0.99, blue: 0.97, alpha: 1).setFill()
NSBezierPath(roundedRect: detailRect, xRadius: 20, yRadius: 20).fill()

drawText("All Clips", in: NSRect(x: 950, y: 470, width: 220, height: 36), size: 34, weight: .bold, color: NSColor(calibratedRed: 0.17, green: 0.15, blue: 0.19, alpha: 1))
drawText("A native macOS clipboard manager with history, pinning, paste stack, and menu bar access.", in: NSRect(x: 850, y: 385, width: 360, height: 90), size: 19, weight: .medium, color: NSColor(calibratedRed: 0.35, green: 0.31, blue: 0.29, alpha: 1))

let badgeColor = NSColor(calibratedRed: 0.93, green: 0.42, blue: 0.25, alpha: 1)
for (index, label) in ["Clipboard History", "Search + Pinning", "Ready for GitHub Releases"].enumerated() {
    let badgeRect = NSRect(x: 850, y: 300 - CGFloat(index) * 60, width: 300, height: 40)
    badgeColor.withAlphaComponent(index == 2 ? 0.22 : 0.16).setFill()
    NSBezierPath(roundedRect: badgeRect, xRadius: 20, yRadius: 20).fill()
    drawText(label, in: NSRect(x: badgeRect.minX + 18, y: badgeRect.minY + 11, width: badgeRect.width - 36, height: 18), size: 15, weight: .semibold, color: NSColor(calibratedRed: 0.25, green: 0.18, blue: 0.16, alpha: 1))
}

drawText("Pinned", in: NSRect(x: 140, y: 328, width: 80, height: 20), size: 14, weight: .semibold, color: .black)
drawText("Links", in: NSRect(x: 140, y: 285, width: 80, height: 20), size: 14, weight: .regular, color: .darkGray)
drawText("Images", in: NSRect(x: 140, y: 242, width: 80, height: 20), size: 14, weight: .regular, color: .darkGray)

for index in 0..<4 {
    let itemRect = NSRect(x: 345, y: 322 - CGFloat(index) * 48, width: 160, height: 34)
    let fillColor = index == 0
        ? NSColor(calibratedRed: 1.0, green: 0.86, blue: 0.78, alpha: 1)
        : NSColor(calibratedRed: 0.96, green: 0.95, blue: 0.93, alpha: 1)
    fillColor.setFill()
    NSBezierPath(roundedRect: itemRect, xRadius: 14, yRadius: 14).fill()
}

drawText("Launch Notes", in: NSRect(x: 582, y: 326, width: 160, height: 22), size: 18, weight: .bold, color: .black)
drawText("Copy, pin, and re-use clips without leaving the keyboard.", in: NSRect(x: 582, y: 270, width: 170, height: 70), size: 15, weight: .regular, color: .darkGray)

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    throw NSError(domain: "PreviewGeneration", code: 1)
}

try png.write(to: outputURL)
print("Generated \(outputURL.path)")
