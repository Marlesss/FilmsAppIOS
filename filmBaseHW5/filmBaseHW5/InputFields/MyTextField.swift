import UIKit

// TODO: fix colors on black theme
class MyTextField: UITextField {
    internal var padding: CGFloat = 16
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX + padding, y: bounds.minY, width: bounds.width - padding * 2, height: bounds.height)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX + padding, y: bounds.minY, width: bounds.width - padding * 2, height: bounds.height)
    }
}

