//
//  SetDetailsVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-05.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase

class SetDetailsVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var workplaceField: FancyField!
    @IBOutlet weak var usernameField: FancyField!
    @IBOutlet weak var cityBornField: FancyField!
    @IBOutlet weak var currentCityField: FancyField!
    @IBOutlet weak var profilePicAdd: CircleView!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        //boilerplate for imagepicker and textfield delegates
        usernameField.delegate = self
        cityBornField.delegate = self
        currentCityField.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        
    }
    // keyboard functionality
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // setting image to what was chosen in the image picker
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePicAdd.image = image
            imageSelected = true
        } else {
            print("Cody1: A valid image wasn't selected")
        }
        // dissmissing image picker
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    

    @IBAction func enterAppTapped(_ sender: AnyObject) {
        guard let username = usernameField.text, username != "" else {
            print("Cody!: Username must be entered")
            return
        }
        // grabbing photo out of the image
        guard let img = profilePicAdd.image, imageSelected == true else {
            print("Cody1: An image must be selected ")
            return
        }
        //compressing photo for storage
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            // setting a unique identifier
            let imgUid = NSUUID().uuidString
            // adding some metadata
            let metadata = FIRStorageMetadata()
            // setting metadata to jpeg
            metadata.contentType = "image/jpeg"
            // Updating the firebase storage folder "profile-pics" with the newly uploaded photo
            DataService.ds.REF_PROFILE_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("CODY!: Unable to upload image to firebase storage")
                } else {
                    print("Cody1: Successfully uploaded image to Firebase storage")
                    // now grabbing specific image url from firebase storage to pass to the firebase database
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        // passing this img url to the post to firebase database function so it can be stored with the specific user
                        self.postToFirebase(imgUrl: url)
                        
                    }
                }
            }
        }
       // opening app
     
    }
    
    func postToFirebase(imgUrl: String!) {
        // setting up how I will update that specific users child value
        let userInfo: Dictionary<String, Any> = [
            "username": usernameField.text!,
            "profile-pic": imgUrl,
            "city-born": cityBornField.text!,
            "current-city": currentCityField.text!,
            "workplace": workplaceField.text!
        ]
        // updating the database specific user with new information
        DataService.ds.REF_USER_CURRENT.updateChildValues(userInfo)
        performSegue(withIdentifier: "enterApp", sender: nil)
        //Reset all fields
        usernameField.text = ""
        cityBornField.text = ""
        currentCityField.text = ""
        imageSelected = false
        
        profilePicAdd.image = UIImage(named: "default-pic")
        
    }
    
  
   // when the profile pic icon is tapped, present the image picker 
    @IBAction func profilePicTapped(_ sender: AnyObject) {
        present(imagePicker,animated: true, completion: nil)
    }
  

}
