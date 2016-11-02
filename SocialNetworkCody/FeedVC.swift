//
//  FeedVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-09-29.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import Kingfisher


class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePic: CircleView!
    @IBOutlet weak var statusProfilePic: UIImageView!
    @IBOutlet weak var signOutImage: UIImageView!
    @IBOutlet weak var showcaseArrow: UIImageView!
    @IBOutlet weak var showcaseView: FancyView!
    @IBOutlet weak var showcaseLbl: UILabel!
    @IBOutlet weak var exploreIcon: UIImageView!

    @IBOutlet weak var feedLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        self.addPosts()
        self.setCurrentUser()
        
                
        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("CALLING THE A SYNC METHOD")
        }
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.checkNumberOfPosts()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var post: Post!
        post = posts[indexPath.row]
        print("DID SELECT ROW AT CALLED")
        performSegue(withIdentifier: "goToPost", sender: post)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // grabbing each post out of the posts array
        let post = posts[indexPath.row]
        // setting up each cell and calling configureCell which will update the UI with firebase data
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            // let img equal to the imageCache with this specifiv post url
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                if let profileImg = FeedVC.imageCache.object(forKey: post.profilePicUrl as NSString) {
                    cell.configureCell(post: post, img: img, profileImage: profileImg)
                }
                // pass that into the configure cell with the post itself
            } else {
                cell.configureCell(post: post)
            }
             return cell
        } else {
            return PostCell()
        }
    }
    
    func loadList(notification: NSNotification){
        //load data here
        self.tableView.reloadData()
    }
    
    // sorting through the array, and comparing posted date then reloading data
    func sortList() {
        posts.sort(by: { $0.date.compare($1.date) == ComparisonResult.orderedDescending })
        tableView.reloadData(); // notify the table view the data has changed
    }
    
    func setCurrentUser() {
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                self.currentUser = User(userKey: key, userData: userDict)
                // setting profile images
                self.setprofileImages()
            }
        })
    }
    
    
    
    func addPosts() {
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            // need to clear out the posts array when the app is interacted with otherwise posts will be duplicated from redownloading
            self.posts = []
            // going through every snapshot
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                //for every snap in the snapshot
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    // for every post, if the post's user Id matches with one the user Id's in the current users following list, then add that post to the array
                    let userId = snap.childSnapshot(forPath: "userId")
                    let userIdValue = userId.value as! String
                    // setting the value of each snap as a postDict
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        //setting constants of key and post
                        let key = snap.key
                         _ = DataService.ds.REF_USER_CURRENT.child("following").observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.hasChild(userIdValue) {
                                let post = Post(postKey: key, postData: postDict)
                                //adding each post to the posts array
                                self.posts.append(post)
                                self.sortList()
                                print("called sort list!!")
                            } else {
                                print("this post isnt for this user")
                            }
                          })
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func checkNumberOfPosts() {
        print("there are this many posts!!! \(self.posts.count)")
        if self.posts.count >= 1 {
            showcaseLbl.isHidden = true
            showcaseArrow.isHidden = true
            showcaseView.isHidden = true
        } else {
            showcaseLbl.isHidden = false
            showcaseArrow.isHidden = false
            showcaseView.isHidden = false
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPost" {
            if let postVC = segue.destination as? PostVC  {
                if let post = sender as? Post {
                    postVC.post = post
                }
            }
        }
        
        if segue.identifier == "goToSearchVC" {
            if let searchVC = segue.destination as? SearchVC {
                if let searchTerm = sender as? String {
                    searchVC.searchTerm = searchTerm
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == nil || searchBar.text == "" {
            
            //make keyboard go away
            view.endEditing(true)
        } else {
             let lower = searchBar.text!.lowercased()
            performSegue(withIdentifier: "goToSearchVC", sender: lower)
        }
        searchBar.text = ""
        searchBar.text = ""
        searchBar.isHidden = true
        profilePic.isHidden = false
        signOutImage.isHidden = false
        feedLbl.isHidden = false
        exploreIcon.isHidden = false
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.text = ""
        searchBar.isHidden = true
        profilePic.isHidden = false
        signOutImage.isHidden = false
        feedLbl.isHidden = false
        exploreIcon.isHidden = false
    }
    
    func setprofileImages() {
        let url = URL(string: self.currentUser.profilePicUrl)
        self.profilePic.kf.setImage(with: url)
        self.statusProfilePic.kf.setImage(with: url)
    }
    
    @IBAction func signOutTapped(_ sender: AnyObject) {
        // When signing out ... remove keychain ID
        let removeKeychain: Bool = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("CODY1: ID removed from keychain \(removeKeychain)")
        //Signout from firebase
        try! FIRAuth.auth()?.signOut()
        //Dissmiss all open view controllers above the log in screen (root controller)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func profilePicTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "goToMainProfile", sender: nil)
    }
    
    
    @IBAction func magGlassTapped(_ sender: AnyObject) {
        searchBar.isHidden = false
        profilePic.isHidden = true
        signOutImage.isHidden = true
        feedLbl.isHidden = true
        exploreIcon.isHidden = true
        
        searchBar.becomeFirstResponder()
    }
    @IBAction func globeTapped(_ sender: Any) {
        print("icon tapped")
    }
    
    @IBAction func statusFieldTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "goToStatus", sender: nil)
    }
}
