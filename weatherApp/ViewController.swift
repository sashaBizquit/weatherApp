//
//  ViewController.swift
//  weatherApp
//
//  Created by Лыков on 16.04.17.
//
//

import UIKit
import SwiftyJSON
import RealmSwift
import Alamofire

//функция определения типа
func getType<T>(_ temp: T) {
    print(T.self)
}

class ViewController: UIViewController, URLSessionDelegate {

    let realm = try! Realm()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        
//        
//        let url = URL(string: "https://api.apixu.com/v1/current.json?key=cf110f1b48174601bd885710171904&q=Moscow")!
//        
//        let session = URLSession(configuration: .default , delegate: self, delegateQueue: OperationQueue.main)
//        
//        let downloadWeatherInfoTask = session.downloadTask(with: url){
//            (location, response, error) in
//            
//            if let err = error {
//                print("Can't download JSON data: \(err)")
//            }
//            else {
//                var data: Data?
//                do {
//                    data = try Data(contentsOf: location!)
//                }
//                catch {
//                    print("Can't get JSON data")
//                }
//                let json = JSON(data!)
//                
//                let weather: WeatherData = WeatherData()
//                
//                weather.city = json["location"]["name"].stringValue
//                weather.degrees = json["current"]["temp_c"].double!
//                
//                print("It's \(weather.degrees.rounded()) celsium degrees in \(weather.city) right now!")
//                
//                try! self.realm.write {
//                    self.realm.add(weather)
//                }
//            }
//        }
//        downloadWeatherInfoTask.resume()
//        
//        try! self.realm.write {
//            self.realm.deleteAll()
//        }
        
    }
    
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let url = "https://raw.githubusercontent.com/sashaBizquit/objc2less1/master/toys.json"
//        Alamofire.request(url).validate().responseJSON {
//                response in
//                
//                switch response.result
//                {
//                case .success(let value):
//                    let json = JSON(value)
//                    print(json)
//                    for temp in json["toys"]{
//                        let jsont = temp.1
//                        let weather: WeatherData = WeatherData()
//                        weather.host = jsont["name"].stringValue
//                        weather.ip = jsont["url"].stringValue
//                        
//                        try! self.realm.write {
//                            self.realm.add(weather)
//                        }
//                    }
//                    
//                case .failure(let error):
//                    print(error)
//                }
//        }
//        
//        
//        let data = realm.objects(WeatherData.self)
//        print(data)
//        
//        try! self.realm.write {
//            self.realm.deleteAll()
//        }
//        
//
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

