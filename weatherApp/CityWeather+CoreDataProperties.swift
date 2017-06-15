//
//  CityWeather+CoreDataProperties.swift
//  
//
//  Created by Лыков on 26.04.17.
//
//

import Foundation
import CoreData


extension CityWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityWeather> {
        return NSFetchRequest<CityWeather>(entityName: "CityWeather")
    }

    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var degrees: Double

}
