import Foundation
import SwiftGodot

@Godot
public class Wall: Node2D {
    public struct Rect {
        var width: Int
        var height: Int
        var x: Int = 0
        var y: Int = 0
        var color: Color
        var originalColor: Color
    }

    var packedRects: [Rect] = []
    
    let availableColors: [Color] = [
        Color(r: 1, g: 0, b: 0, a: 1),  // Red
        Color(r: 0, g: 1, b: 0, a: 1),  // Green
        Color(r: 0, g: 0, b: 1, a: 1),  // Blue
        Color(r: 1, g: 1, b: 0, a: 1)   // Yellow
    ]

    let minWidth = 50
    let minHeight = 50
    let maxWidth = 100
    let maxHeight = 100

    public required init() {
        super.init()
    }

    public required init(nativeHandle: UnsafeRawPointer) {
        super.init(nativeHandle: nativeHandle)
    }

    public override func _ready() {
        packRectangles()
        queueRedraw()
    }

    public func packRectangles() {
        let containerWidth = 400
        let containerHeight = 300

        var currentX = 0
        var currentY = 0

        while currentY + minHeight <= containerHeight {
            while currentX + minWidth <= containerWidth {
                let width = Int.random(in: minWidth...maxWidth)
                let height = Int.random(in: minHeight...maxHeight)

                if currentX + width > containerWidth {
                    break
                }

                if currentY + height > containerHeight {
                    currentY = containerHeight - height
                }

                let color = chooseValidColor(x: currentX, y: currentY, width: width, height: height)

                let placedRect = Rect(
                    width: width,
                    height: height,
                    x: currentX,
                    y: currentY,
                    color: color,
                    originalColor: color
                )

                packedRects.append(placedRect)
                currentX += width
            }
            currentX = 0
            currentY += minHeight
        }
    }

    public func chooseValidColor(x: Int, y: Int, width: Int, height: Int) -> Color {
        var adjacentColors: [Color] = []

        for rect in packedRects {
            let isAbove = (rect.x == x && rect.y + rect.height == y)
            let isBelow = (rect.x == x && rect.y == y + height)
            let isLeft = (rect.y == y && rect.x + rect.width == x)
            let isRight = (rect.y == y && rect.x == x + width)

            if isAbove || isBelow || isLeft || isRight {
                adjacentColors.append(rect.color)
            }
        }

        let unusedColors = availableColors.filter { !adjacentColors.contains($0) }

        return unusedColors.randomElement() ?? availableColors[0]
    }

    public override func _draw() {
        for rect in packedRects {
            let position = Vector2(x: Float(rect.x), y: Float(rect.y))
            let size = Vector2(x: Float(rect.width), y: Float(rect.height))
            let outlineRect = Rect2(position: position, size: size)

            // Draw black outline (1-pixel larger)
            drawRect(outlineRect.grow(amount: 1), color: Color(r: 0, g: 0, b: 0, a: 1))

            // Draw filled rectangle with the chosen color
            drawRect(outlineRect, color: rect.color)
        }
    }
}
