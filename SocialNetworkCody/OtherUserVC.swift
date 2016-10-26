//
//  otherUserVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-25.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase

class OtherUserVC: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImg: UIImageView!

    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var postsCountLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    let screenHeight = UIScreen.main.bounds.height
    let scrollViewContentHeight = 1350 as CGFloat
    let scrollViewContentWidth = UIScreen.main.bounds.width
    var posts = [Post]()
    var profilePicUrl: String = ""
    var coverPhotoUrl: String = ""
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    var user: User!
    var currentUser: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollViewContentWidth, height: scrollViewContentHeight)
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.delegate = self
        scrollView.bounces = false
        tableView.bounces = false
        tableView.isScrollEnabled = false
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        usernameLbl.text = user.username
        print("here is user key\(user.userKey)")
        
        DataService.ds.REF_USERS.child(user.userKey).observeSingleEvent(of: .value, with: { (snapshot) in
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
                        
                    }
                    
                })
                
            } else {
                print("user doesnt have any posts")
                
            }
            
        })
        // downloading profile pic from firebase
        downloadProfilePic()
        
        // if the user has uploaded a coverphoto, then go and download it.
        DataService.ds.REF_USERS.child(user.userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("coverPhotoUrl") {
                
                self.downloadCoverPic()
            } else {
                print("Cody1: User hasnt added dynamic cover photo")
                
            }
        })
        
        
        
        // storing the information of the current user so it can be set later times
       DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
        if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
            //setting constants of key and post
            let key = snapshot.key
            self.currentUser = User(userKey: key, userData: userDict)
            //adding each post to the posts array
        }
       })
        
        
        // checking if the current user already follows this user, if so, then update the follow button accordingly
         let _ = DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("following") {
//                let snap = snapshot.value(forKey: "followers")
                let snap = snapshot.childSnapshot(forPath: "following")
                if snap.hasChild(self.user.userKey) {
                    self.followBtn.setTitle("Unfollow", for: .normal)
                    self.followBtn.backgroundColor = UIColor.white
                    self.followBtn.setTitleColor(UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0), for: .normal)
                    
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        // caching user profile pic
        cacheProfilePic()
        
        // if the current user has a cover photo, then go and cache it
        DataService.ds.REF_USERS.child(user.userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("coverPhotoUrl") {
                // if the user has uploaded a coverphoto, then go and download it.
                self.cacheCoverPic()
            } else {
                print("Cody1: User hasnt added dynamic cover photo")
                
            }
        })
        
        // only scroll down to full table if the user has a post
        if self.posts.count >= 1 {
            scrollView.isScrollEnabled = true
        }
        
        // setting the posts label after it counts and pops the posts into the array
        self.postsCountLbl.text = "\(self.posts.count)"
        
        
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
        
        if scrollView == self.tableView {
            if yOffset <= 0   {
                self.scrollView.isScrollEnabled = true
                self.tableView.isScrollEnabled = false
            }
        }
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
    
    func downloadProfilePic() {
        DataService.ds.REF_USERS.child(user.userKey).child("profile-pic").observeSingleEvent(of: .value,with: { (snapshot) in
            self.profilePicUrl = (snapshot.value as? String)!
        })
    }
    
    func downloadCoverPic() {
        DataService.ds.REF_USERS.child(user.userKey).child("coverPhotoUrl").observeSingleEvent(of: .value, with: { (snapshot) in
            self.coverPhotoUrl = (snapshot.value as? String)!
        })
    }
    
    
    
    func cacheProfilePic() {
        // putting this here because I need to grab the users profile pic before caching it
        let profile = FeedVC.imageCache.object(forKey: profilePicUrl as NSString)
        
        if profile != nil {
            self.profileImg.image = profile
           
        } else {
            // otherwise create the image from firebase storage
            let ref = FIRStorage.storage().reference(forURL: profilePicUrl)
            // max size aloud
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CODY!: Unable to download image Firebase storage")
                } else {
                    print("CODY!: Image downloaded from firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profileImg.image = img
                           
                            // setting the cache now
                            FeedVC.imageCache.setObject(img, forKey: self.profilePicUrl as NSString)
                        }
                    }
                }
            })
        }
    }
    
    func cacheCoverPic() {
        // putting this here because I need to grab the users profile pic before caching it
        let cover = MainProfileVC.imageCache.object(forKey: coverPhotoUrl as NSString)
        
        if cover != nil {
            self.coverImage.image = cover
        } else {
            // otherwise create the image from firebase storage
            let ref = FIRStorage.storage().reference(forURL: coverPhotoUrl)
            // max size aloud
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CODY!: Unable to download image Firebase storage")
                } else {
                    print("CODY!: Image downloaded from firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.coverImage.image = img
                            // setting the cache now
                            MainProfileVC.imageCache.setObject(img, forKey: self.profilePicUrl as NSString)
                        }
                    }
                }
            })
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
        DataService.ds.REF_USERS.child(user.userKey).updateChildValues(userInfo)
        imageSelected = false
        
    }
    
    
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func editCoverPressed(_ sender: AnyObject) {
        present(imagePicker,animated: true, completion: nil)
    }
   
    @IBAction func followBtnPressed(_ sender: Any) {
        //grabbing the current user and setting their child following to this users key
        let followingRef = DataService.ds.REF_USER_CURRENT.child("following").child(user.userKey)
        // grabbing the users key and setting followers child to the current user
        let refCurrentUserKey = DataService.ds.REF_USER_CURRENT.key
        let followersRef = DataService.ds.REF_USERS.child(user.userKey).child("followers").child(refCurrentUserKey)
     
        
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.currentUser.adjustFollowingCount(addFollowingCount: true)
                self.user.adjustFollowersCount(addFollowerCount: true)
                followingRef.setValue(true)
                followersRef.setValue(true)
                //display
                self.followBtn.setTitle("Unfollow", for: .normal)
                self.followBtn.backgroundColor = UIColor.white
                self.followBtn.setTitleColor(UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0), for: .normal)
                
             
            } else {
                self.currentUser.adjustFollowingCount(addFollowingCount: false)
                self.user.adjustFollowersCount(addFollowerCount: false)
                followingRef.removeValue()
                followersRef.removeValue()
                //display
                self.followBtn.setTitle("Follow", for: .normal)
                self.followBtn.backgroundColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                self.followBtn.setTitleColor(UIColor.white, for: .normal)
            }
        })
        

       
    }
    
}

