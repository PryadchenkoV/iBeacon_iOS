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

class ChooseFloorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableViewFloor: UITableView!
    
    let queue = DispatchQueue(label: "com.miem.hse.iBeacon_test")
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
    
    var chosenFloor = 0
    var chosenTitle = ""
    var buildingName = "Strogino"
    var parserAndBuilder = ParserAndBuilder()
    
    var arrayOfNextFloorImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arrayOfFloors = parserAndBuilder.getNameOfBuildings()
        
        for floor in 1...arrayOfFloors.count {
            arrayOfNextFloorImages.append(UIImage(named: "level\(floor)")!)
        }
        
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
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(buildingName)_\(0).png").path
        if !FileManager.default.fileExists(atPath: filePath) {
            createMassiveOfFloors(minFloor: 0, maxFloor: 8)
        }
        // Do any additional setup after loading the view.
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
                //destinantionController.arrayOfFloorImages = arrayOfNextFloorImages
                destinantionController.buildingName = buildingName
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createMassiveOfFloors(minFloor: Int, maxFloor: Int) {
        let refreshBarButton: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = refreshBarButton
        activityIndicator.startAnimating()
        for floor in minFloor...maxFloor {
            queue.async {
                if let createdImage = self.parserAndBuilder.createFloorMapForAsync(floorNumber: floor) {
                    print("\(floor) finish")
                    do {
                        if let pngImageData = UIImagePNGRepresentation(createdImage) {
                            
                            let documents
                            URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let fileURL = documentsURL.appendingPathComponent("\(self.buildingName)_\(floor).png")
                            try pngImageData.write(to: fileURL, options: .atomic)
                            print("\(floor) Saved")
                        }
                    }
                    catch {
                        
                    }
                    if floor == maxFloor {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
    }
    

}
