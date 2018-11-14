//
//  MapViewController.swift
//  Atlas
//
//  Created by Jarvis Wu on 2018-10-29.
//

import UIKit
import Mapbox
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation
import MapboxGeocoder
import SideMenu

class MapViewController: UIViewController, MGLMapViewDelegate, StartNavigationViewDelegate, NavigationViewControllerDelegate, UISearchBarDelegate, SideMenuDelegate {

    var mapView: NavigationMapView!
    var directionsRoute: Route?
    var annotation: MGLPointAnnotation?
    var startNavigationView: StartNavigationView!
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMap()
        addSearchBar()
        addSideMenu()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        longPress.minimumPressDuration = 0.3
        mapView.addGestureRecognizer(longPress)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var compassViewCenterPoint = mapView.compassView.center
        compassViewCenterPoint.x = view.frame.width - 35
        compassViewCenterPoint.y = 115
        mapView.compassView.center = compassViewCenterPoint
    }
    
    private func addMap() {
        mapView = NavigationMapView(frame: view.bounds, styleURL: MGLStyle.streetsStyleURL)
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true
        mapView.showsHeading = true
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.logoView.transform = CGAffineTransform(translationX: 15, y: 15)
        mapView.attributionButton.transform = CGAffineTransform(translationX: -15, y: 15)
        mapView.attributionButton.tintColor = .lightGray
        mapView.tintColor = UIColor(named: "theme-blue")
        // TODO: this probably needs to be replaced as it interferes with other gestures in map view
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnMap))
        mapView.addGestureRecognizer(tap)
        view.addSubview(mapView)
    }
    
    private func addSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .prominent
        // TODO: avoid hardcoded frames here
        searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width - 20, height: 40)
        searchBar.layer.position = CGPoint(x: view.frame.width / 2, y: 65)
        searchBar.addShadow(color: UIColor.lightGray, radius: 5, opacity: 0.3, offset: CGSize.zero)
        searchBar.placeholder = "Search here"
        searchBar.addBorder(color: nil, width: nil, cornerRadius: 10)
        view.addSubview(searchBar)
    }
    
    private func addSideMenu() {
        let vc = SideMenuViewController()
        vc.delegate = self
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: vc)
        menuLeftNavigationController.leftSide = true
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: mapView, forMenu: UIRectEdge.left)
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .viewSlideInOut
        SideMenuManager.default.menuLeftNavigationController?.isNavigationBarHidden = true
        SideMenuManager.default.menuWidth = 280
        SideMenuManager.default.menuShadowOpacity = 0.3
        SideMenuManager.default.menuShadowRadius = 3
    }
    
    private func addStartNavigationView() {
        if startNavigationView != nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.startNavigationView.transform = CGAffineTransform(translationX: 0, y: 240)
            })
        }
        let frame = CGRect(x: 15, y: UIScreen.main.bounds.height - 240, width: view.frame.width - 30, height: 220)
        decodeLocation(from: directionsRoute?.routeOptions.waypoints.last?.coordinate) { (main, secondary) in
            guard let main = main, let secondary = secondary else { return }
            let routeInfo = NavigationRouteInfo.init(eta: self.directionsRoute?.expectedTravelTime, distance: self.directionsRoute?.distance, codedMainLocation: main, codedSecondaryLocation: secondary)
            self.startNavigationView = StartNavigationView(in: frame, withInfo: routeInfo)
            self.startNavigationView.transform = CGAffineTransform(translationX: 0, y: 240)
            self.startNavigationView.delegate = self
            if self.startNavigationView.superview != self.view {
                self.view.addSubview(self.startNavigationView)
            }
            UIView.animate(withDuration: 0.3) {
                self.startNavigationView.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        addAnnotation(to: coordinate)
    }
    
    func addAnnotation(to coordinate: CLLocationCoordinate2D) {
        // Create a basic point annotation and add it to the map
        if let currentAnnotation = annotation {
            mapView.removeAnnotation(currentAnnotation)
        }
        annotation = MGLPointAnnotation()
        annotation!.coordinate = coordinate
        annotation!.title = "Start navigation"
        mapView.addAnnotation(annotation!)
        calculateRoute(from: (mapView.userLocation!.coordinate), to: annotation!.coordinate) { (route, error) in
            if error != nil {
                print("Error calculating route")
            }
        }
    }
    
    func calculateRoute(from origin: CLLocationCoordinate2D,
                        to destination: CLLocationCoordinate2D,
                        completion: @escaping (Route?, Error?) -> ()) {
        // Coordinate accuracy is the maximum distance away from the waypoint that the route may still be considered viable, measured in meters. Negative values indicate that a indefinite number of meters away from the route and still be considered viable.
        let originWaypoint = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destinationWaypoint = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        // Specify that the route is intended for automobiles avoiding traffic
        let options = NavigationRouteOptions(waypoints: [originWaypoint, destinationWaypoint], profileIdentifier: .automobileAvoidingTraffic)
        // Generate the route object and draw it on the map
        _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
            self.directionsRoute = routes?.first
            // Draw the route on the map after creating it
            self.drawRoute(route: self.directionsRoute!)
        }
        adjustCamera(from: origin, to: destination)
    }
    
    func drawRoute(route: Route) {
        guard route.coordinateCount > 0 else { return }
        // Convert the route’s coordinates into a polyline
        var routeCoordinates = route.coordinates!
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        // If there's already a route line on the map, reset its shape to the new route
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0, green: 0.4, blue: 0.8392156863, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 5)
            // Add the source and style layer of the route line to the map
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
        }
        addStartNavigationView()
    }
    
    private func adjustCamera(from origin: CLLocationCoordinate2D,
                              to destination: CLLocationCoordinate2D) {
        let midPointCoordinate = MapHelper.getMidPoint(from: origin, to: destination)
        let distance = CLLocation.distance(from: origin, to: destination)
        // Shift up the mid point to account for the StartNavigationView
        let shiftedMidPointCoordinate = midPointCoordinate.coordinate(at: -distance/4, facing: mapView.direction)
        // Adjust altitude to re-zoom camera: distance * 4.5 / (1 + normalizedPitch * multiplier)
        let currentCamera = mapView.camera
        let newCamera = MGLMapCamera(lookingAtCenter: shiftedMidPointCoordinate, altitude: distance * 4.5 / Double(1 + currentCamera.pitch / 60 * 3), pitch: currentCamera.pitch, heading: currentCamera.heading)
        let cameraTransitionTime = distance < 30000 ? 3 : distance.magnitude / 30000
        mapView.setCamera(newCamera, withDuration: cameraTransitionTime, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
    }
    
    private func decodeLocation(from coordinate: CLLocationCoordinate2D?, completion: @escaping (String?, String?) -> ()) {
        guard let coordinate = coordinate else { completion(nil, nil); return }
        let options = ReverseGeocodeOptions(coordinate: coordinate)
        let _ = Geocoder.shared.geocode(options) { (placemarks, attribution, error) in
            guard let placemark = placemarks?.first, let postalAddress = placemark.postalAddress else { completion(nil, nil); return }
            completion(placemark.formattedName, "\(postalAddress.city), \(postalAddress.state) \(postalAddress.postalCode)")
        }
        completion(nil, nil)
    }
    
    // StartNavigationViewDelegate
    
    func startNavigation() {
        let origin = Waypoint(coordinate: mapView.userLocation!.coordinate, name: "You")
        let destination = Waypoint(coordinate: (directionsRoute?.routeOptions.waypoints.last?.coordinate)!, name: "Destination")
        let options = NavigationRouteOptions(waypoints: [origin, destination])
        Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first else { return }
            let viewController = NavigationViewController(for: route)
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func removeRouteFromMap() {
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource, let layer = mapView.style?.layer(withIdentifier: "route-style") as? MGLLineStyleLayer, let annotation = annotation {
            mapView.style?.removeLayer(layer)
            mapView.style?.removeSource(source)
            mapView.removeAnnotation(annotation)
            searchBar.text = ""
        }
    }
    
    // NavigationViewControllerDelegate
    
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        if canceled {
            navigationViewController.dismiss(animated: true) {
                self.removeRouteFromMap()
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        print("selected")
    }
    
    @objc func didTapOnMap(sender: NavigationMapView) {
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            performPlaceSearch(with: text)
            searchBar.endEditing(true)
            searchBar.resignFirstResponder()
        }
    }
    
    func performPlaceSearch(with searchText: String) {
        let options = ForwardGeocodeOptions(query: searchText)
        // To refine the search, you can set various properties on the options object.
        options.allowedISOCountryCodes = ["CA", "US"]
        options.focalLocation = CLLocation(latitude: mapView.userLocation!.coordinate.latitude, longitude: mapView.userLocation!.coordinate.longitude)
        options.allowedScopes = [.all]
        let _ = Geocoder.shared.geocode(options) { (placemarks, attribution, error) in
            guard let placemark = placemarks?.first else { return }
            print(placemark.name)
            print(placemark.qualifiedName!)
            let coordinate = placemark.location!.coordinate
            self.addAnnotation(to: coordinate)
            let formatter = CNPostalAddressFormatter()
            print(formatter.string(from: placemark.postalAddress!))
        }
    }
    
    func userDidSignOut() {
        dismiss(animated: true, completion: nil)
    }

}

