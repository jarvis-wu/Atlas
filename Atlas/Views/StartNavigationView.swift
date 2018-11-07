//
//  StartNavigationView.swift
//  Atlas
//
//  Created by Jarvis Wu on 2018-10-31.
//

import UIKit
import CoreLocation

protocol StartNavigationViewDelegate {
    func startNavigation()
    func removeRouteFromMap()
}

class StartNavigationView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dragIndicator: UIView!
    @IBOutlet weak var destinationTitleLabel: UILabel!
    @IBOutlet weak var destinationSubtitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var beginNavigationButton: UIButton!
    
    var initialFrame: CGRect!
    var delegate: StartNavigationViewDelegate!
    var yTotalTranslation: CGFloat!
    
    convenience init(in frame: CGRect, withInfo routeInfo: NavigationRouteInfo) {
        self.init(frame: frame)
        parseInfo(with: routeInfo)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("StartNavigationView", owner: self, options: nil)
        initialFrame = frame
        yTotalTranslation = UIScreen.main.bounds.height - initialFrame.origin.y
        setupContentView()
        setupLabels()
        setupDragIndicator()
        setupBeginNavigationButton()
    }
    
    private func setupContentView() {
        addSubview(contentView)
        contentView.frame = bounds
        contentView.addBorder(color: nil, width: nil, cornerRadius: 35)
        contentView.addShadow(color: UIColor.lightGray, radius: 5, opacity: 0.3, offset: CGSize.zero)
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panned)))
    }
    
    private func setupLabels() {
        destinationTitleLabel.minimumScaleFactor = 20 / destinationTitleLabel.font.pointSize
        destinationTitleLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setupDragIndicator() {
        // This is hardcoded from the home indicator of iPhone X
        dragIndicator.frame = CGRect(x: 107, y: 10, width: UIScreen.main.bounds.width - 244, height: 5)
        dragIndicator.addBorder(color: nil, width: nil, cornerRadius: 2.5)
    }
    
    private func setupBeginNavigationButton() {
        beginNavigationButton.frame = CGRect(x: 15, y: frame.height - 40 - 15, width: frame.width - 30, height: 40)
        beginNavigationButton.addBorder(color: nil, width: nil, cornerRadius: 20)
        beginNavigationButton.addTarget(self, action: #selector(beginNavigationButtonTapped), for: .touchUpInside)
    }
    
    @objc private func panned(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        self.center = CGPoint(x: self.center.x, y: self.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self)
        if sender.state == .ended {
            let yVelovity = sender.velocity(in: self).y
            let yTranslated = frame.origin.y - initialFrame.origin.y
            let animatedYTranslation = yTotalTranslation - yTranslated
            if yVelovity > 500 || yTranslated >= frame.height / 3 {
                dismiss(animatedYTranslation: animatedYTranslation)
                delegate.removeRouteFromMap()
            } else {
                UIView.animate(withDuration: Double(yTranslated / 800)) {
                    self.frame = self.initialFrame
                }
            }
        }
    }
    
    @objc private func beginNavigationButtonTapped(_ sender: UIButton) {
        dismiss(animatedYTranslation: yTotalTranslation)
        delegate.startNavigation()
    }
    
    private func dismiss(animatedYTranslation: CGFloat) {
        UIView.animate(withDuration: Double(animatedYTranslation / 800), animations: {
            self.frame = self.frame.offsetBy(dx: 0, dy: animatedYTranslation)
        }) { (completed) in
            self.removeFromSuperview()
        }
    }
    
    private func parseInfo(with info: NavigationRouteInfo) {
        if let eta = info.eta, let distance = info.distance, let main = info.codedMainLocation, let secondary = info.codedSecondaryLocation {
            destinationTitleLabel.text = main
            destinationSubtitleLabel.text = secondary
            let trimmedDistance = String(format: "%.2f", distance / 1000)
            distanceLabel.text = "Travel distance: \(trimmedDistance)km"
            let travelTimeFormatter = DateComponentsFormatter()
            travelTimeFormatter.unitsStyle = .abbreviated
            travelTimeFormatter.allowedUnits = [.hour, .minute]
            etaLabel.text = "ETA: \(travelTimeFormatter.string(from: eta)!)"
        }
    }

}
