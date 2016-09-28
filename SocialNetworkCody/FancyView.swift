//
//  FancyView.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-09-28.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit

class FancyView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Color
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6 ).cgColor
        // Opacity
        layer.shadowOpacity = 0.8
        // How far is spreads / blurs out
        layer.shadowRadius = 5.0
        // 1 down, 1 up
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
    }

}
