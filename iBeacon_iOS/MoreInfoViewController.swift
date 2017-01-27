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
        
        lableAddress.text = parserAndBuilder.getBuildingAdress(nameOfBuilding: buildingName)
        
        let address = lableAddress.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
            }
        })
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
