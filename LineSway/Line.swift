import ScreenSaver

class Line: NSObject {
  let color: NSColor
  let point: NSPoint
  let paceMod: Int

  var count: Int
  var alpha: Float
  var state: LineAnimationType

  init(point: NSPoint, color: NSColor, count: Int, paceMod: Int) {
    self.point = point
    self.color = color
    self.count = count
    self.paceMod = paceMod
    self.alpha = 0
    self.state = LineAnimationType.Initial
  }

  func update() {
    count = count + 1
    switch state {
    case .Initial:
      break
    case .AlphaIncrease:
      alpha = alpha + Float(0.01) * Float(paceMod)
      if alpha > 0.5 {
        state = .AlphaIncreaseThreshold
      }
    case .AlphaIncreaseThreshold:
      alpha = alpha + Float(0.01) * Float(paceMod)
      if alpha >= 1 {
        state = .Visible
      }
    case .Visible:
      break
    case .AlphaDecrease:
      alpha = alpha - Float(0.01) * Float(paceMod)
      if alpha < 0.5 {
        state = .AlphaDecreaseThreshold
      }
    case .AlphaDecreaseThreshold:
      alpha = alpha - Float(0.01) * Float(paceMod)
      if alpha <= 0 {
        state = .Done
      }
    case .Done:
      break
    }
  }

}

enum LineAnimationType {
  case Initial
  case AlphaIncrease
  case AlphaIncreaseThreshold
  case Visible
  case AlphaDecrease
  case AlphaDecreaseThreshold
  case Done
}
