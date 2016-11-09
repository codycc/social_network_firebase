//
//  MainProfileVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-21.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

//
class MainProfileVC: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileImg2: UIImageView!
    @IBOutlet weak var workplaceLbl: UILabel!
    @IBOutlet weak var currentCityLbl: UILabel!
    @IBOutlet weak var cityBornLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var postsCountLbl: UILabel!
    @IBOutlet weak var followingCountLbl: UILabel!
    @IBOutlet weak var followersCountLbl: UILabel!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    let screenHeight = UIScreen.main.bounds.height
    let scrollViewContentHeight = 1350 as CGFloat
    let scrollViewContentWidth = UIScreen.main.bounds.width
    var posts = [Post]()
    var profilePicUrl: String = ""
    var coverPhotoUrl: String = ""
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: scrollViewContentWidth, height: scrollViewContentHeight)
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.delegate = self
        scrollView.isScrollEnabled = false
        scrollView.bounces = false
        tableView.bounces = false
        tableView.isScrollEnabled = false
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.setCurrentUser()
        self.checkAndAddPosts()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        self.postsCountLbl.text = "\(self.posts.count)"

        
         // only scroll down to full table if the user has a post
        if self.posts.count >= 1 {
            scrollView.isScrollEnabled = true
        }
    }
    
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        print("THIS IS Y OFFSET \(yOffset)")
        
        if scrollView == self.scrollView {
            if yOffset >= scrollViewContentHeight - screenHeight {
                print("this is screen height: \(screenHeight)")
                scrollView.isScrollEnabled = false
                tableView.isScrollEnabled = true
            }
        }
        
        if scrollView == self.tableView  {
            if yOffset <= 0   {
                self.scrollView.isScrollEnabled = true
                self.tableView.isScrollEnabled = false
            }
        }
    }
    
   
    
    func setCurrentUser() {
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                self.currentUser = User(userKey: key, userData: userDict)
                // setting profile images
                self.setProfile()
            }
        })
    }
    
    func setProfile() {
        let url = URL(string: self.currentUser.profilePicUrl)
        self.profileImg.kf.setImage(with: url)
        self.profileImg2.kf.setImage(with: url)
        self.usernameLbl.text = self.currentUser.username
        self.cityBornLbl.text = self.currentUser.cityBorn
        self.currentCityLbl.text = self.currentUser.currentCity
        self.workplaceLbl.text = self.currentUser.workplace
        self.postsCountLbl.text = "\(self.posts.count)"
        self.followersCountLbl.text = "\(self.currentUser.followerCount)"
        self.followingCountLbl.text = "\(self.currentUser.followingCount)"
        
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("coverPhotoUrl") {
                let url = URL(string: self.currentUser.coverPhotoUrl)
                if url != nil {
                    self.coverImage.kf.setImage(with: url)
                } else {
                    print("unable to download and cache image with Kingfisher")
                }
                
            } else {
                print("Cody1: User hasnt added dynamic cover photo")
                
            }
            
        })
        
    }
    
    func checkAndAddPosts() {
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("posts") {
                DataService.ds.REF_USER_CURRENT.child("posts").observe(.value, with: { (snapshot) in
                    // need to clear out the posts array when the app is interacted with otherwise posts will be duplicated from redownloading
                    self.posts = []
                    // snapshot will now grab all objects
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        
                        // for every post object ie "kldjfkjdls" : "true"
                        for snap in snapshot {
                            print("SNAP: \(snap)")
                            // grab the key of that post and search for it in your posts database
                            let post = DataService.ds.REF_POSTS.child(snap.key)
                            print("THE POST NOW:\(post)")
                            // now grab the snapshot of that specific post
                            post.observeSingleEvent(of: .value, with: { (snapshot) in
                                // set it up as a dictionary with string and any object
                                if let postValue = snapshot.value as? Dictionary <String, AnyObject> {
                                    print("POST VALUE:\(postValue)")
                                    // the key will be the key of that post
                                    let key = snapshot.key
                                    // create a post instance with the new data
                                    let post = Post(postKey: key, postData: postValue)
                                    // add that post into the array
                                    self.posts.append(post)
                                    print("HERE IS THE THING IN ARRAY:\(post.caption)")
                                }
                            })
                        }
                        self.refreshUI()
                    }
                })
            } else {
                print("user doesnt have any posts")
            }
        })
    }
    
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as? ProfileCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                print("THIS IS THE POST FROM CELL:\(post)")
                cell.configureCell(post: post, img: img)
            } else {
                cell.configureCell(post: post)
                
            }
            return cell
        } else {
            return ProfileCell()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            coverImage.image = image
            imageSelected = true
            // take image from uipicker and pass to post to firebase storage function
            postToFirebaseStorage(image: image)
        } else {
            print("Cody1: A valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func refreshUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("CALLING THE A SYNC METHOD")
        }
    }
    
    
    // taking cover image from the imagePickerController function, and posting it to firebase storage
    func postToFirebaseStorage(image: UIImage) {
        if let imgData = UIImageJPEGRepresentation(image, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            DataService.ds.REF_COVER_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("CODY1: Unable to uplaod image to firebase storage")
                } else {
                    print("CODY1: Successfully uploaded image to Firebase Storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                     if let url = downloadUrl {
                        // taking the image url, and passing it to the postToFirebaseDatabase function to be stored with the specific user
                        self.postToFirebaseDatabase(imgUrl: url)
                    }
                }
            }
        }
    }
    
    func postToFirebaseDatabase(imgUrl: String!) {
        let userInfo: Dictionary<String, Any> = [
            "coverPhotoUrl": imgUrl
        ]
        DataService.ds.REF_USER_CURRENT.updateChildValues(userInfo)
        imageSelected = false
        
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func statusBtnPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "goToStatusVC2", sender: nil)
    }
    @IBAction func editCoverPressed(_ sender: AnyObject) {
        present(imagePicker,animated: true, completion: nil)
    }
    @IBAction func editProfileTapped(_ sender: Any) {
        
    }
   
}
