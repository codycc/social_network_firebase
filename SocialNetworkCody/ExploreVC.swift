//
//  ExploreVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-11-02.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase

class ExploreVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self 
        self.collectUsers()
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.item]
        performSegue(withIdentifier: "goToOtherUserFromExploreVC", sender: user)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let user = users[indexPath.item]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreCell", for: indexPath) as? ExploreCell {
            
            cell.configureCell(user: user)
            return cell
        } else {
            return UICollectionViewCell()
        }
        
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOtherUserFromExploreVC" {
            if let otherUserVC = segue.destination as? OtherUserVC  {
                if let user = sender as? User {
                    otherUserVC.user = user
                }
            }
        }
    }
    
    
    func collectUsers() {
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            self.users = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("snap \(snap)")
                    if let userDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let user = User(userKey: key, userData: userDict)
                        self.users.append(user)
                    } else {
                        print("could not add user")
                    }
                }
                self.collectionView.reloadData()
            }
        })
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
 

}
