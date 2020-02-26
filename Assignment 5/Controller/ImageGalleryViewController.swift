//
//  ImageGalleryViewController.swift
//  Assignment 5
//
//  Created by Adham Ragab on 2/24/20.
//  Copyright © 2020 Adham Ragab. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController , UIDropInteractionDelegate, UIScrollViewDelegate , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
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
    //MARK: - Drop Zone
    
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
    
    //MARK: - CollectionView
    
    @IBOutlet weak var imageGalleryCollectionView: UICollectionView!{
        didSet{
            imageGalleryCollectionView.delegate = self
            imageGalleryCollectionView.dataSource = self
            imageGalleryCollectionView.dragDelegate = self
            imageGalleryCollectionView.dropDelegate = self
        }
    }
    var imageURL : URL?
    var DictionaryKey = String() {
        didSet{
            if let dictcount = images[DictionaryKey]?.count {
                tableCount = dictcount
                
            }
        }
    }
    
    private  var tableCount = 0
    
    var images = ["Space":["oval","mars","moon","horizon","lake","sat"],
                  "Fields":["field1","field2","field3","field4","field5"],
                  "FootballPlayers":["mosalah","messi","cr7","ibra","son"]
    ]
    
    
    
    //MARK: - numOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableCount
    }
    
    //MARK: - cellForItem
    
    var flowLayout : UICollectionViewFlowLayout?{
        return imageGalleryCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    override func viewDidLayoutSubviews() {
        flowLayout?.invalidateLayout()
    }
            
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("inside collectionView",images[DictionaryKey]![indexPath.row])
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        
        if let imageCell = cell as? ImageGalleryCollectionViewCell{
            imageURL = Bundle.main.url(forResource: images[DictionaryKey]![indexPath.row], withExtension: "jpg")
            
            if let url = imageURL {
                DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
                    let urlContent = try? Data(contentsOf: url)
                    DispatchQueue.main.async {
                        if let imageData = urlContent , url == self?.imageURL {
                            imageCell.uiImage.image = UIImage(data: imageData)
                            imageCell.layoutIfNeeded()
                            imageCell.layer.masksToBounds = true
                        }
                    }
                }
                
            }
        }
      
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        if let image = (imageGalleryCollectionView.cellForItem(at: indexPath) as? ImageGalleryCollectionViewCell)?.uiImage.image{
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = image
            return [dragItem]
        }else{
            return []
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) || session.canLoadObjects(ofClass: NSURL.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath{
                if let image = item.dragItem.localObject as? UIImage {
                    collectionView.performBatchUpdates({
                        images[DictionaryKey]!.remove(at: sourceIndexPath.item)
                        images[DictionaryKey]!.insert(images[DictionaryKey]![sourceIndexPath.row], at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            }
        }
        
    }
    
    
    
}
