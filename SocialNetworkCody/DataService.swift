//
//  DataService.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-09-30.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

//this will contain the url of our firebase database
let DB_BASE = FIRDatabase.database().reference()

// this will contain the url of our firebase storage
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    //Singleton
    static let ds = DataService()
    
    //Storage references 
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    private var _REF_PROFILE_IMAGES = STORAGE_BASE.child("profile-pics")
    private var _REF_COVER_IMAGES = STORAGE_BASE.child("cover-pics")
    
    //DB references
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_COMMENTS = DB_BASE.child("comments")
    
    
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user 
    }
    
    var REF_COMMENTS: FIRDatabaseReference {
        return _REF_COMMENTS
    }
    
    
    var REF_POST_IMAGES: FIRStorageReference {
        return _REF_POST_IMAGES
    }
    
    var REF_PROFILE_IMAGES: FIRStorageReference {
        return _REF_PROFILE_IMAGES
    }
    
    var REF_COVER_IMAGES: FIRStorageReference {
        return _REF_COVER_IMAGES
    }
    
    
    
    
    
    
    
    func createFirebaseDbUser(uid: String, userData: Dictionary<String, Any>) {
        // when creating a user, itll create uid, and update the child values with the userData we pass in 
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
}
