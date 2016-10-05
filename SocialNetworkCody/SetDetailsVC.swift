//
//  SetDetailsVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-05.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit

class SetDetailsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func enterAppTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "enterApp", sender: nil)
    }
   

}
