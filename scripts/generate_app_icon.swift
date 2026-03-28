import AppKit
import Foundation

let fileManager = FileManager.default
let root = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let resourcesDirectory = root.appendingPathComponent("Resources", isDirectory: true)
let iconsetDirectory = resourcesDirectory.appendingPathComponent("AppIcon.iconset", isDirectory: true)
let iconFile = resourcesDirectory.appendingPathComponent("Cclips.icns")

try? fileManager.removeItem(at: iconsetDirectory)
try? fileManager.removeItem(at: iconFile)
try fileManager.createDirectory(at: iconsetDirectory, withIntermediateDirectories: true)

let iconSpecs: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

func makeImage(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let canvas = NSRect(x: 0, y: 0, width: size, height: size)
    let corner = size * 0.23

    let outer = NSBezierPath(roundedRect: canvas, xRadius: corner, yRadius: corner)
    let background = NSGradient(
        colors: [
            NSColor(calibratedRed: 0.96, green: 0.66, blue: 0.34, alpha: 1),
            NSColor(calibratedRed: 0.93, green: 0.35, blue: 0.22, alpha: 1),
        ]
    )!
    background.draw(in: outer, angle: 270)

    NSGraphicsContext.current?.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowBlurRadius = size * 0.05
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.02)
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
    shadow.set()

    let boardRect = NSRect(
        x: size * 0.24,
        y: size * 0.20,
        width: size * 0.52,
        height: size * 0.60
    )
    let board = NSBezierPath(roundedRect: boardRect, xRadius: size * 0.08, yRadius: size * 0.08)
    NSColor.white.withAlphaComponent(0.96).setFill()
    board.fill()
    NSGraphicsContext.current?.restoreGraphicsState()

    let clipRect = NSRect(
        x: size * 0.37,
        y: size * 0.72,
        width: size * 0.26,
        height: size * 0.11
    )
    let clip = NSBezierPath(roundedRect: clipRect, xRadius: size * 0.045, yRadius: size * 0.045)
    NSColor(calibratedRed: 0.17, green: 0.15, blue: 0.19, alpha: 0.92).setFill()
    clip.fill()

    let innerPaperRect = NSRect(
        x: size * 0.31,
        y: size * 0.26,
        width: size * 0.38,
        height: size * 0.42
    )
    let paper = NSBezierPath(roundedRect: innerPaperRect, xRadius: size * 0.05, yRadius: size * 0.05)
    NSColor(calibratedRed: 1.0, green: 0.97, blue: 0.91, alpha: 1).setFill()
    paper.fill()

    let lineColor = NSColor(calibratedRed: 0.93, green: 0.43, blue: 0.26, alpha: 0.95)
    lineColor.setStroke()

    for index in 0..<4 {
        let y = size * (0.58 - CGFloat(index) * 0.09)
        let path = NSBezierPath()
        path.lineWidth = max(2, size * 0.028)
        path.lineCapStyle = .round
        path.move(to: NSPoint(x: size * 0.37, y: y))
        path.line(to: NSPoint(x: size * (index == 0 ? 0.60 : 0.63), y: y))
        path.stroke()
    }

    let sparkleColor = NSColor.white.withAlphaComponent(0.9)
    sparkleColor.setFill()
    let sparkle = NSBezierPath()
    sparkle.move(to: NSPoint(x: size * 0.77, y: size * 0.70))
    sparkle.line(to: NSPoint(x: size * 0.81, y: size * 0.79))
    sparkle.line(to: NSPoint(x: size * 0.90, y: size * 0.83))
    sparkle.line(to: NSPoint(x: size * 0.81, y: size * 0.87))
    sparkle.line(to: NSPoint(x: size * 0.77, y: size * 0.96))
    sparkle.line(to: NSPoint(x: size * 0.73, y: size * 0.87))
    sparkle.line(to: NSPoint(x: size * 0.64, y: size * 0.83))
    sparkle.line(to: NSPoint(x: size * 0.73, y: size * 0.79))
    sparkle.close()
    sparkle.fill()

    image.unlockFocus()
    return image
}

for (filename, size) in iconSpecs {
    let image = makeImage(size: size)
    guard let tiff = image.tiffRepresentation,
          let representation = NSBitmapImageRep(data: tiff),
          let png = representation.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "IconGeneration", code: 1)
    }

    let fileURL = iconsetDirectory.appendingPathComponent(filename)
    try png.write(to: fileURL)
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetDirectory.path, "-o", iconFile.path]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    throw NSError(domain: "IconGeneration", code: Int(process.terminationStatus))
}

print("Generated \(iconFile.path)")
