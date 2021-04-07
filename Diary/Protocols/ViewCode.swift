import UIKit

protocol ViewCode {
    func buildLayout()
    func buildViewHierarchy()
    func buildConstraints()
    func configureView()
}

extension ViewCode {
    func buildLayout() {
        buildViewHierarchy()
        buildConstraints()
        configureView()
    }

    func configureView() { }
}
