//
//  WeatherTableVC.swift
//  weatherApp
//
//  Created by Лыков on 21.04.17.
//
//

import UIKit
import CoreData
import Gzip
import Foundation

let displayNotificationName = Notification.Name.init("DisplayMsg")

class WeatherTableVC: UITableViewController {
    
    var weatherDataList = [WeatherData]()
    var provider: WeatherDataProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.weatherDataList.count == 0 {
            self.getProviderReady()
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action:#selector(WeatherTableVC.addNewCity))
        }
    }
    
    func alertWithMessage(_ msg: String) {
        let alert = UIAlertController(title: "Message", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let cansel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cansel)
        
        if self.presentedViewController == nil {
            self.parent!.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func deviceOrientationMessage() {
        self.alertWithMessage("Device orientation was changed!")
    }
    
    func caughtError(_ notification: Notification){
        let error = notification.object as! NSError
        self.alertWithMessage(error.localizedDescription)
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weatherDataList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let tempData: WeatherData = self.weatherDataList[indexPath.row]
        cell.textLabel?.text = tempData.city + "  " + String(tempData.degrees) + "°"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.weatherDataList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DetailView" {
            let cell: UITableViewCell = sender as! UITableViewCell
            let navVC = segue.destination as! UINavigationController
            let newVC = navVC.viewControllers[0] as! DetailVC
            let index = self.tableView.indexPath(for: cell)
            newVC.currWeather = self.weatherDataList[index!.row]
        }
    }
    
    // MARK: - WeatherProviderDelegate
    
    func requestDidCompleteWeather(data: WeatherData, forIndex index: Int){
        
        let indexP = IndexPath(row: index, section: 0)
        
        if index < self.weatherDataList.count {
            self.weatherDataList[index] = data
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexP], with: .none)
            }
        }
        else {
            if self.weatherDataList.contains(where: {$0.city == data.city}) {
                self.alertWithMessage("This city already in the list")
            }
            else {
                self.weatherDataList.append(data)
                DispatchQueue.main.async {
                    self.tableView.insertRows(at: [indexP], with: .none)
                }
            }
        }
    }
}

// MARK: - WeatherDataProviderDelegate

extension WeatherTableVC: WeatherDataProviderDelegate {
    
    
    func getProviderReady() {
        self.provider = WeatherDataProvider(withDelegate: self)
        self.weatherDataList.removeAll()
        self.weatherDataList.append(contentsOf: self.provider!.getStoredData())
        self.provider!.getData(self.weatherDataList.map{$0.city})
    }
    
    func addNewCity() {
        
        let alert = UIAlertController(title: "Choose city to add", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let cansel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cansel)
        let add = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) -> Void in
            let textField = alert.textFields?[0]
            let cityName = (textField?.text)!
            if  cityName.isEmpty {
                alert.dismiss(animated: true, completion: nil)
                self.alertWithMessage("You didnt type anything")
            }
            else {
                if (self.weatherDataList.contains{$0.city == cityName}) {
                    alert.dismiss(animated: true, completion: nil)
                    self.alertWithMessage("This city already in the list")
                }
                else {
                    self.provider!.getCurrentWeatherDataFor(cityNamed: cityName, index: self.weatherDataList.count)
                }
            }
        }
        alert.addAction(add)
        alert.addTextField {
            (textField: UITextField) -> Void in
            textField.placeholder = "City name"
        }
        self.present(alert, animated: true, completion: nil)
    }
}
