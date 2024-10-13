import Foundation
import SwiftGodotKit
import SwiftGodot

class RectanglePacker2D: Node2D {
    var rectangles: [ColorRect] = []
    var freeRectangles: [Rectangle] = []
    let containerWidth: Int = 800
    let containerHeight: Int = 600
    var originalColors: [Color] = []  // Store the original colors for each rectangle

    // Define four distinct colors
    let colors: [Color] = [
        Color(1, 0, 0),  // Red
        Color(0, 1, 0),  // Green
        Color(0, 0, 1),  // Blue
        Color(1, 1, 0)   // Yellow
    ]

    override func _ready() {
        freeRectangles.append(Rectangle(width: containerWidth, height: containerHeight))

        // Pack 10 rectangles
        for _ in 0..<10 {
            addPackedRectangle(width: Int.random(in: 50...200), height: Int.random(in: 50...150))
        }

        // Start random color animation after packing
        startRandomColorAnimation(duration: 10, lingerTime: 1)
    }

    func addPackedRectangle(width: Int, height: Int) {
        var rect = Rectangle(width: width, height: height)
        if pack(&rect) {
            let colorRect = ColorRect()
            colorRect.rectMinSize = Vector2(x: CGFloat(rect.width), y: CGFloat(rect.height))
            colorRect.position = Vector2(x: CGFloat(rect.x), y: CGFloat(rect.y))
            
            // Assign a valid color
            let validColor = getValidColor(for: rect)
            colorRect.modulate = validColor

            // Add the rectangle to the scene and store it
            addChild(colorRect)
            rectangles.append(colorRect)
            originalColors.append(validColor)  // Store the original color for resetting
        } else {
            print("Failed to pack rectangle with size: \(width)x\(height)")
        }
    }

    // Method to start the random color animation
    func startRandomColorAnimation(duration: Int, lingerTime: Int) {
        var iterations = 0
        let maxIterations = duration / lingerTime  // Calculate how many times it should loop

        let timer = Timer()
        timer.start(time: lingerTime.toDouble())

        timer.connect("timeout", self, "_on_timer_timeout")

        func _on_timer_timeout() {
            if iterations >= maxIterations {
                timer.stop()
                return
            }

            // Pick a random rectangle
            let randomIndex = Int.random(in: 0..<rectangles.count)
            let selectedRect = rectangles[randomIndex]
            let originalColor = originalColors[randomIndex]

            // Change to white
            selectedRect.modulate = Color(1, 1, 1)

            // Wait for linger time, then change back
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(lingerTime)) {
                selectedRect.modulate = originalColor
            }

            iterations += 1
        }
    }

    // Function to pack the rectangle (same as before)
    func pack(_ rect: inout Rectangle) -> Bool {
        for (index, freeRect) in freeRectangles.enumerated() {
            if rect.width <= freeRect.width && rect.height <= freeRect.height {
                rect.x = freeRect.x
                rect.y = freeRect.y

                freeRectangles.remove(at: index)
                splitFreeSpace(freeRect: freeRect, usedRect: rect)
                return true
            }
        }
        return false
    }

    func splitFreeSpace(freeRect: Rectangle, usedRect: Rectangle) {
        if freeRect.width > usedRect.width {
            freeRectangles.append(Rectangle(width: freeRect.width - usedRect.width, height: usedRect.height, x: usedRect.x + usedRect.width, y: usedRect.y))
        }
        if freeRect.height > usedRect.height {
            freeRectangles.append(Rectangle(width: usedRect.width, height: freeRect.height - usedRect.height, x: usedRect.x, y: usedRect.y + usedRect.height))
        }
    }

    // Check for adjacent rectangles and assign a valid color
    func getValidColor(for rect: Rectangle) -> Color {
        var adjacentColors: Set<Color> = []

        for colorRect in rectangles {
            let otherRect = Rectangle(
                width: Int(colorRect.rectMinSize.x),
                height: Int(colorRect.rectMinSize.y),
                x: Int(colorRect.position.x),
                y: Int(colorRect.position.y)
            )

            if isAdjacent(rectA: rect, rectB: otherRect) {
                adjacentColors.insert(colorRect.modulate)
            }
        }

        // Find the first color that is not used by any adjacent rectangles
        for color in colors {
            if !adjacentColors.contains(color) {
                return color
            }
        }

        // Default to the first color if no other color is available
        return colors[0]
    }

    // Helper function to determine if two rectangles are adjacent
    func isAdjacent(rectA: Rectangle, rectB: Rectangle) -> Bool {
        let horizontalTouch = (rectA.x == rectB.x + rectB.width || rectA.x + rectA.width == rectB.x)
        let verticalTouch = (rectA.y == rectB.y + rectB.height || rectA.y + rectA.height == rectB.y)
        
        return horizontalTouch || verticalTouch
    }
}

// Rectangle struct (same as previous)
struct Rectangle {
    var width: Int
    var height: Int
    var x: Int = 0
    var y: Int = 0
}
