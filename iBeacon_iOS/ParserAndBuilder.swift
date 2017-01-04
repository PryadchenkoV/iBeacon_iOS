//
//  ParserAndBuilder.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 23.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit

class ParserAndBuilder: NSObject {
    
    func createFloorMapForAsync(floorNumber: Int) -> UIImage? {
        var dictionaryCoordNextFloor = [String:String]()
        if let beginImageNextFloor = UIImage(named: "level\(floorNumber)") {
            dictionaryCoordNextFloor = jsonToStringCoords(jsonName: "json\(floorNumber)")
            return textAllToImage(image: beginImageNextFloor, dictionaryCoord: dictionaryCoordNextFloor, buildingName: "level\(floorNumber)")
        }
        return nil
    }
    
    func getNameOfBuildings() -> [String] {
        var arrayOfBuildingNames = [String]()
        for floor in 0...9 {
            arrayOfBuildingNames.append(jsonToStringBuildingName(jsonName: "json\(floor)"))
        }
        return arrayOfBuildingNames
    }
    
    
    
    func jsonToStringBuildingName(jsonName:String) -> String {
        let bundle = Bundle(for: type(of: self))
        var nameForMap = ""
        if let theURL = bundle.url(forResource: jsonName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data as Data, options:.allowFragments){
                    let dictionaryOfParcedData = parsedData as! NSDictionary
                    nameForMap = dictionaryOfParcedData["mapLevel"] as! String
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
        return nameForMap

    }

    func jsonToStringCoords(jsonName: String) -> [String:String] {
        let bundle = Bundle(for: type(of: self))
        var dictionaryCoord = [String:String]()
        if let theURL = bundle.url(forResource: jsonName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data as Data, options:.allowFragments){
                    let dictionaryOfParcedData = parsedData as! NSDictionary
                    let dictionaryForBeacons = dictionaryOfParcedData["beacons"] as! NSArray
                    for i in 0..<dictionaryForBeacons.count {
                        let dictionaryForEveryBeaconInfo = (dictionaryForBeacons[i] as! NSDictionary)
                        dictionaryCoord["\(String(describing: dictionaryForEveryBeaconInfo["coordX"]!)):\(String(describing: dictionaryForEveryBeaconInfo["coordY"]!))"] = String(describing: dictionaryForEveryBeaconInfo["title"]!)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
        UserDefaults.standard.set(dictionaryCoord, forKey: jsonName)
        return dictionaryCoord
    }
    
    
    func jsonToStringMapSize(jsonName: String) -> (mapSizeX:Int,mapSizeY:Int) {
        let bundle = Bundle(for: type(of: self))
        var mapSizeX = 0
        var mapSizeY = 0
        if let theURL = bundle.url(forResource: jsonName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data as Data, options:.allowFragments){
                    let dictionaryOfParcedData = parsedData as! NSDictionary
                    mapSizeX = dictionaryOfParcedData["mapSizeX"] as! Int
                    mapSizeY = dictionaryOfParcedData["mapSizeY"] as! Int
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }

        return (mapSizeX:mapSizeX,mapSizeY:mapSizeY)
    }

    

    func textAllToImage(image:UIImage, dictionaryCoord:[String:String], buildingName: String) -> UIImage {
        let textColor = UIColor.red
        let textFont = UIFont.systemFont(ofSize: 40, weight: UIFontWeightSemibold)
        var newImage = image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        for (coords, text) in dictionaryCoord {
            let coordX = coords.components(separatedBy: ":")[0]
            let coordY = coords.components(separatedBy: ":")[1]
            let point = CGPoint(x: Int(coordX)!, y: Int(coordY)!)
            let rect = CGRect(origin: point, size: image.size)
            text.draw(in: rect, withAttributes: textFontAttributes)
            
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            //UIGraphicsEndImageContext()
        }
        UIGraphicsEndImageContext()
        return newImage
    }
    

    
}
