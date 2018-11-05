//
//  NavigationRouteInfo.swift
//  Atlas
//
//  Created by Jarvis Wu on 2018-11-03.
//

import Foundation
import CoreLocation

struct NavigationRouteInfo {
    var eta: TimeInterval?
    var distance: CLLocationDistance?
    var codedMainLocation: String?
    var codedSecondaryLocation: String?
}
