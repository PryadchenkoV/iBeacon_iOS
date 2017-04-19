//
//  LoginViewController.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 18.04.17.
//  Copyright © 2017 Ivan Pryadchenko. All rights reserved.
//

import UIKit

let kSegueFromLoginToBuildings = "fromLoginToBuildings"

class LoginViewController: UIViewController {

    @IBOutlet weak var buttonRegister: UIButton!
    @IBOutlet weak var buttonLogin: UIButton!
    
    @IBOutlet weak var textFieldLogin: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func buttonPushed(_ sender: UIButton) {
        if sender == buttonLogin{
            if !(textFieldLogin.text?.isEmpty)! && !(textFieldPassword.text?.isEmpty)! {
                performSegue(withIdentifier: kSegueFromLoginToBuildings, sender: self)
            } else {
                let alert = UIAlertController(title: "Error", message: "Login or Password is Empty", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
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
