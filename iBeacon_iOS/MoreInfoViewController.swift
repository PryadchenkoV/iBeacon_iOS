//
//  MoreInfoViewController.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 25.01.17.
//  Copyright © 2017 Ivan Pryadchenko. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MoreInfoViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lableAddress: UILabel!
    var buildingID = -1
    var buildingName = ""
    let parserAndBuilder = ParserAndBuilder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = buildingName
        lableAddress.text = parserAndBuilder.getBuildingAdress(nameOfBuilding: buildingName)
        let location = CLLocationCoordinate2D.init(latitude: 55.803529, longitude: 37.409817)
        mapView.addAnnotation(MKPlacemark(coordinate: location))
        mapView.setCenter(location, animated: true)
        let span = MKCoordinateSpanMake(0.020, 0.020)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        // Do any additional setup after loading the view.
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
