import AppKit

let size = CGSize(width: 1024, height: 1024)
let rect = CGRect(origin: .zero, size: size)

let image = NSImage(size: size)
image.lockFocus()

let background = NSColor(calibratedRed: 0.72, green: 0.84, blue: 0.95, alpha: 1.0)
background.setFill()
NSBezierPath(rect: rect).fill()

let plateRect = CGRect(x: 250, y: 258, width: 524, height: 32)
let plate = NSBezierPath(roundedRect: plateRect, xRadius: 16, yRadius: 16)
NSColor(calibratedRed: 0.89, green: 0.94, blue: 0.98, alpha: 0.9).setFill()
plate.fill()

let cakeBodyRect = CGRect(x: 302, y: 312, width: 420, height: 248)
let cakeBody = NSBezierPath(roundedRect: cakeBodyRect, xRadius: 54, yRadius: 54)
NSColor(calibratedRed: 0.98, green: 0.96, blue: 0.91, alpha: 1.0).setFill()
cakeBody.fill()

let cakeTopRect = CGRect(x: 286, y: 506, width: 452, height: 110)
let cakeTop = NSBezierPath(roundedRect: cakeTopRect, xRadius: 56, yRadius: 56)
NSColor(calibratedRed: 0.99, green: 0.985, blue: 0.95, alpha: 1.0).setFill()
cakeTop.fill()

let icingColor = NSColor(calibratedRed: 0.96, green: 0.98, blue: 1.0, alpha: 0.95)
icingColor.setFill()
let icing = NSBezierPath()
icing.move(to: CGPoint(x: 318, y: 548))
icing.curve(to: CGPoint(x: 370, y: 520), controlPoint1: CGPoint(x: 330, y: 520), controlPoint2: CGPoint(x: 352, y: 514))
icing.curve(to: CGPoint(x: 432, y: 552), controlPoint1: CGPoint(x: 388, y: 528), controlPoint2: CGPoint(x: 410, y: 560))
icing.curve(to: CGPoint(x: 498, y: 520), controlPoint1: CGPoint(x: 452, y: 544), controlPoint2: CGPoint(x: 476, y: 510))
icing.curve(to: CGPoint(x: 568, y: 552), controlPoint1: CGPoint(x: 520, y: 530), controlPoint2: CGPoint(x: 546, y: 562))
icing.curve(to: CGPoint(x: 640, y: 518), controlPoint1: CGPoint(x: 592, y: 540), controlPoint2: CGPoint(x: 616, y: 506))
icing.curve(to: CGPoint(x: 706, y: 548), controlPoint1: CGPoint(x: 664, y: 530), controlPoint2: CGPoint(x: 686, y: 552))
icing.line(to: CGPoint(x: 706, y: 604))
icing.line(to: CGPoint(x: 318, y: 604))
icing.close()
icing.fill()

let stripeColor = NSColor(calibratedRed: 0.85, green: 0.92, blue: 0.98, alpha: 0.9)
stripeColor.setStroke()
for x in stride(from: 360, through: 664, by: 76) {
    let stripe = NSBezierPath()
    stripe.lineWidth = 14
    stripe.move(to: CGPoint(x: x, y: 348))
    stripe.line(to: CGPoint(x: x, y: 514))
    stripe.stroke()
}

let candleRect = CGRect(x: 494, y: 598, width: 36, height: 150)
let candle = NSBezierPath(roundedRect: candleRect, xRadius: 18, yRadius: 18)
NSColor(calibratedRed: 0.24, green: 0.52, blue: 0.84, alpha: 1.0).setFill()
candle.fill()

let wick = NSBezierPath()
wick.lineWidth = 6
NSColor(calibratedRed: 0.35, green: 0.29, blue: 0.2, alpha: 1.0).setStroke()
wick.move(to: CGPoint(x: 512, y: 748))
wick.curve(to: CGPoint(x: 516, y: 770), controlPoint1: CGPoint(x: 514, y: 756), controlPoint2: CGPoint(x: 520, y: 764))
wick.stroke()

let flame = NSBezierPath()
flame.move(to: CGPoint(x: 515, y: 840))
flame.curve(to: CGPoint(x: 545, y: 790), controlPoint1: CGPoint(x: 548, y: 824), controlPoint2: CGPoint(x: 552, y: 804))
flame.curve(to: CGPoint(x: 515, y: 758), controlPoint1: CGPoint(x: 538, y: 772), controlPoint2: CGPoint(x: 524, y: 760))
flame.curve(to: CGPoint(x: 485, y: 790), controlPoint1: CGPoint(x: 508, y: 760), controlPoint2: CGPoint(x: 492, y: 772))
flame.curve(to: CGPoint(x: 515, y: 840), controlPoint1: CGPoint(x: 478, y: 804), controlPoint2: CGPoint(x: 482, y: 824))
NSColor(calibratedRed: 1.0, green: 0.74, blue: 0.38, alpha: 1.0).setFill()
flame.fill()

let innerFlame = NSBezierPath()
innerFlame.move(to: CGPoint(x: 515, y: 822))
innerFlame.curve(to: CGPoint(x: 532, y: 792), controlPoint1: CGPoint(x: 534, y: 812), controlPoint2: CGPoint(x: 536, y: 800))
innerFlame.curve(to: CGPoint(x: 515, y: 774), controlPoint1: CGPoint(x: 529, y: 784), controlPoint2: CGPoint(x: 520, y: 776))
innerFlame.curve(to: CGPoint(x: 498, y: 792), controlPoint1: CGPoint(x: 510, y: 776), controlPoint2: CGPoint(x: 501, y: 784))
innerFlame.curve(to: CGPoint(x: 515, y: 822), controlPoint1: CGPoint(x: 494, y: 800), controlPoint2: CGPoint(x: 496, y: 812))
NSColor(calibratedRed: 1.0, green: 0.95, blue: 0.75, alpha: 1.0).setFill()
innerFlame.fill()

image.unlockFocus()

guard
    let tiffData = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiffData),
    let pngData = bitmap.representation(using: .png, properties: [:])
else {
    fatalError("Failed to encode icon image")
}

let outputURL = URL(fileURLWithPath: "/Users/kenchen/Projects/birthdays/Birthdays/Birthdays/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
try pngData.write(to: outputURL)
