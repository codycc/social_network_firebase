//
//  BorderView.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-21.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit

class BorderView: UIImageView {

    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        
    }


}
