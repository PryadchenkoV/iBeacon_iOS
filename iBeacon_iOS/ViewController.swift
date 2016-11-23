//
//  ViewController.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 05.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIScrollViewDelegate, UISearchBarDelegate{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var tabBarOutlet: UIToolbar!
    @IBOutlet weak var barButtonUp: UIBarButtonItem!
    @IBOutlet weak var barButtonDown: UIBarButtonItem!
    
    @IBOutlet weak var barButtonCancel: UIBarButtonItem!
    
    var floorNumber = 0
    
    let maxFloor = 8
    let minFloor = 0
    @IBOutlet weak var navigationBarButtonSearch: UIBarButtonItem!
    
    var floorTitle = ""
    
    var arrayOfFloorImages = [UIImage]()
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        scrollView.delegate = self
        
        for _ in minFloor...maxFloor {
            arrayOfFloorImages.append(UIImage(named: "level1")!)
        }
        
        self.title = arrayOfFloors[floorNumber]

        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        if floorNumber == minFloor {
            barButtonDown.isEnabled = false
            
        } else if floorNumber == maxFloor {
            barButtonUp.isEnabled = false
        }
        imageView.image = arrayOfFloorImages[floorNumber]
        //createSearchBar()
    }
    
    
    func createSearchBar() {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Enter room number..."
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
//    
//    
//    
//    
//    
//    func createFloorMapForAsync(floorNumber: Int) -> UIImage? {
//        if let beginImageNextFloor = UIImage(named: "level\(floorNumber + 1)") {
//            let dictionaryCoordNextFloor = jsonToString(jsonName: "json\(floorNumber + 1)")
//            return textAllToImage(image: beginImageNextFloor, dictionaryCoord: dictionaryCoordNextFloor)
//        }
//        return nil
//    }
//
//    
//    func startNewMap(floorNumber: Int) {
//        let beginImage = UIImage(named: "level\(floorNumber+1)")!
//        let dictionaryCoord = jsonToString(jsonName: "json\(floorNumber+1)")
//        imageView.image = textAllToImage(image: beginImage, dictionaryCoord: dictionaryCoord)
//    }

    
    @IBAction func barButtonPush(_ sender: UIBarButtonItem) {
        switch sender {
        case barButtonUp:
            barButtonDown.isEnabled = true
            if floorNumber == maxFloor {
                barButtonUp.isEnabled = false
            } else {
                floorNumber += 1
                imageView.image = arrayOfFloorImages[floorNumber]
                self.title = arrayOfFloors[floorNumber]
            }
        case barButtonDown:
            barButtonUp.isEnabled = true
            if floorNumber == minFloor {
                barButtonDown.isEnabled = false
            } else {
                floorNumber -= 1
                imageView.image = arrayOfFloorImages[floorNumber]
                self.title = arrayOfFloors[floorNumber]
            }
        case barButtonCancel:
            if imageView.image != UIImage(named: "level\(floorNumber + 1)") {
                imageView.image = UIImage(named: "level\(floorNumber + 1)")
            } else {
                imageView.image = arrayOfFloorImages[floorNumber]
            }
        case navigationBarButtonSearch:
            let resultController = UITableViewController(style: .plain)
            let searchController = UISearchController(searchResultsController: resultController)
            self.present(searchController, animated: true, completion: nil)
        default:
            break
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

