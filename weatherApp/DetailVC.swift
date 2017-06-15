//
//  DetailVC.swift
//  weatherApp
//
//  Created by Лыков on 21.04.17.
//
//

import UIKit
import MapKit

class DetailVC: UIViewController {
    
    var currWeather: WeatherData?

    @IBOutlet weak var countryTitle: UILabel!
    @IBOutlet weak var annotation: UILabel!
    @IBOutlet weak var degreeTitle: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard currWeather != nil else {
            return
        }
        
        self.navigationItem.title = currWeather!.city
        
        self.countryTitle.text = "\u{27A4} " + currWeather!.country
        self.annotation.text = currWeather!.annotation
        switch currWeather!.degrees.sign {
            case .plus:
                self.degreeTitle.text = "+" + currWeather!.degrees.description + "°"
            default:
                self.degreeTitle.text = currWeather!.degrees.description + "°"
        }
        
        let location: CLLocation = currWeather!.location
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = currWeather!.city
        
        self.map.addAnnotation(annotation)
        self.map.setRegion(region, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        switch (self.map.mapType) {
        case .hybrid:
            self.map.mapType = .standard;
        case .standard:
            self.map.mapType = .hybrid;
        default:
            break;
        }
        self.map.showsUserLocation = false
        self.map.removeFromSuperview()
        self.map.delegate = nil
        self.map = nil
    }
}
