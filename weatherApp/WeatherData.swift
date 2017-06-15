//
//  WeatherData.swift
//  weatherApp
//
//  Created by Лыков on 18.04.17.
//
//

import Foundation
import CoreLocation

class WeatherData {
    
    static let defaultCityName = "SomeCity"
    
    var city: String = defaultCityName
    var degrees: Double = 0
    var country: String = ""
    var location: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var annotation: String = ""
    
}

protocol WeatherDataProviderDelegate: class {
    func requestDidCompleteWeather(data: WeatherData, forIndex index: Int)
}
