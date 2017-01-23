//
//  DownloadedBuildingsViewController.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 23.01.17.
//  Copyright © 2017 Ivan Pryadchenko. All rights reserved.
//

import UIKit

let kDownloadedBuildingReuseableID = "downloadedBuildingReuseableID"

class DownloadedBuildingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableDownloadedBuildings: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableDownloadedBuildings.delegate = self
        tableDownloadedBuildings.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kDownloadedBuildingReuseableID) as! BuildingFromServerTableViewCell
        return cell
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
