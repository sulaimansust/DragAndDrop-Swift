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
    
    @IBOutlet weak var lyricsTextViewContainer: UIView!
    @IBOutlet weak var lyricsTextView: UITextView!
    
    @IBOutlet weak var dividerCircle: UIImageView!
    @IBOutlet weak var dividerLine: UIImageView!
    
    @IBOutlet weak var imageContainerView: UIView!
    
    @IBOutlet weak var imageContainerFrameWithShadow: UIImageView!
    @IBOutlet weak var imageContainerFrame: UIImageView!
    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var badgeCircle: UIImageView!
    @IBOutlet weak var badgeCountLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        self.layoutSubviews()
    }
    
    
}
