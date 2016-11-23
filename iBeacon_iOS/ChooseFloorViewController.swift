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

class ChooseFloorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableViewFloor: UITableView!
    
    let arrayOfFloors = ["Floor1","Floor2","Floor3","Floor4","Floor5","Floor6","Floor7","Floor8","Floor9"]
    var chosenFloor = 0
    var chosenTitle = ""
    
    var parserAndBuilder = ParserAndBuilder()
    
    var arrayOfNextFloorImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for _ in 0..<arrayOfFloors.count {
            arrayOfNextFloorImages.append(UIImage(named: "level1")!)
        }
        
        loadMassiveOfFloors(minFloor: 0, maxFloor: 8)
        
        tableViewFloor.delegate = self
        tableViewFloor.dataSource = self
        
        
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
                destinantionController.floorTitle = chosenTitle
                destinantionController.arrayOfFloorImages = arrayOfNextFloorImages
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMassiveOfFloors(minFloor: Int, maxFloor: Int) {
        let queue = DispatchQueue(label: "com.miem.hse.iBeacon_test", qos: .background, attributes: .concurrent )
        for floor in minFloor...maxFloor {
            
            queue.sync {
                if let createdImage = parserAndBuilder.createFloorMapForAsync(floorNumber: floor) {
                    self.arrayOfNextFloorImages.remove(at: floor)
                    self.arrayOfNextFloorImages.insert(createdImage, at: floor)
                    print("\(floor) finish")
                }
            }
            if floor == maxFloor {
                dismiss(animated: false, completion: nil)
            }
        }
    }
    

}
