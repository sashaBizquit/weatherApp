//
//  AppDelegate.swift
//  weatherApp
//
//  Created by Лыков on 16.04.17.
//
//

import UIKit
import CoreData
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    var ref: DatabaseReference!
    
    func getWeatherVC() -> WeatherTableVC {
        let split = self.window?.rootViewController as! UISplitViewController
        split.preferredDisplayMode = .allVisible
        split.delegate = self
        let navi = split.viewControllers[0] as! UINavigationController
        return navi.viewControllers.first as! WeatherTableVC
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let wvc = getWeatherVC()
        FirebaseApp.configure()
        self.ref = Database.database().reference()
        
        NotificationCenter.default.addObserver(wvc,
                                               selector: #selector(wvc.caughtError(_:)),
                                               name: displayNotificationName,
                                               object: nil)
        
//        NotificationCenter.default.addObserver(wvc,
//                                               selector: #selector(wvc.deviceOrientationMessage),
//                                               name: Notification.Name.UIDeviceOrientationDidChange,
//                                               object: nil)
        return true
    }
    
    private func restoreContainer() {
        
        let wvc = getWeatherVC()
        let context = self.persistentContainer.viewContext
        
        //deleting previous one
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CityWeather")
        
        do {
            let res = try context.execute(request) as! NSAsynchronousFetchResult<NSFetchRequestResult>
            
            let arr = res.finalResult as! [CityWeather]
            
            guard arr.count > 0 else {
                throw NSError.init(domain: "Persistant storage is empty,", code: 259, userInfo: nil)
            }
            
            for elem in arr {
                context.delete(elem)
            }
            self.saveContext()
        } catch let error as NSError {
            if error.code != 259 {
                print(error.localizedDescription)
            }
        } catch{
        
        }
        
        var fire = Dictionary<String, Any>()
        
        for temp in wvc.weatherDataList{
            
            //saving local context
            let entity = NSEntityDescription.entity(forEntityName: "CityWeather", in: context)
            let city = NSManagedObject(entity: entity!, insertInto: context)
            
            city.setValue(temp.city, forKey: "city")
            city.setValue(temp.degrees, forKey: "degrees")
            city.setValue(temp.country, forKey: "country")
            self.saveContext()
            
            //updating server database
            let post: [String : Any] = ["degrees": temp.degrees,
                        "country": temp.country,
                        "annotation": temp.annotation,
                        "location": ["latitude": temp.location.coordinate.latitude, "longitude": temp.location.coordinate.longitude]]
            
            fire["/\(temp.city)"] = post
        }
        self.ref.updateChildValues(fire)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        restoreContainer()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        restoreContainer()
    }
    
    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailVC else { return false }
        if topAsDetailController.currWeather == nil {
            return true
        }
        return false
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "weatherApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

