//
//  WeatherDataProvider.swift
//  weatherApp
//
//  Created by Лыков on 24.04.17.
//
//

import Foundation
import SwiftyJSON
import CoreLocation
import CoreData

class WeatherDataProvider: NSObject, URLSessionDelegate {
    
    private let dataLink = "https://api.apixu.com/v1/current.json?key=cf110f1b48174601bd885710171904&q="
    private let cities = ["Moscow", "London", "Tokyo", "Washington", "Ivanovo"]
    private static let myQueue: OperationQueue = OperationQueue()
    private static let session: URLSession = URLSession(configuration: .default , delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
    
    weak var delegate: WeatherDataProviderDelegate?
    
    init(withDelegate someDelegate: WeatherDataProviderDelegate) {
        
        self.delegate = someDelegate
        WeatherDataProvider.myQueue.maxConcurrentOperationCount = max(min(Int(log2(Double(cities.count))), 10), 2)
        
    }
    
    func getStoredData() -> Array<WeatherData> {
        
        var storedData = Array<WeatherData>()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //download achived data from device
        
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CityWeather")
        
        do {
            let res = try context.execute(request) as! NSAsynchronousFetchResult<NSFetchRequestResult>
            let arr = res.finalResult as! [CityWeather]
            
            guard arr.count > 0 else {
                throw NSError.init(domain: "Persistant storage is empty,", code: 0, userInfo: nil)
            }
            
            for elem in arr {
                let some = WeatherData()
                some.city = elem.value(forKey: "city") as! String
                some.degrees = elem.value(forKey: "degrees") as! Double
                some.country = elem.value(forKey: "country") as! String
                storedData.append(some)
            }
        } catch {
            
            //if failed, then take some template data
            for name in self.cities {
                let some = WeatherData()
                some.city = name
                storedData.append(some)
            }
        }
        return storedData
    }
    
    private func getArchivedWeatherData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //download archived data from sever
        appDelegate.ref!.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let val = snapshot.value as? NSDictionary
            
            for (index, cityName) in (val?.allKeys.enumerated())! {
                let weather: WeatherData = WeatherData()
                weather.city = cityName as! String
                
                let value = val?[weather.city] as? NSDictionary
                weather.degrees = value?["degrees"] as? Double ?? 0
                weather.country = value?["country"] as? String ?? ""
                weather.annotation = value?["annotation"] as? String ?? ""
                
                let lat = (value?["location"] as? NSDictionary)?["latitude"] as? Double ?? 0
                let lon = (value?["location"] as? NSDictionary)?["longitude"] as? Double ?? 0
                
                weather.location = CLLocation(latitude: lat, longitude: lon)
                
                WeatherDataProvider.myQueue.addOperation {
                    self.delegate!.requestDidCompleteWeather(data: weather, forIndex: index)
                }
            }
            
        }) { (error) in
            self.postError(error as NSError)
        }
    }
    
    func getCurrentWeatherDataFor(cityNamed city: String, index: Int){
        let url = URL(string: self.dataLink + city)!
        
        let dataTask = WeatherDataProvider.session.dataTask(with: url) {
            (data, response, error) in
            if let err = error {
                self.postError(err as NSError)
            }
            else {
                do {
                    if data == nil {
                        throw NSError.init(domain: "Can't get JSON data for: " + city, code: 259, userInfo: nil)
                    }
                    let json = JSON(data!)
                    let weather: WeatherData = WeatherData()
                    
                    //check if json is correct
                    let bool = json["location"].exists() && json["current"].exists()
                    guard bool else {
                        throw NSError.init(domain: json["error"]["message"].stringValue, code: json["error"]["code"].intValue, userInfo: nil)
                    }
                    
                    weather.city = json["location"]["name"].stringValue
                    weather.degrees = json["current"]["temp_c"].double!
                    weather.country = json["location"]["country"].stringValue
                    weather.location = CLLocation(latitude: json["location"]["lat"].double!, longitude: json["location"]["lon"].double!)
                    weather.annotation = json["current"]["condition"]["text"].stringValue
                    
                    WeatherDataProvider.myQueue.addOperation {
                        self.delegate!.requestDidCompleteWeather(data: weather, forIndex: index)
                    }
                    
                }
                catch let error as NSError {
                    self.postError(error)
                    self.getArchivedWeatherData()
                }
                catch {
                    let str = "Can't get JSON data for: " + city
                    self.postError(NSError.init(domain: str, code: 259, userInfo: nil))
                    self.getArchivedWeatherData()
                }
            }
        }
        
        dataTask.resume()
    }
    
    func getData(_ cities: Array<String>) {
        for (index, cityName) in cities.enumerated(){
            getCurrentWeatherDataFor(cityNamed: cityName, index: index)
        }
    }
    
    func postError(_ error: NSError) {
        NotificationCenter.default.post(name: displayNotificationName, object: error)
    }
    
}
