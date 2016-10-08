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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FancyField!
    
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        captionField.delegate = self 
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //user can edit photo before uploading
        imagePicker.allowsEditing = true
       
        // observing for any changes in the posts object in firebase
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            // need to clear out the posts array when the app is interacted with otherwise posts will be duplicated from redownloading 
            self.posts = []
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
    }
    
    
    //FOR KEYBOARD EDITING 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
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
    
    //IMAGE PICKER: once the image is selected, dissmiss the view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // what to do if it returns as edited image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("CODY1: A valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
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
    
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion:nil)
    }
    
    
    @IBAction func postBtnTapped(_ sender: AnyObject) {
        // if there is caption text and an image has been uploaded, then do the following
        guard let caption = captionField.text, caption != "" else {
            print("CODY1: Caption must be entered")
            return
        }
        
        guard let img = imageAdd.image, imageSelected == true else {
            print("CODY1: An image must be selected")
            return
        }
        
        //grabbing the users profile pic so it can be passed into the post to firebase method to be stored with that post
        var userProfilePic: String!
        // grabbing specific user and the profile pic child
            let profilePicRef = DataService.ds.REF_USER_CURRENT.child("profile-pic")
        // grabbing the value of that users profile pic
            profilePicRef.observeSingleEvent(of: .value, with: { (snapshot) in
                userProfilePic = snapshot.value as! String
            })
        
    
        // compressing the post image for Firebase storage
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            // setting a unique identifier
            let imgUid = NSUUID().uuidString
            // letting it know itll be a jpeg for safety
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            // Referencing Firebase storage child with the unique identifier, and updating with the image from the picker
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("CODY1: Unable to upload iamge to Firebase storage ")
                } else {
                    //
                    print("CODY1: Successfully uploaded image to Firebase storage ")
                    //GETT
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        //once the image is uploaded to firebase stoarge, its then posted to the database 
                        self.postToFirebase(imgUrl: url, profileUrl: userProfilePic)
                    }
                }
            }
        }
    }
    
    func postToFirebase(imgUrl: String!, profileUrl: String!) {
        let post: Dictionary<String, Any> = [
            "caption": captionField.text! as String,
            "imageUrl": imgUrl as String,
            "likes": 0 as Int,
            "userId": DataService.ds.REF_USER_CURRENT.key,
            "profilePicUrl": profileUrl
        ]
        // setting the value with whatever is passed into this function
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        let postsRef = DataService.ds.REF_USER_CURRENT.child("posts").child(firebasePost.key)
        postsRef.setValue(true)
        
        
        // resetting the inputs for the post
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named:"add-image")
        
        // reloading the tableview since new data has now been added to the Firebase Database
        tableView.reloadData()
    }
    
    
    @IBAction func profilePicTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "goToProfile", sender: nil)
    }
    

}
