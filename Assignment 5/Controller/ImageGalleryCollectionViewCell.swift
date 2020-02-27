//
//  ImageGalleryCollectionViewCell.swift
//  Assignment 5
//
//  Created by Adham Ragab on 2/24/20.
//  Copyright © 2020 Adham Ragab. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    var image : UIImage?{
        get {
            return uiImage.image
        }
        set{
            uiImage.image = newValue
            uiImage.sizeToFit()
            
        }
    }
    
    @IBOutlet weak var uiImage: UIImageView!{
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    
}
