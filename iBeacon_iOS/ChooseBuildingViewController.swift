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

var tupleOfDownloadedBuilding = [(String,String)]()

class ChooseBuildingViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableBuildingFormServer: UITableView!
    var refreshControl: UIRefreshControl!
    
    let parserAndBuilder = ParserAndBuilder()
    let downloadView = DownloadedBuildingsViewController()
    
    var buildingFromServerDict = [String: String]()
    var buildingIdToSend = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableBuildingFormServer.dataSource = self
        tableBuildingFormServer.delegate = self
        self.title = "Buildings From Server"
        parserAndBuilder.getBuildingNames()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refreshAction), for: UIControlEvents.valueChanged)
        tableBuildingFormServer.addSubview(refreshControl)
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        arrayOfFloors = [String]()
        DispatchQueue.main.async {
            self.downloadView.createListDownloadedBuilings()
            self.tabBarController?.tabBar.items?[1].badgeValue = String(tupleOfDownloadedBuilding.count)
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationGetBuildingReceive(notification:)),
                                               name: NSNotification.Name(rawValue: kNotificationServiceGetBuildingNames),
                                               object: nil)
    }
    
    func refreshAction(sender:AnyObject) {
        parserAndBuilder.getBuildingNames()
        Timer.scheduledTimer(timeInterval: 10,
                             target: self,
                             selector: #selector(self.endRefreshing),
                             userInfo: nil,
                             repeats: false)
    }
    
    func endRefreshing(){
        refreshControl.endRefreshing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
        tableView.deselectRow(at: indexPath, animated: true)
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
        refreshControl.endRefreshing()
        if let userInfo = notification.userInfo as? [String: String] {
            buildingFromServerDict = userInfo
            DispatchQueue.main.async {
                self.tableBuildingFormServer.reloadData()
                self.downloadView.createListDownloadedBuilings()
                self.tabBarController?.tabBar.items?[1].badgeValue = String(tupleOfDownloadedBuilding.count)
            }
        }

    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        arrayOfFloors = [String]()
//        DispatchQueue.main.async {
//            self.downloadView.createListDownloadedBuilings()
//            self.tabBarController?.tabBar.items?[1].badgeValue = String(tupleOfDownloadedBuilding.count)
//        }
//    }

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
