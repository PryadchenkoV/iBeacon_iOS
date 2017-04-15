//
//  ChooseFloorViewController.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 23.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit

let kTableViewCellFloor = "tableCellFloor"
let kSegueFormFloorToMap = "fromFloorToMap"

var arrayOfFloors = [String]()

class ChooseFloorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet weak var tableViewFloor: UITableView!
    
    var overlay : UIView?
    @IBOutlet weak var barButtonSearch: UIBarButtonItem!
    
    //let queue = DispatchQueue(label: "com.miem.hse.iBeacon_test")
    let queue = DispatchQueue(label: "com.miem.hse.iBeacon_test")
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

    
    var chosenFloor = 0
    var chosenTitle = ""
    var buildingName = ""
    var buildingID = -1
    var parserAndBuilder = ParserAndBuilder()
    var arrayOfFloorID = [String]()
    var searchFlag = false
    var searchRoom = ""
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var arrayOfNextFloorImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationDownloadedJSONReceived(notification:)),
                                               name: NSNotification.Name(rawValue: kNotificationServiceJSONOfBuildingDownloaded),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationDownloadedJSONOfFloorReceived(notification:)),
                                               name: NSNotification.Name(rawValue: kNotificationServiceJSONOfFloorDownloaded),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationStopWaiting(notification:)),
                                               name: NSNotification.Name(rawValue: kNotificationServiceStopWaiting),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationStartWaiting(notification:)),
                                               name: NSNotification.Name(rawValue: kNotificationServiceStartWaiting),
                                               object: nil)
//
//        let refreshBarButton: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
//        self.navigationItem.rightBarButtonItem = refreshBarButton
//        activityIndicator.startAnimating()
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        
        //present(alert, animated: true, completion: nil)
        parserAndBuilder.downloadJSON(url: "https://miem-msiea.rhcloud.com/json?action=getBuildingInfo&buildingId=\(buildingID)", jsonName: buildingName)
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let filePath = documentsURL.appendingPathComponent("default").path
////        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
////        var getPath = paths.appendingPathComponent("default")
////        var fileName = String(describing: NSURL.fileURL(withPath: getPath))
//        let data = Data(contentsOfFile: filePath)
//        
//        print(data)
        
//        arrayOfFloors = parserAndBuilder.getNameOfBuildings()
//        
//        for floor in 0...arrayOfFloors.count - 1{
//            arrayOfNextFloorImages.append(UIImage(named: "level\(floor)")!)
//        }
        
//        for floor in 0...arrayOfFloors.count - 1{
//            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let filePath = documentsURL.appendingPathComponent("\(buildingName)_\(floor).png").path
//            if FileManager.default.fileExists(atPath: filePath) {
//                arrayOfNextFloorImages.remove(at: floor)
//                arrayOfNextFloorImages.insert(UIImage(contentsOfFile: filePath)!, at: floor)
//                floorCounter += 1
//                print("\(floor) Restored")
//
//            }
//        }
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        
        tableViewFloor.delegate = self
        tableViewFloor.dataSource = self
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let filePath = documentsURL.appendingPathComponent("\(buildingName)_\(0).png").path
//        if !FileManager.default.fileExists(atPath: filePath) {
//            createMassiveOfFloors(minFloor: 0, maxFloor: 9)
//        }
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        chosenFloor = 0
        buildingID = -1
        NotificationCenter.default.removeObserver(self)
    }
    
    func notificationStopWaiting(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            //self.activityIndicator.stopAnimating()
            self.alert.dismiss(animated: false, completion: nil)
        })
    }
    
    func notificationStartWaiting(notification: Notification) {
        DispatchQueue.main.async {
            self.present(self.alert, animated: true, completion: nil)
        }
    }
    
    func notificationDownloadedJSONOfFloorReceived(notification: Notification) {
        if let userInfo = notification.userInfo as? [String:String] {
//            print(userInfo)
//            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let filePath = documentsURL.appendingPathComponent(buildingName + userInfo.keysForValue(value: buildingName)[0]).path
//            let dataNew = NSData(contentsOfFile: filePath) as! Data
//            do {
//                let jsonDictNew = try JSONSerialization.jsonObject(with: dataNew, options: .mutableContainers) as AnyObject
//                print(jsonDictNew)
//            } catch{
//                
//            }
            arrayOfFloors.append(parserAndBuilder.jsonToStringBuildingNameNew(buildingName: buildingName, buildingID: userInfo.keysForValue(value: buildingName)[0]))
            if arrayOfFloors.count == arrayOfFloorID.count {
                DispatchQueue.main.async {
                    arrayOfFloors.sort()
                    self.tableViewFloor.reloadData()
                }
                createMassiveOfFloors()
            }
        }
    }
    
    func notificationDownloadedJSONReceived(notification: Notification) {
        arrayOfFloorID = parserAndBuilder.getIDOfBuildings(nameOfBuilding: buildingName)
        downloadFloorJSONWithID(arrayOfID: arrayOfFloorID)
    }
    
    
    
    func downloadFloorJSONWithID(arrayOfID: [String]) {
        for floor in arrayOfID {
            parserAndBuilder.downloadJSONOfFloor(url: "https://miem-msiea.rhcloud.com/json?action=getMapInfo&mapId=\(floor)",buildingName: buildingName, jsonName: floor)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfFloors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableViewFloor.dequeueReusableCell(withIdentifier: kTableViewCellFloor, for: indexPath) as! FloorTableViewCell
        tableViewCell.labelFloorName.text = String(arrayOfFloors[indexPath.row])
        return tableViewCell
    }
    
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let lastRowIndex = tableView.numberOfRows(inSection: 0)
//        if indexPath.row == lastRowIndex - 1 {
//            loadMassiveOfFloors(minFloor: 0, maxFloor: 8)
//        }
//
//    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        chosenFloor = indexPath.row
        chosenTitle = arrayOfFloors[chosenFloor]
        performSegue(withIdentifier: kSegueFormFloorToMap, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueFormFloorToMap {
            if let destinantionController = segue.destination as? ViewController {
                destinantionController.floorNumber = chosenFloor
                destinantionController.floorTitle = arrayOfFloors[chosenFloor]
                destinantionController.minFloor = Int(arrayOfFloorID.first!)!
                destinantionController.maxFloor = Int(arrayOfFloorID.last!)!
                destinantionController.floorID = Int(arrayOfFloorID[chosenFloor])!
                destinantionController.searchFlag = searchFlag
                searchFlag = false
                destinantionController.searchRoom = searchRoom
                searchRoom = ""
                //destinantionController.arrayOfFloorImages = arrayOfNextFloorImages
                destinantionController.buildingName = buildingName
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func barButtonPushed(_ sender: UIBarButtonItem) {
        if sender == barButtonSearch {
            searchController.dimsBackgroundDuringPresentation = true
            searchController.searchBar.placeholder = "Enter the room..."
            searchController.searchBar.delegate = self
            self.present(searchController, animated: true, completion: nil)
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
            if item.name == searchBar.text! {
                
                chosenTitle = item.floor
                chosenFloor = arrayOfFloors.index(of: self.chosenTitle)!
                searchFlag = true
                searchRoom = item.name
                self.dismiss(animated: true, completion: nil)
                performSegue(withIdentifier: kSegueFormFloorToMap, sender: self)
                searchController.searchBar.text = ""
                break
            } else if counter == beaconArray.count{
                let alert = UIAlertController(title: "Error", message: "Unknown room", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { (_) in
                    self.present(self.searchController, animated: true, completion: nil)
                }))
                searchController.searchBar.text = ""
                self.dismiss(animated: true, completion: nil)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
//    func createMassiveOfFloors(minFloor: Int, maxFloor: Int) {
//        let refreshBarButton: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
//        self.navigationItem.rightBarButtonItem = refreshBarButton
//        activityIndicator.startAnimating()
//        for floor in minFloor...maxFloor {
//            queue.asyncAfter(deadline: .now() + 1.3 * Double(floor), execute: {
//                if let createdImage = self.parserAndBuilder.createFloorMapForAsync(floorNumber: floor) {
//                    print("\(floor) finish")
//                    do {
//                        if let pngImageData = UIImagePNGRepresentation(createdImage) {
//                            
//                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                            let fileURL = documentsURL.appendingPathComponent("\(self.buildingName)_\(floor).png")
//                            try pngImageData.write(to: fileURL, options: .atomic)
//                            print("\(floor) Saved")
//                        }
//                    }
//                        
//                    catch {
//                        
//                    }
//                    if floor == maxFloor {
//                        DispatchQueue.main.async {
//                            self.activityIndicator.stopAnimating()
//                        }
//                    }
//                }
//            })
////            queue.async {
////    
////                if let createdImage = self.parserAndBuilder.createFloorMapForAsync(floorNumber: floor) {
////                    print("\(floor) finish")
////                    do {
////                        if let pngImageData = UIImagePNGRepresentation(createdImage) {
////                            
////                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
////                            let fileURL = documentsURL.appendingPathComponent("\(self.buildingName)_\(floor).png")
////                            try pngImageData.write(to: fileURL, options: .atomic)
////                            print("\(floor) Saved")
////                        }
////                    }
////                    
////                    catch {
////                        
////                    }
//////                    if floor == maxFloor {
//////                        DispatchQueue.main.async {
//////                            self.activityIndicator.stopAnimating()
//////                        }
//////                    }
////                }
//            
//        }
//    }
    
    func createMassiveOfFloors() {
        var counterForAsync = 0.0
        for floor in arrayOfFloorID {
            let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
            let fileURL = documentsDirectoryPath.appendingPathComponent("\(self.buildingName)_\(floor).png")
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: (fileURL?.absoluteString)!) {
                print("\(floor) already exists")
                if floor == arrayOfFloorID.last {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                        //self.activityIndicator.stopAnimating()
                        self.createArrayOfBeacons()
                        self.alert.dismiss(animated: false, completion: nil)
                    })
                }
                continue
            }
            counterForAsync += 1.0
            queue.asyncAfter(deadline: .now() + 1.6 * counterForAsync, execute: {
                if let createdImage = self.parserAndBuilder.createFloorMapForAsync(building: self.buildingName, floorNumber: floor) {
                    print("\(floor) finish")
                    do {
                        if let pngImageData = UIImagePNGRepresentation(createdImage) {
                            let _ = fileManager.createFile(atPath: (fileURL?.absoluteString)!, contents: nil, attributes: nil)
                            let file = try FileHandle(forWritingTo: fileURL!)
                            file.write(pngImageData)
                            print("\(floor) Saved")
                        }
                    }
                        
                    catch {
                        
                    }
                    if floor == self.arrayOfFloorID.last {
                        DispatchQueue.main.async {
                            //self.activityIndicator.stopAnimating()
                            self.alert.dismiss(animated: false, completion: nil)
                        }
                    }
                }
            })
            //            queue.async {
            //
            //                if let createdImage = self.parserAndBuilder.createFloorMapForAsync(floorNumber: floor) {
            //                    print("\(floor) finish")
            //                    do {
            //                        if let pngImageData = UIImagePNGRepresentation(createdImage) {
            //
            //                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            //                            let fileURL = documentsURL.appendingPathComponent("\(self.buildingName)_\(floor).png")
            //                            try pngImageData.write(to: fileURL, options: .atomic)
            //                            print("\(floor) Saved")
            //                        }
            //                    }
            //
            //                    catch {
            //
            //                    }
            ////                    if floor == maxFloor {
            ////                        DispatchQueue.main.async {
            ////                            self.activityIndicator.stopAnimating()
            ////                        }
            ////                    }
            //                }
            
        }
    }

    func createArrayOfBeacons(){
        for floor in arrayOfFloorID {
            parserAndBuilder.jsonToBeaconArray(buildingName: buildingName, jsonName: floor)
        }
    }

}
