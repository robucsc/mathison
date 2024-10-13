import SwiftGodot

public class RectanglePacker: Node {
    
    // Struct to represent a rectangle
    public struct Rect {
        var width: Int
        var height: Int
        var x: Int = 0  // Initial position
        var y: Int = 0  // Initial position
    }

    // The container that holds all rectangles
    var containerWidth: Int = 0
    var containerHeight: Int = 0
    var packedRects: [Rect] = []

    public required init() {
        super.init()
    }

    public required init(nativeHandle: UnsafeRawPointer) {
        super.init(nativeHandle: nativeHandle)
    }

    // Method to initialize the container size
    public func setContainerSize(width: Int, height: Int) {
        containerWidth = width
        containerHeight = height
        packedRects.removeAll() // Clear existing packed rectangles
    }

    // Packing logic (a very basic greedy algorithm)
    public func pack(rects: [Rect]) -> [Rect] {
        var currentX = 0
        var currentY = 0
        var rowHeight = 0

        for rect in rects {
            var placedRect = rect

            // Check if it fits in the current row
            if currentX + rect.width <= containerWidth {
                placedRect.x = currentX
                placedRect.y = currentY
                currentX += rect.width
                rowHeight = max(rowHeight, rect.height)
            } else {  // Move to the next row
                currentX = 0
                currentY += rowHeight
                if currentY + rect.height > containerHeight {
                    print("Not enough space to pack all rectangles.")
                    break
                }
                placedRect.x = currentX
                placedRect.y = currentY
                currentX += rect.width
                rowHeight = rect.height
            }

            packedRects.append(placedRect)
        }

        return packedRects
    }

    public override func _ready() {
        print("RectanglePacker is ready")
    }
}
