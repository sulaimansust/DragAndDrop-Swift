//
//  ImageModel.swift
//  RnDProjectSortImage
//
//  Created by sulayman on 3/9/18.
//  Copyright © 2018 sulayman. All rights reserved.
//

import Foundation
import UIKit

struct LyricsImageModel {
    var imageName:String?
    var image:UIImage?
    var tintcolor:UIColor?
    
    init( imageName: String? ) {
        
        self.imageName = imageName
        if let name = imageName {
            if name.count > 0 {
                if let image = UIImage.init(named: name) {
                self.image = image
                self.tintcolor = image.getColors().primary
                    print("Color : \(self.tintcolor)")
                }
            }
        }
    }
}
