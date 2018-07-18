//
//  Cell.swift
//  RnDProjectSortImage
//
//  Created by sulayman on 17/7/18.
//  Copyright © 2018 sulayman. All rights reserved.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var lyricsText: UITextView!
    @IBOutlet weak var dividerPlaceHolder: UIView!
    
    @IBOutlet weak var imageContainerView: UIView!
    
    @IBOutlet weak var contentImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        self.layoutSubviews()
    }
    
    
}
