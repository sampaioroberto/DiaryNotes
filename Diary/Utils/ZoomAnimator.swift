import UIKit

final class ZoomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let zoomedView: UIView
    private let zoomedFrame: CGRect
    private let isZoomingIn: Bool

    private let zoomScale: CGFloat = 50

    private let duration = 1.0
    private lazy var halfDuration = duration/2

    private let rotationAngle: CGFloat = 45.0

    private let minimumScale: CGFloat = 0.01
    private let mediumScale: CGFloat = 0.3
    private let fullScale: CGFloat = 1.0

    init(frame: CGRect, view: UIView, isZoomingIn: Bool) {
        zoomedFrame = frame
        zoomedView = view
        self.isZoomingIn = isZoomingIn
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        if isZoomingIn {
            guard let toView = transitionContext.view(forKey: .to) else {
                return
            }

            containerView.addSubview(toView)
            containerView.addSubview(zoomedView)

            UIView.animateKeyframes(
                withDuration: duration,
                delay: .zero,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: .zero, relativeDuration: .zero) {
                        toView.center = .init(x: self.zoomedFrame.midX, y: self.zoomedFrame.midY)
                        
                        toView.transform = CGAffineTransform.init(scaleX: self.minimumScale, y: self.minimumScale).concatenating(CGAffineTransform.init(rotationAngle: -self.rotationAngle))
                        self.zoomedView.frame = self.zoomedFrame
                    }

                    UIView.addKeyframe(withRelativeStartTime: .zero, relativeDuration: self.halfDuration) {
                        toView.transform = CGAffineTransform.init(scaleX: self.mediumScale, y: self.mediumScale)
                        self.zoomedView.transform = CGAffineTransform.init(scaleX: self.zoomScale, y: self.zoomScale).concatenating(CGAffineTransform.init(rotationAngle: self.rotationAngle))
                    }

                    UIView.addKeyframe(withRelativeStartTime: self.halfDuration, relativeDuration: self.halfDuration) {
                        containerView.bringSubviewToFront(toView)
                        toView.center = containerView.center
                        toView.transform = .identity

                    }
                },
                completion: { _ in
                    transitionContext.completeTransition(true)
                }
            )
        } else {
            guard let fromView = transitionContext.view(forKey: .from) else {
                return
            }

            containerView.insertSubview(self.zoomedView, belowSubview: fromView)

            UIView.animateKeyframes(
                withDuration: duration,
                delay: .zero,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: .zero, relativeDuration: .zero) {
                        self.zoomedView.center = .init(x: self.zoomedFrame.midX, y: self.zoomedFrame.midY)
                        self.zoomedView.transform = CGAffineTransform.init(scaleX: self.zoomScale, y: self.zoomScale).concatenating(CGAffineTransform.init(rotationAngle: self.rotationAngle))
                    }

                    UIView.addKeyframe(withRelativeStartTime: .zero, relativeDuration: self.halfDuration) {
                        fromView.center = .init(x: self.zoomedFrame.midX, y: self.zoomedFrame.midY)
                        fromView.transform = CGAffineTransform.init(scaleX: self.mediumScale, y: self.mediumScale)
                    }
                    UIView.addKeyframe(withRelativeStartTime: self.halfDuration, relativeDuration: self.halfDuration) {
                        self.zoomedView.transform = .init(scaleX: self.fullScale, y: self.fullScale)
                        fromView.transform = CGAffineTransform.init(scaleX: self.minimumScale, y: self.minimumScale).concatenating(CGAffineTransform.init(rotationAngle: -self.rotationAngle))
                    }
                },
                completion: { _ in
                    transitionContext.completeTransition(true)
                }
            )
        }
    }
}
