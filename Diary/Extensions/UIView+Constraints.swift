import UIKit

extension UIView {

    func makeConstraintsEqualsToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        makeConstraints(
            top: superview.topAnchor,
            left: superview.leadingAnchor,
            right: superview.trailingAnchor,
            bottom: superview.bottomAnchor,
            insets: insets
        )
    }

    func makeConstraints(
        top: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil,
        left: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil,
        right: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil,
        bottom: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil,
        insets: UIEdgeInsets = .zero
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        if let top = top {
            constraints.append(topAnchor.constraint(equalTo: top, constant: insets.top))
        }
        if let left = left {
            constraints.append(leadingAnchor.constraint(equalTo: left, constant: insets.left))
        }
        if let right = right {
            let rightInset = insets.right > 0 ? insets.right * -1 : insets.right
            constraints.append(trailingAnchor.constraint(equalTo: right, constant: rightInset))
        }
        if let bottom = bottom {
            let bottomInset = insets.bottom > 0 ? insets.bottom * -1 : insets.bottom
            constraints.append(bottomAnchor.constraint(equalTo: bottom, constant: bottomInset))
        }
        NSLayoutConstraint.activate(constraints)
    }

    func makeConstraints(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        if let height = height {
            constraints.append(heightAnchor.constraint(equalToConstant: height))
        }
        if let width = width {
            constraints.append(widthAnchor.constraint(equalToConstant: width))
        }
        NSLayoutConstraint.activate(constraints)
    }

//    func centerXToSuperview() {
//        translatesAutoresizingMaskIntoConstraints = false
//        guard let superview = superview else { return }
//        centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
//    }
//
//    func centerYToSuperview() {
//        translatesAutoresizingMaskIntoConstraints = false
//        guard let superview = superview else { return }
//        centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
//    }
//
//    func centerToSuperview() {
//        centerXToSuperview()
//        centerYToSuperview()
//    }
}
