//
//  ViewController.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 05.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit

extension Dictionary where Value: Equatable {
    func keysForValue(value: Value) -> [Key] {
        return flatMap { (key: Key, val: Value) -> Key? in
            value == val ? key : nil
        }
    }
}


class ViewController: UIViewController, UIScrollViewDelegate, UISearchControllerDelegate, UISearchBarDelegate{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var tabBarOutlet: UIToolbar!
    
    @IBOutlet weak var barButtonCancel: UIBarButtonItem!
    
    var floorID = -1
    var floorNumber = 0
    var buildingName = ""
    
    var maxFloor = 0
    var minFloor = 0
    @IBOutlet weak var navigationBarButtonSearch: UIBarButtonItem!
    
    var floorTitle = ""
    
    var dictionaryOfCoords = [String:String]()
    
    let parserAndBuilder = ParserAndBuilder()
    
//    var arrayOfFloorImages = [UIImage]()
    
    let queue = DispatchQueue(label: "com.miem.hse.iBeacon_ViewController", qos: .background, attributes: .concurrent )
    
    var imageSize = (mapSizeX:0,mapSizeY:0)
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        scrollView.delegate = self
        print(floorID)
        print(minFloor)
        print(maxFloor)
//        for _ in minFloor...maxFloor {
//            arrayOfFloorImages.append(UIImage(named: "level1")!)
//        }
        
        self.title = arrayOfFloors[floorNumber]

        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        let swipeRightGuesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeGuesterRecogniser(guesterRecogiser:)))
        swipeRightGuesture.direction = .right
        scrollView.addGestureRecognizer(swipeRightGuesture)
        
        let swipeLeftGuesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeGuesterRecogniser(guesterRecogiser:)))
        swipeLeftGuesture.direction = .left
        scrollView.addGestureRecognizer(swipeLeftGuesture)
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(gestureRecognizer:)))
        tapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tapRecognizer)
        
        
        imageView.image = loadFromMemory(buildingName: buildingName, floorNumber: floorID)
        //loadNeedData()
    }
    
    func loadFromMemory(buildingName:String, floorNumber: Int) -> UIImage{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(buildingName)_\(floorNumber).png").path
        return UIImage(contentsOfFile: filePath)!
    }
    
//    func loadNeedData() {
//        queue.sync {
//            dictionaryOfCoords = parserAndBuilder.jsonToStringCoords(jsonName: "json\(floorNumber + 1)")
//            imageSize = parserAndBuilder.jsonToStringMapSize(jsonName: "json\(floorNumber + 1)")
//        }
//    }
    
    func onSwipeGuesterRecogniser(guesterRecogiser:UISwipeGestureRecognizer) {
        if guesterRecogiser.direction == .right && scrollView.zoomScale == 1.0 {
            if floorID != minFloor {
                floorNumber -= 1
                floorID -= 1
                changeFloor()
            }
        } else if guesterRecogiser.direction == .left && scrollView.zoomScale == 1.0 {
            if floorID != maxFloor {
                floorNumber += 1
                floorID += 1
                changeFloor()
            }
        }
    }
    
    
    func onDoubleTap(gestureRecognizer: UITapGestureRecognizer) {
        let scale = min(scrollView.zoomScale * 2, scrollView.maximumZoomScale)
        
        if scale != scrollView.zoomScale {
            let point = gestureRecognizer.location(in: imageView)
            
            let scrollSize = scrollView.frame.size
            let size = CGSize(width: scrollSize.width / scale,
                              height: scrollSize.height / scale)
            let origin = CGPoint(x: point.x - size.width / 2,
                                 y: point.y - size.height / 2)
            scrollView.zoom(to:CGRect(origin: origin, size: size), animated: true)
            print(CGRect(origin: origin, size: size))
        }
    }
    
    
    func changeFloor()  {
        let toUImage:UIImage?
        toUImage = loadFromMemory(buildingName: buildingName, floorNumber: floorID)
        //let toImage = arrayOfFloorImages[floorNumber]
        UIView.transition(with: self.imageView,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: { self.imageView.image = toUImage },
                                  completion: nil)
        
//        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, animations: {
//            self.imageView.image = toImage
//        }, completion: nil)
        //imageView.image = arrayOfFloorImages[floorNumber]
        self.title = arrayOfFloors[floorNumber]
        scrollView.zoomScale = 1.0
        //loadNeedData()
    }

    
    @IBAction func barButtonPush(_ sender: UIBarButtonItem) {
        switch sender {
        case barButtonCancel:
            if imageView.image != UIImage(named: "level\(floorID)") {
                imageView.image = UIImage(named: "level\(floorID)")
            } else {
                imageView.image = loadFromMemory(buildingName: buildingName, floorNumber: floorID)
            }
        case navigationBarButtonSearch:
            //let resultController = UIViewController()
            let searchController = UISearchController(searchResultsController: nil)
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Enter the room..."
            searchController.searchBar.delegate = self
            self.present(searchController, animated: true, completion: nil)
        default:
            break
        }
    
        
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !dictionaryOfCoords.keysForValue(value: searchBar.text!).isEmpty {
            let coordString = dictionaryOfCoords.keysForValue(value: searchBar.text!)[0]
            var coordX = Double(coordString.components(separatedBy: ":")[0])!
            var coordY = Double(coordString.components(separatedBy: ":")[1])!
            let error = scrollView.frame.size
            coordX *= Double(error.width)/Double(imageSize.mapSizeX) / Double(scrollView.zoomScale + 0.2)
            coordY *= Double(error.height)/Double(imageSize.mapSizeY) / Double(scrollView.zoomScale + 0.2)
            
            print(scrollView.zoomScale)
            print(error)
            print(coordString)
            
            scrollView.zoom(to: CGRect(x: coordX, y: coordY, width: 100, height: 100), animated: true)
        }
    }
    
    
    
    
    
//    func jsonToString(jsonName: String) -> [String:String] {
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
//        return dictionaryCoord
//    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
//    
//    func textAllToImage(image:UIImage, dictionaryCoord:[String:String]) -> UIImage {
//        let textColor = UIColor.red
//        let textFont = UIFont.systemFont(ofSize: 40, weight: UIFontWeightSemibold)
//        var newImage = image
//        let scale = UIScreen.main.scale
//        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
//        
//        let textFontAttributes = [
//            NSFontAttributeName: textFont,
//            NSForegroundColorAttributeName: textColor,
//            ] as [String : Any]
//        
//        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
//        
//        for (coords, text) in dictionaryCoord {
//            let coordX = coords.components(separatedBy: ":")[0]
//            let coordY = coords.components(separatedBy: ":")[1]
//            let point = CGPoint(x: Int(coordX)!, y: Int(coordY)!)
//            let rect = CGRect(origin: point, size: image.size)
//            text.draw(in: rect, withAttributes: textFontAttributes)
//            
//            newImage = UIGraphicsGetImageFromCurrentImageContext()!
//            //UIGraphicsEndImageContext()
//        }
//        UIGraphicsEndImageContext()
//        
//        return newImage
//    }
//    
//    //MARK - TEST
//    
//    func loadMassiveOfFloors() {
//        let queue = DispatchQueue(label: "com.miem.hse.iBeacon_test", qos: .background, attributes: .concurrent )
//        for floor in minFloor...maxFloor {
//            
//            queue.sync {
//                if let createdImage = self.createFloorMapForAsync(floorNumber: floor) {
//                    self.arrayOfFloorImages.remove(at: floor)
//                    self.arrayOfFloorImages.insert(createdImage, at: floor)
//                    print("\(floor) finish")
//                }
//            }
//            if floor == maxFloor {
//                dismiss(animated: false, completion: nil)
//            }
//        }
//    }
//    
}

