//
//  ImageGalleryModel.swift
//  Assignment 5
//
//  Created by Adham Ragab on 3/11/20.
//  Copyright © 2020 Adham Ragab. All rights reserved.
//

import UIKit

protocol updateUI {
    func updateUIInMainThread()
}

class ImageGalleryModel {
    
    var imageGalleries = [ImageGallery()]
    private var image : UIImage?
    
    func fetchImage(withURL url: URL ) -> UIImage? {
        
            guard let data = try? Data(contentsOf: url.imageURL) else {
                return nil
            }
            guard let image = UIImage(data: data) else {
                print("Couldn't convert data to UIImage")
                print("The url is")
                print(url.imageURL)
                return nil
            }
           
        return image
       
    }
    
    func add(gallery: ImageGallery) {
        imageGalleries.append(gallery)
    }
    
    func delete(gallery: ImageGallery , at index: Int) {
        imageGalleries.remove(at: index)
    }
    
    
    
    
    
}
