//
//  ViewController.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 05.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit

//let dictionaryCoord = ["101":"130:2186", "102":"130:2107", "103":"130:1863", "104":"130:1662", "105":"130:1484", "106":"130:1306", "107":"130:1127", "125":"410:2014", "124":"410:1934", "123":"410:1756", "111":"424:107", "109":"229:679", "122":"358:1558", "121":"498:1466", "116":"521:1069", "115":"518:989", "114":"626:677", "113":"645:425", "126":"716:811", "127":"937:390", "129":"1260:591", "120":"1527:583", "131":"1460:517", "132":"1461:578", "135":"1814:741", "136":"1573:927", "137":"1214:1130", "138":"1066:1049", "134":"1735:742", "128":"1177:682", "108":"267:881"]

//var dictionaryCoordNew = [String:String]()


class ViewController: UIViewController, UIScrollViewDelegate{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var tabBarOutlet: UIToolbar!
    @IBOutlet weak var barButtonUp: UIBarButtonItem!
    @IBOutlet weak var barButtonDown: UIBarButtonItem!
    
    var floorNumber = 0
    
    var arrayOfNextFloorImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        
        barButtonDown.isEnabled = false
        barButtonUp.isEnabled = false

        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        floorNumber = 1
        //startNewMap(floorNumber: floorNumber)
        imageView.image = createFloorMap(floorNumber: floorNumber)
        //arrayOfNextFloorImages = loadMassiveOfFloors()
        
    }
    
    func createFloorMap(floorNumber: Int) -> UIImage? {
        if let beginImageNextFloor = UIImage(named: "level\(floorNumber)") {
            let dictionaryCoordNextFloor = jsonToString(jsonName: "json\(floorNumber)")
            loadNextFloorParallel(floorNumber: floorNumber)
            return textAllToImage(image: beginImageNextFloor, dictionaryCoord: dictionaryCoordNextFloor)
        }
        return nil
    }
    
    
    
    
    
    func createFloorMapForAsync(floorNumber: Int) -> UIImage? {
        if let beginImageNextFloor = UIImage(named: "level\(floorNumber)") {
            let dictionaryCoordNextFloor = jsonToString(jsonName: "json\(floorNumber)")
            return textAllToImage(image: beginImageNextFloor, dictionaryCoord: dictionaryCoordNextFloor)
        }
        return nil
    }
    
    
    func loadNextFloorParallel(floorNumber: Int) {
        arrayOfNextFloorImages.removeAll()
        var flagOfFinish = 0
        let queue = DispatchQueue(label: "com.miem.hse.iBeacon", qos: .background, target: nil)
        queue.async {
            if let bufCreatedFloor = self.createFloorMapForAsync(floorNumber: floorNumber + 1) {
                
                self.arrayOfNextFloorImages.insert(bufCreatedFloor, at: 0)
                //self.arrayOfNextFloorImages.append(bufCreatedFloor)
                print("Queue1")
                flagOfFinish += 1
            }
        }
        queue.async {
            if let bufCreatedFloor = self.createFloorMapForAsync(floorNumber: floorNumber - 1) {
                self.arrayOfNextFloorImages.insert(bufCreatedFloor, at: 1)
                //self.arrayOfNextFloorImages.append(bufCreatedFloor)
                print("Queue2")
                flagOfFinish += 2
                
                //self.barButtonUp.isEnabled = true
                
            }
        }
        queue.async {
            DispatchQueue.main.async{
                switch flagOfFinish {
                case 1:
                    self.barButtonUp.isEnabled = true
                case 2:
                    self.barButtonDown.isEnabled = true
                case 3:
                    self.barButtonDown.isEnabled = true
                    self.barButtonUp.isEnabled = true
                default:
                    break
                }
            }
        }
        
//        barButtonUp.isEnabled = true
//        barButtonDown.isEnabled = true
//        queue.async {
//            if let bufCreatedFloor = self.createFloorMap(floorNumber: floorNumber - 1) {
//                self.arrayOfNextFloorImages.append(bufCreatedFloor)
//                print("Queue2")
//            }
//        }
    }
    
//    func startNewMap(floorNumber: Int) {
//        let beginImage = UIImage(named: "level\(floorNumber)")!
//        let dictionaryCoord = jsonToString(jsonName: "json\(floorNumber)")
//        imageView.image = textAllToImage(image: beginImage, dictionaryCoord: dictionaryCoord)
//    }
//
    
    @IBAction func barButtonPush(_ sender: UIBarButtonItem) {
        //print(arrayOfNextFloorImages)
        barButtonDown.isEnabled = false
        barButtonUp.isEnabled = false
        switch sender {
        case barButtonUp:
            floorNumber += 1
            if floorNumber == 10 {
                floorNumber = 9
            }
            //imageView.image = createFloorMap(floorNumber: floorNumber)
            imageView.image = arrayOfNextFloorImages[0]
            loadNextFloorParallel(floorNumber: floorNumber)
        case barButtonDown:
            floorNumber -= 1
            if floorNumber == 0 {
                floorNumber = 1
            }
            imageView.image = arrayOfNextFloorImages[1]
            loadNextFloorParallel(floorNumber: floorNumber)
            //imageView.image = createFloorMap(floorNumber: floorNumber)
        default:
            break
        }
        
    }
    
    
    func jsonToString(jsonName: String) -> [String:String] {
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
        return dictionaryCoord
    }
    
    func putTextOnMap(dictionaryOfCoord: [String:String], beginMap: UIImage) -> UIImage{
        var endImage = beginMap
        for (name,coords) in dictionaryOfCoord {
            let coordX = coords.components(separatedBy: ":")[0]
            let coordY = coords.components(separatedBy: ":")[1]
            let point = CGPoint(x: Int(coordX)!, y: Int(coordY)!)
            endImage = textToImage(drawText: name as NSString, inImage: endImage, atPoint: point)
        }
        return endImage
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func textAllToImage(image:UIImage, dictionaryCoord:[String:String]) -> UIImage {
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
    
    func textToImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.red
        let textFont = UIFont(name: "Helvetica Bold", size: 40)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    //MARK - TEST
    
    func loadMassiveOfFloors() -> [UIImage] {
        var arrayOfFloors = [UIImage]()
        let queue = DispatchQueue(label: "com.miem.hse.iBeacon_test", attributes: .concurrent)
        for floor in 1...9 {
            queue.async {
                if let createdImage = self.createFloorMapForAsync(floorNumber: floor) {
                    queue.sync {
                        arrayOfFloors.insert(createdImage, at: floor - 1)
                    }
                }
            }
        }
        return arrayOfFloors
    }
    
}

