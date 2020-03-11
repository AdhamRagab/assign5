//
//  ImageViewController.swift
//  Assignment 5
//
//  Created by Adham Ragab on 3/1/20.
//  Copyright © 2020 Adham Ragab. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageView = UIImageView()
    
    var image : UIImage? {
           get {
               return imageView.image
           }set{
               imageView.image = newValue
               imageView.sizeToFit()
           }
       }
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.minimumZoomScale = 1/25
            scrollView.maximumZoomScale = 1.0
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        image?.draw(in: imageView.bounds)
        // Do any additional setup after loading the view.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
           return imageView
       }
    
}
