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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //user can edit photo before uploading
        imagePicker.allowsEditing = true
       
        // observing for any changes in the posts object in firebase
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            // going through every snapshot
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                //for every snap in the snapshot
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    // setting the value of each snap as a postDict
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        //setting constants of key and post
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        //adding each post to the posts array 
                        self.posts.append(post)
                    }
                }
                self.tableView.reloadData()
            }
        })
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // grabbing each post out of the posts array
        let post = posts[indexPath.row]
        
        // setting up each cell and calling configureCell which will update the UI with firebase data
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            cell.configureCell(post: post)
            return cell
        } else {
            return PostCell()
        }
    }
    
    //IMAGE PICKER: once the image is selected, dissmiss the view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // what to do if it returns as edited image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
        } else {
            print("CODY1: A valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func signOutTapped(_ sender: AnyObject) {
        // When signing out ... remove keychain ID
        let keychainResult2 = KeychainWrapper.defaultKeychainWrapper().removeObjectForKey(KEY_UID)
        print("CODY1: ID removed from keychain \(keychainResult2)")
        //Signout from firebase
        try! FIRAuth.auth()?.signOut()
        // Go back to login screen
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion:nil)
    }

}
