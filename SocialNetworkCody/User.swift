//
//  User.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-25.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import Foundation
import Firebase

class User {
    private var _username: String!
    private var _provider: String!
    private var _profilePicUrl: String!
    private var _coverPhotoUrl: String!
    private var _userKey: String!
    private var _userRef: FIRDatabaseReference!
    
    var username: String {
        return _username
    }
    
    var provider: String {
        return _provider
    }
    
    var profilePicUrl: String {
        return _profilePicUrl
    }
    
    var coverPhotoUrl: String {
        return _coverPhotoUrl
    }
    
    var userKey: String {
        return _userKey
    }
    
    init(username: String, provider: String, profilePicUrl: String, coverPhotoUrl: String) {
        self._username = username
        self._provider = provider
        self._profilePicUrl = profilePicUrl
        self._coverPhotoUrl = coverPhotoUrl
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>) {
        self._userKey = userKey
        
        if let username = userData["username"] as? String {
            self._username = username
        }
        
        if let provider = userData["provider"] as? String {
            self._provider = provider
        }
        
        if let profilePicUrl = userData["profile-pic"] as? String {
            self._profilePicUrl = profilePicUrl
        }
        
        if let coverPhotoUrl = userData["coverPhotoUrl"] as? String {
            self._coverPhotoUrl = coverPhotoUrl
        }
        
        _userRef = DataService.ds.REF_USERS.child(_userKey)
    }
    
}
