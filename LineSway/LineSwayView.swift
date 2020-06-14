import ScreenSaver

enum AnimationState {
  case Initial
  case AddLines
  case RemoveLines
  case Done
}

class LineSwayView : ScreenSaverView {
  let myModuleName = "com.ranrun.LineSway"

  override var hasConfigureSheet: Bool { return false }
  override var configureSheet: NSWindow? { return nil }

  var viewBounds: NSRect
  var maxX: CGFloat
  var maxY: CGFloat
  var offsetX: CGFloat

  var initializeFlag = true
  var previewFlag = false
  var globalColor = NSColor.orange
  var globalCounter = Int32(0)
  var animationCompletions = Int32(0)

  var lineWidth = CGFloat(3)
  var lineCount = 3
  var columns = 3
  var stacksPerColumn = 3
  var charsPerCell = 3
  var charHeight = 30
  var stackOffsetX: CGFloat = 100
  var lines: [Line] = []
  var stackUpdateCount = Int32(5)
  var paceMod = 5
  var state = AnimationState.Initial

  override init?(frame: NSRect, isPreview: Bool) {
    viewBounds = frame
    maxX = frame.maxX
    maxY = frame.maxY
    offsetX = 50
    previewFlag = isPreview
    super.init(frame: frame, isPreview: isPreview)

    animationTimeInterval = (1.0 / 30.0)
  }

  required init?(coder: NSCoder) {
    viewBounds = NSMakeRect(0, 0, 100, 100)
    maxX = 100
    maxY = 100
    offsetX = 50
    super.init(coder: coder)
  }

  override func animateOneFrame() {
    NSAnimationContext.runAnimationGroup({(context) -> Void in
      animateState()
      globalCounter += 1
    }) {
      self.needsDisplay = true
    }
  }

  func animateState() {
    switch state {
    case .Initial:
      let lineRand = Int(SSRandomIntBetween(0, 10))
      if lineRand > 8 {
        lineCount = Int(SSRandomIntBetween(1, 11))
      } else {
        lineCount = Int(SSRandomIntBetween(1, 5))
      }
      if lineCount % 2 == 0 {
        lineCount = lineCount + 1
      }
      let yOffset = SSRandomFloatBetween(0, maxY - (2 * lineWidth))
      if animationCompletions % 20 == 0 {
        paceMod = Int(SSRandomIntBetween(2, 5))
      }
      globalColor = getColor()

      lines.removeAll()
      while lines.count < lineCount {
        let point = NSMakePoint(0, yOffset + (3 * CGFloat(lines.count) * lineWidth))
        let count = Int(SSRandomIntBetween(0, 30))
        let line = Line(point:point, color: globalColor, count: count, paceMod: paceMod)
        lines.append(line)
      }

      state = .AddLines
    case .AddLines:
      if lines.allSatisfy({$0.state == .Visible}) {
        state = .RemoveLines
      } else {
        let containsAlphaIncrease = lines.contains {
          let line = ($0 as Line)
          return line.state == .AlphaIncrease
        }
        if !containsAlphaIncrease {
          if let line = lines.filter({$0.state == .Initial}).randomElement() {
            line.state = .AlphaIncrease
          }
        }
      }
    case .RemoveLines:
      if lines.allSatisfy({$0.state == .Done}) {
        state = .Done
      } else {
        let containsAlphaDecrease = lines.contains {
          let line = ($0 as Line)
          return line.state == .AlphaDecrease
        }
        if !containsAlphaDecrease {
          if let line = lines.filter({ $0.state == .Visible}).randomElement() {
            line.state = .AlphaDecrease
          }
        }
      }
    case .Done:
      if globalCounter % 20 == 0 {
        animationCompletions += 1
        state = .Initial
      }
    }

    for line in lines {
      line.update()
    }
  }

  override func draw(_ rect: NSRect) {
    super.draw(rect)

    if initializeFlag {
      viewBounds = rect
      maxX = rect.maxX
      maxY = rect.maxY
      initializeFlag = false
    }

    NSColor.black.set()
    NSBezierPath.fill(rect)

    let ctx: CGContext = currentContext()

    for line in lines {
      ctx.saveGState()

      line.color.withAlphaComponent(CGFloat(line.alpha)).set()
      let bPath = NSBezierPath.init()
      bPath.move(to: NSPoint.init(x:0, y:line.point.y))
      bPath.line(to: NSPoint.init(x:maxX, y:line.point.y))
      bPath.lineWidth = lineWidth
      bPath.stroke()

      ctx.restoreGState()
    }

  }

  func getColor() -> NSColor {
    switch SSRandomIntBetween(0, 9) {
    case 0:
      return NSColor.systemRed
    case 1:
      return NSColor.systemGreen
    case 2:
      return NSColor.systemBlue
    case 3:
      return NSColor.systemOrange
    case 4:
      return NSColor.systemYellow
    case 5:
      return NSColor.systemPink
    case 6:
      return NSColor.systemPurple
    case 7:
      return NSColor.systemGray
    case 8:
      return NSColor.systemTeal
//    case 9:
//      return NSColor.systemIndigo
    default:
      return NSColor.white
    }
  }

  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    initializeFlag = true;
  }

  override func startAnimation() {
    super.startAnimation()
  }

  override func stopAnimation() {
    super.stopAnimation()
  }

  func currentContext() -> CGContext {
    return NSGraphicsContext.current!.cgContext
  }

}
