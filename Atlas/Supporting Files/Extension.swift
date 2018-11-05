//
//  Extension.swift
//  Atlas
//
//  Created by Jarvis Wu on 2018-11-01.
//

import Foundation
import UIKit
import CoreLocation

extension UIView {
    
    func addBorder(color: UIColor?, width: CGFloat?, cornerRadius: CGFloat) {
        if let color = color, let width = width {
            layer.borderColor = color.cgColor
            layer.borderWidth = width
        }
        layer.cornerRadius = cornerRadius
    }
    
    func addShadow(color: UIColor, radius: CGFloat, opacity: Float, offset: CGSize) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
    }
    
}

extension CLLocation {

    class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return toLocation.distance(from: fromLocation)
    }
}

class MapHelper {
    
    class func getMidPoint(from pointA: CLLocationCoordinate2D, to pointB: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lonA: Double = pointA.longitude * .pi / 180
        let lonB: Double = pointB.longitude * .pi / 180
        let latA: Double = pointA.latitude * .pi / 180
        let latB: Double = pointB.latitude * .pi / 180
        let dLon: Double = lonB - lonA
        let x: Double = cos(latB) * cos(dLon)
        let y: Double = cos(latB) * sin(dLon)
        let latitude = atan2(sin(latA) + sin(latB), sqrt((cos(latA) + x) * (cos(latA) + x) + y * y))
        let longitude: Double = lonA + atan2(y, cos(latA) + x)
        let center = CLLocationCoordinate2D(latitude: latitude * 180 / .pi, longitude: longitude * 180 / .pi)
        return center
    }
    
}

