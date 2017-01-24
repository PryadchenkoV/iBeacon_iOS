//
//  DownloadedBuildingsViewController.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 23.01.17.
//  Copyright © 2017 Ivan Pryadchenko. All rights reserved.
//

import UIKit

let kDownloadedBuildingReuseableID = "downloadedBuildingReuseableID"
let kSegueFromDownloadedBuildingsToChooseFloor = "fromDownloadedBuildingsToChooseFloor"

class DownloadedBuildingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableDownloadedBuildings: UITableView!
    
    let parserAndBuilder = ParserAndBuilder()
    
    
    var bufDict = [String:String]()
    
    var numberOfRowSelected = -1
    var arrayOfDownloadedBuildings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableDownloadedBuildings.delegate = self
        tableDownloadedBuildings.dataSource = self
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tupleOfDownloadedBuilding.count
    }
    
    func createListDownloadedBuilings(){
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        let fileURL = documentsDirectoryPath.appendingPathComponent("AllBuildings")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: (fileURL?.absoluteString)!) {
            bufDict = parserAndBuilder.getListForDownloadedBuildings()
        }
        for (buildingNumber,buildingName) in bufDict {
            let buildingURL = documentsDirectoryPath.appendingPathComponent(buildingName)
            if fileManager.fileExists(atPath: (buildingURL?.absoluteString)!) && !tupleOfDownloadedBuilding.contains(where: { $0.0 == buildingNumber }){
                tupleOfDownloadedBuilding += [(buildingNumber,buildingName)]
            }
        }
        tupleOfDownloadedBuilding.sort{$0.0 < $1.0}
        //tableDownloadedBuildings.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kDownloadedBuildingReuseableID) as! BuildingFromServerTableViewCell
        cell.lableNameOfBuilding.text = tupleOfDownloadedBuilding[indexPath.row].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        numberOfRowSelected = indexPath.row
        performSegue(withIdentifier: kSegueFromDownloadedBuildingsToChooseFloor, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ChooseFloorViewController {
            destinationVC.buildingID = Int(tupleOfDownloadedBuilding[numberOfRowSelected].0)!
            destinationVC.buildingName = tupleOfDownloadedBuilding[numberOfRowSelected].1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        arrayOfFloors = [String]()
        createListDownloadedBuilings()
        tabBarController?.tabBar.items?[1].badgeValue = String(tupleOfDownloadedBuilding.count)
        tableDownloadedBuildings.reloadData()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
