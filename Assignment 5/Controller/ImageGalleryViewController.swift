//
//  ImageGalleryViewController.swift
//  Assignment 5
//
//  Created by Adham Ragab on 2/24/20.
//  Copyright © 2020 Adham Ragab. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController , UIDropInteractionDelegate, UIScrollViewDelegate , UICollectionViewDelegate , UICollectionViewDataSource {
    
    
    
    
    var imageGalleryView = ImageGalleryView()
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(imageGalleryView)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // The view we want to scale
        return imageGalleryView
    }
    
    //
    // Tells the delegate that the scroll view’s zoom factor changed.
    //
    //        func scrollViewDidZoom(_ scrollView: UIScrollView) {
    //            scrollViewHeight.constant = scrollView.contentSize.height
    //            scrollViewWidth.constant = scrollView.contentSize.width
    //        }
    
    var imageGalleryBackgroundImage: UIImage? {
        get {
            // Image is stored in emojiArtView
            return imageGalleryView.backgroundImage
        }
        set {
            // Reset zoomScale
            scrollView?.zoomScale = 1.0
            
            // Setup background image
            imageGalleryView.backgroundImage = newValue
            
            // Setup appropriate size
            let size = newValue?.size ?? CGSize.zero
            
            // Frame starting at CGPoint.zero
            imageGalleryView.frame = CGRect(origin: CGPoint.zero, size: size)
            
            // Setup scrolling size
            scrollView?.contentSize = size
            
            // Setup constraints of scrollView to properly fit the image's size
            scrollViewHeight?.constant = size.height
            scrollViewWidth?.constant = size.width
            
            // If appropriate, setup zoomScale
            if let dropZone = self.dropZone, size.width > 0, size.height > 0 {
                scrollView?.zoomScale = max(
                    dropZone.bounds.size.width / size.width,
                    dropZone.bounds.size.height / size.height
                )
            }
        }
    }
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var dropZone: UIView!{
        didSet{
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) &&
            session.canLoadObjects(ofClass: NSURL.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    var imageFetcher: ImageFetcher!
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        
        imageFetcher = ImageFetcher() { (url,image) in
            DispatchQueue.main.async{self.imageGalleryBackgroundImage = image}
        }
        
        session.loadObjects(ofClass: NSURL.self) { (nsurls) in
            if let url = nsurls.first as? URL {
                self.imageFetcher.fetch(url)
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { (images) in
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        }
        
        
        
    }
    
    
    
    @IBOutlet weak var imageGalleryCollectionView: UICollectionView!{
        didSet{
            imageGalleryCollectionView.delegate = self
            imageGalleryCollectionView.dataSource = self
            
        }
    }
    
    var images = ["oval","mars","moon","horizon","lake","sat"]
    var imageURL : URL?
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        
        if let imageCell = cell as? ImageGalleryCollectionViewCell{
            
            imageURL = Bundle.main.url(forResource: images[indexPath.item], withExtension: "jpg")
            if let url = imageURL {
                DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
                    let urlContent = try? Data(contentsOf: url)
                    DispatchQueue.main.async {
                        if let imageData = urlContent , url == self?.imageURL {
                            imageCell.uiImage.image = UIImage(data: imageData)
                            collectionView.reloadData()
                        }
                    }
                    
                }
            }
            
        }
        return cell
        
    }
    
    
    
}
