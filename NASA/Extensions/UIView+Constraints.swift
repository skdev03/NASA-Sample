import UIKit

extension UIView {
    /// Add a subview, constrained to the specified top, left, bottom and right margins.
    ///
    /// - Parameters:
    ///   - view: The subview to add.
    ///   - top: Optional top margin constant.
    ///   - left: Optional left (leading) margin constant.
    ///   - bottom: Optional bottom margin constant.
    ///   - right: Optional right (trailing) margin constant.
    ///   - toSafeArea: When `true`, constraints are created to the view's safe area, not its bounds.
    func addConstrained(subview: UIView,
                        top: CGFloat? = 0,
                        left: CGFloat? = 0,
                        bottom: CGFloat? = 0,
                        right: CGFloat? = 0,
                        toSafeArea: Bool = false) {
        
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            var topItem: NSLayoutConstraint?
            if toSafeArea {
                topItem = subview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: top)
            } else {
                topItem = subview.topAnchor.constraint(equalTo: topAnchor, constant: top)
            }
            topItem?.isActive = true
        }
        
        if let left = left {
            var leadingItem: NSLayoutConstraint?
            if toSafeArea {
                leadingItem = subview.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: left)
            } else {
                leadingItem = subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: left)
            }
            leadingItem?.isActive = true
        }
        
        if let bottom = bottom {
            var bottomItem: NSLayoutConstraint?
            if toSafeArea {
                bottomItem = subview.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: bottom)
            } else {
                bottomItem = subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom)
            }
            bottomItem?.isActive = true
        }
        
        if let right = right {
            var trailingItem: NSLayoutConstraint?
            if toSafeArea {
                trailingItem = subview.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: right)
            } else {
                trailingItem = subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: right)
            }
            trailingItem?.isActive = true
        }
    }

}
