//
//  ViewController.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 05.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

extension Dictionary where Value: Equatable {
    func keysForValue(value: Value) -> [Key] {
        return flatMap { (key: Key, val: Value) -> Key? in
            value == val ? key : nil
        }
    }
}

var bufFloor = BeaconInfo()

class ViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate,  UISearchBarDelegate{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var tabBarOutlet: UIToolbar!
    
    @IBOutlet weak var barButtonCancel: UIBarButtonItem!
    
    @IBOutlet weak var barButtonAction: UIBarButtonItem!

    @IBOutlet weak var navigationBarButtonSearch: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID.init(uuidString:"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")! as UUID, identifier: "Simple")
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var floorTitle = ""
    var floorID = -1
    var floorNumber = 0
    var buildingName = ""
    
    var maxFloor = 0
    var minFloor = 0
    var dictionaryOfCoords = [String:String]()
    var bufColor = UIColor.blue
    let parserAndBuilder = ParserAndBuilder()
    
//    var arrayOfFloorImages = [UIImage]()
    
    let queue = DispatchQueue(label: "com.miem.hse.iBeacon_ViewController", qos: .background, attributes: .concurrent )
    
    var imageSize = (mapSizeX:0,mapSizeY:0)
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        bufColor = barButtonCancel.tintColor!
        
        barButtonCancel.tintColor = UIColor.clear
        barButtonCancel.isEnabled = false
        
        
        
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        //let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID.init(uuidString:"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")! as UUID, major: 1, minor: 2, identifier: "Simple")
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        scrollView.delegate = self
        print(floorID)
        print(minFloor)
        print(maxFloor)
        
        //print(beaconArray[4].floor,beaconArray[4].coordX,beaconArray[4].coordY)
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
        
        queue.sync {
            imageSize = parserAndBuilder.jsonToStringMapSize(jsonName: "json\(floorNumber)")
        }
        
        //imageView.image = parserAndBuilder.placeMarker(buildingName: buildingName, floorNumber: floorID, coordX: beaconArray[4].coordX, coordY: beaconArray[4].coordY)
    }
    
    func handleTouchTabbarCenter(){
        
    }
    
    func loadFromMemory(buildingName:String, floorNumber: Int) -> UIImage{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(buildingName)_\(floorNumber).png").path
        return UIImage(contentsOfFile: filePath)!
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for beacon in beacons {
            print(Int(beacon.minor),Int(beacon.major))
            for floor in beaconArray {
                if ((floor.major == Int(beacon.major)) && (floor.minor == Int(beacon.minor)) && (Int(beacon.major) != bufFloor.major) && (Int(beacon.minor) != bufFloor.minor)) {
                    print(floor.floor)
                    print(floor.coordX,floor.coordY)
                    DispatchQueue.main.async {
                        self.imageView.image = self.parserAndBuilder.placeMarker(buildingName: self.buildingName, floorNumber: self.floorID, coordX: floor.coordX, coordY: floor.coordY, flag: 1)
                    }
                    //updateDistance(beacons[0].proximity, coordX: floor.coordX, coordY: floor.coordY)
                    bufFloor.setMajorAndMinor(minor: Int(beacon.minor), major: Int(beacon.major))
                }
            }
        }
    }
    
    func updateDistance(_ distance: CLProximity, coordX: Int, coordY: Int) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                print("unknown")
            case .far:
                print("far")
                
            case .near:
               print("near")
                self.imageView.image = self.parserAndBuilder.placeMarker(buildingName: self.buildingName, floorNumber: self.floorID, coordX: coordX, coordY: coordY, flag: 1)
                
            case .immediate:
                print("immediate")
                self.imageView.image = self.parserAndBuilder.placeMarker(buildingName: self.buildingName, floorNumber: self.floorID, coordX: coordX, coordY: coordY, flag: 1)
            }
        }
    }
    
    func loadNeedData() {
        queue.sync {
            dictionaryOfCoords = parserAndBuilder.jsonToStringCoords(buildingName: self.buildingName, jsonName: "json\(floorNumber + 1)")
        }
    }
    
    func floorDown(){
        if floorID != minFloor {
            floorNumber -= 1
            floorID -= 1
            changeFloor()
        }
    }
    func floorUp(){
        if floorID != maxFloor {
            floorNumber += 1
            floorID += 1
            changeFloor()
        }
    }
    
    func onSwipeGuesterRecogniser(guesterRecogiser:UISwipeGestureRecognizer) {
        if guesterRecogiser.direction == .right && scrollView.zoomScale == 1.0 {
            floorDown()
        } else if guesterRecogiser.direction == .left && scrollView.zoomScale == 1.0 {
            floorUp()
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
        floorTitle = arrayOfFloors[floorNumber]
        self.title = floorTitle
        scrollView.zoomScale = 1.0
        //loadNeedData()
    }

    
    @IBAction func barButtonPush(_ sender: UIBarButtonItem) {
        switch sender {
        case barButtonCancel:
                imageView.image = loadFromMemory(buildingName: buildingName, floorNumber: floorID)
                barButtonCancel.tintColor = UIColor.clear
                barButtonCancel.isEnabled = false
        case navigationBarButtonSearch:
            //let resultController = UIViewController()
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Enter the room..."
            searchController.searchBar.delegate = self
            self.present(searchController, animated: true, completion: nil)
        case barButtonAction:
            let alert = UIAlertController(title: "Menu", message: "Choose an action", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction.init(title: "Show/Hide rooms", style: .default, handler: { (_) in
                if self.imageView.image != UIImage(named: "level\(self.floorID)") {
                    self.imageView.image = UIImage(named: "level\(self.floorID)")
                } else {
                    self.imageView.image = self.loadFromMemory(buildingName: self.buildingName, floorNumber: self.floorID)
                }
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        default:
            break
        }
    
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.dismiss(animated: true, completion: nil)
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var counter = 0
        searchController.searchBar.resignFirstResponder()
        for item in beaconArray {
            counter += 1
            if item.name == searchBar.text! && item.floor == floorTitle {
                DispatchQueue.main.async {
                    self.imageView.image = self.parserAndBuilder.placeMarker(buildingName: self.buildingName, floorNumber: self.floorID, coordX: item.coordX, coordY: item.coordY, flag: 2)
                }
                barButtonCancel.tintColor = bufColor
                barButtonCancel.isEnabled = true
                self.dismiss(animated: true, completion: nil)
                //                var coordX = Double(item.coordX)
                //                var coordY = Double(item.coordY)
                //                let error = scrollView.frame.size
                //                //coordX *= (Double(error.width))/Double((imageView.image?.size.width)!)
                //                //coordY *= (Double(error.height) * 3)/Double((imageView.image?.size.height)!)
                //                print(getLocationOfTouchInImageInScrollView(paintLocation: CGPoint.init(x: coordX, y: coordY)))
                //                print(coordX)
                //                print(coordY)
                //
                //scrollView.zoomScale = 1.9
                //                scrollView.zoom(to: CGRect(x: coordX, y: coordY, width: 100, height: 100), animated: true)
                
//                let contentSize = CGSize.init(width: ((self.imageView.image!.size.width) / scrollView.zoomScale), height: ((self.imageView.image!.size.height) / scrollView.zoomScale))
//                let zoomPoint = CGPoint.init(x: (CGFloat(item.coordX) / contentSize.width) * (scrollView.bounds.size.width), y: (CGFloat(item.coordY) / contentSize.height) * (scrollView.bounds.size.height))
//                
//                
//                //derive the size of the region to zoom to
//                let zoomSize = CGSize.init(width: scrollView.bounds.size.width / 3.0, height: scrollView.bounds.size.height / 3.0
//                )
//                
//                //offset the zoom rect so the actual zoom point is in the middle of the rectangle
//                let zoomRect = CGRect.init(x:  (zoomPoint.x) - (zoomSize.width) / 3.0, y: (zoomPoint.y) - (zoomSize.height) / 3.0, width: (zoomSize.width), height: (zoomSize.height))
//                
//                //apply the resize
//                scrollView.zoom(to: zoomRect, animated: true)
                break
            } else if item.name == searchBar.text! && item.floor != floorTitle {
                barButtonCancel.tintColor = bufColor
                barButtonCancel.isEnabled = true
                var tmp = item.floor.components(separatedBy: " ")
                print(Int(tmp[1])! - floorNumber)
                floorID += Int(tmp[1])! - floorNumber
                floorNumber = Int(tmp[1])!
                changeFloor()
                self.dismiss(animated: true, completion: nil)
                DispatchQueue.main.async {
                    self.imageView.image = self.parserAndBuilder.placeMarker(buildingName: self.buildingName, floorNumber: self.floorID, coordX: item.coordX, coordY: item.coordY, flag: 2)
                }
//                scrollView.zoomScale = 1.9
//                //                scrollView.zoom(to: CGRect(x: coordX, y: coordY, width: 100, height: 100), animated: true)
//                
//                let contentSize = CGSize.init(width: ((self.imageView.image!.size.width) / scrollView.zoomScale), height: ((self.imageView.image!.size.height) / scrollView.zoomScale))
//                let zoomPoint = CGPoint.init(x: (CGFloat(item.coordX) / contentSize.width) * (scrollView.bounds.size.width), y: (CGFloat(item.coordY) / contentSize.height) * (scrollView.bounds.size.height))
//                
//                
//                //derive the size of the region to zoom to
//                let zoomSize = CGSize.init(width: scrollView.bounds.size.width / 3.0, height: scrollView.bounds.size.height / 3.0
//                )
//                
//                //offset the zoom rect so the actual zoom point is in the middle of the rectangle
//                let zoomRect = CGRect.init(x:  (zoomPoint.x) - (zoomSize.width) / 3.0, y: (zoomPoint.y) - (zoomSize.height) / 3.0, width: (zoomSize.width), height: (zoomSize.height))
//                
//                //apply the resize
//                scrollView.zoom(to: zoomRect, animated: true)
                break
            } else if counter == beaconArray.count{
                let alert = UIAlertController(title: "Error", message: "Unknown room", preferredStyle: .alert)
            
                alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { (_) in
                    self.present(self.searchController, animated: true, completion: nil)
                }))
                self.dismiss(animated: true, completion: nil)
                self.present(alert, animated: true, completion: nil)
            }

        }

    }
    
    func getLocationOfTouchInImageInScrollView(paintLocation:CGPoint)->CGPoint {
        
        let imageSize = imageView.image!.size
        let imageFrame = scrollView.frame
        let imageRect = AVMakeRect(aspectRatio: imageSize, insideRect: imageFrame)
        let imageHeightToViewHeight = max(imageSize.height, imageSize.width) / imageFrame.size.height
        
        let px = (max(0, min(imageSize.width, ((paintLocation.x - imageRect.origin.x) * imageHeightToViewHeight))))
        let py = (max(0, min(imageSize.height, ((paintLocation.y - imageRect.origin.y ) * imageHeightToViewHeight))))
        let imageTouchPoint = CGPoint.init(x: px, y: py)
        
        return imageTouchPoint
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
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopMonitoring(for: beaconRegion)
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

