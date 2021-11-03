//
//  MyCollectionViewCell.swift
//  Gomoku: Five In A Row
//
//  Created by Josh Kelleran on 5/27/19.
//  Copyright © 2019 Josh Kelleran. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell
{
    
    @IBOutlet weak var myLabel: UILabel!
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.width = ceil(size.width)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
}
