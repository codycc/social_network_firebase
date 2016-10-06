//
//  SetDetailsVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-05.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase

class SetDetailsVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameField: FancyField!

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func enterAppTapped(_ sender: AnyObject) {
        if let username = usernameField.text {
            let usernameData = [ "username": username]
            _ = DataService.ds.REF_USER_CURRENT.updateChildValues(usernameData)
            print("CODY1: DATA saved successfully ")
        }
        performSegue(withIdentifier: "enterApp", sender: nil)
    }
   

}
