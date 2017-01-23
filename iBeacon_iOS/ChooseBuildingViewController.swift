//
//  ChooseBuildingViewController.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 20.01.17.
//  Copyright © 2017 Ivan Pryadchenko. All rights reserved.
//

import UIKit

let kBuildingFromServerReuseableID = "buildingFromServerReuseableID"
let kSegueFromBuildingFromServerToChooseFloor = "fromBuildingFromServerToChooseFloor"

class ChooseBuildingViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableBuildingFormServer: UITableView!
    
    let parserAndBuilder = ParserAndBuilder()
    
    var buildingFromServerDict = [String: String]()
    var buildingIdToSend = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableBuildingFormServer.dataSource = self
        tableBuildingFormServer.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationGetBuildingReceive(notification:)),
                                               name: NSNotification.Name(rawValue: kNotificationServiceGetBuildingNames),
                                               object: nil)
        
        parserAndBuilder.getBuildingNames()
        
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildingFromServerDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kBuildingFromServerReuseableID) as! BuildingFromServerTableViewCell
        cell.lableNameOfBuilding.text = buildingFromServerDict[String(indexPath.row + 1)]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        buildingIdToSend = indexPath.row + 1
        performSegue(withIdentifier: kSegueFromBuildingFromServerToChooseFloor, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ChooseFloorViewController {
            destinationVC.buildingID = buildingIdToSend
            destinationVC.buildingName = buildingFromServerDict[String(buildingIdToSend)]!
        }
    }
    
    func notificationGetBuildingReceive(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: String] {
            buildingFromServerDict = userInfo
            DispatchQueue.main.async {
                self.tableBuildingFormServer.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
