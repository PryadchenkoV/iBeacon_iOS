//
//  ParserAndBuilder.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 23.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit
let kNotificationServiceGetBuildingNames = "NotificationServiceGetBuildingNames"
let kNotificationServiceJSONOfBuildingDownloaded = "NotificationServiceJSONOfBuildingDownloaded"
let kNotificationServiceJSONOfFloorDownloaded = "NotificationServiceJSONOfFloorDownloaded"
let kNotificationServiceGetBuildingNamesForDownloadedList = "NotificationServiceGetBuildingNamesForDownloadedList"
let kNotificationServiceStopWaiting = "NotificationServiceStopWaiting"

class ParserAndBuilder: NSObject {
    
    let mainURL = URL(string: "https://miem-msiea.rhcloud.com")
    
    func getBuildingNames() {
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        let fileManager = FileManager.default
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("AllBuildings")
        let url = URL(string: "https://miem-msiea.rhcloud.com/json?action=getBuildingsNames")
        let session = URLSession.shared
        let urlRequest = NSMutableURLRequest(url: url!)
        var dictWithDate = [String:String]()
        let task = session.dataTask(with: urlRequest as URLRequest){ (data,response,error) in
            if error != nil{
                print(error!.localizedDescription)
            } else {
                if let content = data {
                    do {
                        print(content)
                        let _ = fileManager.createFile(atPath: (jsonFilePath?.absoluteString)!, contents: nil, attributes: nil)
                        let jsonDict = try JSONSerialization.jsonObject(with: content, options: .allowFragments) as! NSArray
                        let json =  try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
                        let file = try FileHandle(forWritingTo: jsonFilePath!)
                        file.write(json)
                        print(jsonDict)
                        for i in 0..<(jsonDict).count {
                            let dictionaryOfBuilding = jsonDict[i] as! NSDictionary
                            print(dictionaryOfBuilding["buildingId"])
                            if let buildingID = dictionaryOfBuilding["buildingId"], let buildingName = dictionaryOfBuilding["buildingName"] {
                                dictWithDate[String(describing: buildingID)] = String(describing: buildingName)
                            }

                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationServiceGetBuildingNames),
                                                        object: nil,
                                                        userInfo: dictWithDate)
                    } catch let error as NSError {
                        print(" \(error.localizedDescription)")
                    }
                }
            }
        }
        task.resume()
        
    }
    
    func getListForDownloadedBuildings() -> [String:String] {
        var dictWithDate = [String:String]()
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("AllBuildings").path
        let content = NSData(contentsOfFile: filePath) as! Data
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: content, options: .allowFragments) as! NSArray
            for i in 0..<(jsonDict).count {
                let dictionaryOfBuilding = jsonDict[i] as! NSDictionary
                if let buildingID = dictionaryOfBuilding["buildingId"], let buildingName = dictionaryOfBuilding["buildingName"] {
                    dictWithDate[String(describing: buildingID)] = String(describing: buildingName)
                }
                
            }

        }
        catch let error as NSError {
            print(error.localizedDescription)
        }

        return dictWithDate
    }
    
    
    func downloadJSON(url: String,jsonName: String){
        let url = URL(string: url)
        let urlRequest = NSMutableURLRequest(url: url!)
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        let fileManager = FileManager.default
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent(jsonName)
        let session = URLSession.shared
        if fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationServiceJSONOfBuildingDownloaded),
                                            object: nil,
                                            userInfo: nil)
            
        } else {
            let task = session.dataTask(with: urlRequest as URLRequest){ (data,response,error) in
                if error != nil{
                    print(error!.localizedDescription)
                } else {
                    if let content = data {
                        
                        if !fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!) {
                            do {
                                
                                let jsonDict = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as AnyObject
                                print(jsonDict)
                                let json =  try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
                                //print(jsonDict)
                                let created = fileManager.createFile(atPath: (jsonFilePath?.absoluteString)!, contents: nil, attributes: nil)
                                let file = try FileHandle(forWritingTo: jsonFilePath!)
                                file.write(json)
                                print("JSON data was written to the file successfully!")
                            } catch let error as NSError {
                                print("Couldn't write to file: \(error.localizedDescription)")
                            }
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationServiceJSONOfBuildingDownloaded),
                                                        object: nil,
                                                        userInfo: nil)
                    }
                }
            }
            task.resume()
        }
    }
    
    func downloadJSONOfFloor(url: String,buildingName: String,jsonName: String){
        let url = URL(string: url)
        let urlRequest = NSMutableURLRequest(url: url!)
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        let fileManager = FileManager.default
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent(buildingName + jsonName)
        let session = URLSession.shared
        if fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationServiceJSONOfFloorDownloaded),
                                            object: nil,
                                            userInfo: [jsonName : buildingName])
        }else {
            let task = session.dataTask(with: urlRequest as URLRequest){ (data,response,error) in
                if error != nil{
                    print(error!.localizedDescription)
                } else {
                    if let content = data {
                        
                        if !fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!) {
                            let created = fileManager.createFile(atPath: (jsonFilePath?.absoluteString)!, contents: nil, attributes: nil)
                        }
                        do {
                            
                            let jsonDict = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as AnyObject
                            let json =  try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
                            //print(jsonDict)
                            
                            let file = try FileHandle(forWritingTo: jsonFilePath!)
                            file.write(json)
                            print("JSON data was written to the file successfully!")
                            //
                            //                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            //                        let filePath = documentsURL.appendingPathComponent("default").path
                            //                        let dataNew = NSData(contentsOfFile: filePath) as! Data
                            //
                            //
                            //                        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
                            //                        var getPath = paths.appendingPathComponent("default")
                            //                        var fileName = String(describing: NSURL.fileURL(withPath: getPath))
                            //                        var data = Data(contentsOfFile: fileName)
                            //                        let jsonDictNew = try JSONSerialization.jsonObject(with: dataNew, options: .mutableContainers) as AnyObject
                            //                        print(jsonDictNew)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationServiceJSONOfFloorDownloaded),
                                                            object: nil,
                                                            userInfo: [jsonName : buildingName])
                        } catch let error as NSError {
                            print("Couldn't write to file: \(error.localizedDescription)")
                        }
                    }
                }
            }
            task.resume()
        }
    }

    
    
//    func createFloorMapForAsync(floorNumber: Int) -> UIImage? {
//        var dictionaryCoordNextFloor = [String:String]()
//        if let beginImageNextFloor = UIImage(named: "level\(floorNumber)") {
//            dictionaryCoordNextFloor = jsonToStringCoords(jsonName: "json\(floorNumber)")
//            return textAllToImage(image: beginImageNextFloor, dictionaryCoord: dictionaryCoordNextFloor, buildingName: "level\(floorNumber)")
//        }
//        return nil
//    }
    
    func createFloorMapForAsync(building: String, floorNumber: String) -> UIImage? {
        var dictionaryCoordNextFloor = [String:String]()
        if let beginImageNextFloor = UIImage(named: "level\(floorNumber)") {
            dictionaryCoordNextFloor = jsonToStringCoords(buildingName: building,jsonName: floorNumber)
            return textAllToImage(image: beginImageNextFloor, dictionaryCoord: dictionaryCoordNextFloor, buildingName: "level\(floorNumber)")
        }
        return nil
    }
    
    func getIDOfBuildings(nameOfBuilding: String) -> [String] {
        var arrayOfBuildingID = [String]()
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent(nameOfBuilding).path
        let dataNew = NSData(contentsOfFile: filePath) as! Data
        do {
            let jsonDictNew = try JSONSerialization.jsonObject(with: dataNew, options: .mutableContainers) as AnyObject
            let mapIDArray = jsonDictNew["maps"] as? NSArray
            if mapIDArray != nil && (mapIDArray?.count)! > 0{
            for floor in (mapIDArray)! {
                let mapDict = floor as! NSDictionary
                arrayOfBuildingID.append(String(describing: mapDict["mapId"]!))
                }
            } else {
                print("No Floors")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationServiceStopWaiting),
                                                object: nil,
                                                userInfo: nil)
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        return arrayOfBuildingID
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
    
    func jsonToStringBuildingNameNew(buildingName: String, buildingID: String) -> String {
        var nameForMap = ""
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent(buildingName + buildingID).path
        let dataNew = NSData(contentsOfFile: filePath) as! Data
        do {
            let parsedData = try JSONSerialization.jsonObject(with: dataNew, options: .mutableContainers) as AnyObject
            let dictionaryOfParcedData = parsedData as! NSDictionary
            nameForMap = dictionaryOfParcedData["mapLevel"] as! String
        } catch{
            print(error.localizedDescription)

        }
        return nameForMap
    }
    

//    func jsonToStringCoords(jsonName: String) -> [String:String] {
//        let bundle = Bundle(for: type(of: self))
//        var dictionaryCoord = [String:String]()
//        if let theURL = bundle.url(forResource: jsonName, withExtension: "json") {
//            do {
//                let data = try Data(contentsOf: theURL)
//                if let parsedData = try? JSONSerialization.jsonObject(with: data as Data, options:.allowFragments){
//                    let dictionaryOfParcedData = parsedData as! NSDictionary
//                    let dictionaryForBeacons = dictionaryOfParcedData["beacons"] as! NSArray
//                    for i in 0..<dictionaryForBeacons.count {
//                        let dictionaryForEveryBeaconInfo = (dictionaryForBeacons[i] as! NSDictionary)
//                        dictionaryCoord["\(String(describing: dictionaryForEveryBeaconInfo["coordX"]!)):\(String(describing: dictionaryForEveryBeaconInfo["coordY"]!))"] = String(describing: dictionaryForEveryBeaconInfo["title"]!)
//                    }
//                }
//            } catch {
//                print(error.localizedDescription)
//            }
//            
//        }
//        UserDefaults.standard.set(dictionaryCoord, forKey: jsonName)
//        return dictionaryCoord
//    }
    
    func jsonToStringCoords(buildingName: String,jsonName: String) -> [String:String] {
        var dictionaryCoord = [String:String]()
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent(buildingName + jsonName).path
        let dataNew = NSData(contentsOfFile: filePath) as! Data
        do {
            if let parsedData = try? JSONSerialization.jsonObject(with: dataNew, options: .mutableContainers) as AnyObject {
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
