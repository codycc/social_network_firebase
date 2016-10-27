//
//  StatusVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-19.
//  Copyright © 2016 Cody Condon. All rights reserved.
//


import UIKit
import Firebase
import FirebaseStorage
import Kingfisher

class StatusVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate{

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var textViewField: UITextView!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        textViewField.delegate = self
        imagePicker.allowsEditing = true
        textViewField.isEditable = true

        self.setCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let url = URL(string: self.currentUser.profilePicUrl)
        if url != nil {
            profileImage.kf.setImage(with: url)
        } else {
            print("unable to download and cache image using Kingfisher")
        }
        self.usernameLbl.text = "\(self.currentUser.username)"
    }
    
    func setCurrentUser() {
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                //setting constants of key and post
                let key = snapshot.key
                self.currentUser = User(userKey: key, userData: userDict)
                //adding each post to the posts array
            }
        })
    }
    
  
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // what to do if it returns as edited image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
            imageSelected = true
        } else {
            print("CODY1: A valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: AnyObject) {
        //close keyboard
        self.view.endEditing(true)
        // if there is caption text and an image has been uploaded, then do the following
        guard let caption = textViewField.text, caption != "" else {
            print("CODY1: Caption must be entered")
            return
        }
        
        guard let img = addImage.image, imageSelected == true else {
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
            "caption": textViewField.text! as String,
            "imageUrl": imgUrl as String,
            "likes": 0 as Int,
            "userId": DataService.ds.REF_USER_CURRENT.key,
            "profilePicUrl": profileUrl
        ]
        // setting the value with whatever is passed into this function
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        // adding True to the current user section posts to say this is that users post in the database
        let postsRef = DataService.ds.REF_USER_CURRENT.child("posts").child(firebasePost.key)
        postsRef.setValue(true)
        
        
        // resetting the inputs for the post
        textViewField.text = ""
        imageSelected = false
        addImage.image = UIImage(named:"add-image")
        self.dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textViewField.resignFirstResponder()
        
            return false
        }
        else {
            return true
        }
    }
    
    
    @IBAction func addPhotoTapped(_ sender: AnyObject) {
         present(imagePicker, animated: true, completion:nil)
    }
    
    @IBAction func addPhotoTapped2(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion:nil)
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
  
    @IBAction func textViewFieldTapped(_ sender: AnyObject) {
       textViewField.text = ""
        // makes text cursor start blinking
        textViewField.becomeFirstResponder()
    }
    
    

}
