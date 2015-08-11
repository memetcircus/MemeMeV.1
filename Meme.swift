//
//  Meme.swift
//  MemeMe
//
//  Created by Mehmet Akif Acar on 07/08/15.
//  Copyright (c) 2015 Memetcircus. All rights reserved.
//

import Foundation
import UIKit

struct Meme{
    
    let bottomText: String
    let topText: String
    let orgImage: UIImage
    let memedImage: UIImage
    
    init(bottomText: String, topText: String, orgImage: UIImage, memedImage: UIImage){
        self.bottomText = bottomText
        self.topText = topText
        self.orgImage = orgImage
        self.memedImage = memedImage
    }
}
