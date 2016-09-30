//
//  DataService.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-09-30.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import Foundation
import Firebase

//this will contain the url of our firebase database
let DB_BASE = FIRDatabase.database().reference()

class DataService {
    //Singleton
    static let ds = DataService()
    
    private var _REF_BASE = DB_BASE
    // grabbing the posts
    private var _REF_POSTS = DB_BASE.child("posts")
    // grabbing the users
    private var _REF_USERS = DB_BASE.child("users")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    func createFirebaseDbUser(uid: String, userData: Dictionary<String, String>) {
        // when creating a user, itll create uid, and update the child values with the userData we pass in 
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
}
