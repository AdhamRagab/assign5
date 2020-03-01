//
//  ImageGalleryCollectionViewCell.swift
//  Assignment 5
//
//  Created by Adham Ragab on 2/24/20.
//  Copyright © 2020 Adham Ragab. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    
    var url: URL?{
          didSet{
            self.fetchImage(withURL: url!.imageURL)
          }
      }

      private func fetchImage(withURL url: URL) {
          DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let data = try? Data(contentsOf: url) else {
                  return
              }

              guard let image = UIImage(data: data) else {
                  print("Couldn't convert data to UIImage")
                  print("The url is")
                print(url.imageURL)
                  return
              }

              // If by the time the async. fetch finishes, the imageURL is still the same, update the UI (in the main queue)
            if self?.url == url {
                  DispatchQueue.main.async {
                      self?.uiImage.image = image
                      
                  }
              }
          }
      }
    
//    var image : UIImage?{
//        get {
//            return uiImage.image
//        }
//        set{
//            uiImage.image = newValue-
//            uiImage.sizeToFit()
//
//        }
//    }
    
    @IBOutlet weak var uiImage: UIImageView!{
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    
}
