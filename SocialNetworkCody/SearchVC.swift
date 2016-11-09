//
//  SearchVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-25.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    var searchTerm: String!

    static var imageCache: NSCache<NSString, UIImage> = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.searchAndParseUsers()
        
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOtherUserVC" {
            if let otherUserVC = segue.destination as? OtherUserVC  {
                if let user = sender as? User {
                    otherUserVC.user = user
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        performSegue(withIdentifier: "goToOtherUserVC", sender: user)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell {
            if let img = SearchVC.imageCache.object(forKey: user.profilePicUrl as NSString) {
                cell.configureCell(user: user, img: img)
                
            } else {
                cell.configureCell(user: user)
            }
            return cell
        } else {
            return UserCell()
        }
        
    }
    
    func searchAndParseUsers() {
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            self.users = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                // for ever user in user
                for snap in snapshot {
                    let usernameRef = snap.childSnapshot(forPath: "username")
                    let username = usernameRef.value as! String
                    let lowercaseUsername = username.lowercased()
                    if lowercaseUsername == self.searchTerm!.lowercased() {
                        if let userDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let user = User(userKey: key, userData: userDict)
                            self.users.append(user)
                        } else {
                            print("couldnt add to dictionary")
                        }
                        self.tableView.reloadData()
                    } else {
                        print("doesnt match search term")
                    }
                }
            }
        })
    }
    
 
    @IBAction func arrowBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        

    }
    
}
