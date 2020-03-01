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
                if let dictcount = gallery.gallery?[DictionaryKey]?.count {
                    tableCount = dictcount
                }
            }
        }
    
    private  var tableCount = 0
    
    let gallery = ImageGallery()
    
    
    //MARK: - numOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableCount
    }
    
    //MARK: - cellForItem
    
    var flowLayout : UICollectionViewFlowLayout?{
        return imageGalleryCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        if let imageCell = cell as? ImageGalleryCollectionViewCell{
            if let image = gallery.gallery?[DictionaryKey]?[indexPath.row]{
                imageCell.uiImage.image = image
                //            fetchImage(forArr: DictionaryKey, forCell: imageCell, for: indexPath)
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
    
    var url: URL?
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath{
                if let image = item.dragItem.localObject as? UIImage {
                    collectionView.performBatchUpdates({
                        print(sourceIndexPath)
                        print(destinationIndexPath)
                        gallery.gallery?[DictionaryKey]?.remove(at: sourceIndexPath.item)
                        gallery.gallery?[DictionaryKey]?.insert(image, at: destinationIndexPath.item)
                        //                        images[DictionaryKey]!.remove(at: sourceIndexPath.item)
                        //                        images[DictionaryKey]!.insert(image, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                        
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            }
            else {
                let placeHolderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceHolderCell"))
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { [weak self] (provider, error) in
                    
                    self?.url = provider as? URL
                    
                    if let url = provider as? URL {
                        
                        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                            guard let data = try? Data(contentsOf: url.imageURL) else {
                                return
                            }
                            
                            guard let image = UIImage(data: data) else {
                                print("Couldn't convert data to UIImage")
                                print("The url is")
                                print(self!.url!.imageURL)
                                return
                            }
                            
                            
                            // If by the time the async. fetch finishes, the imageURL is still the same, update the UI (in the main queue)
                            DispatchQueue.main.async {
                                collectionView.performBatchUpdates({
                                    // Update model
                                    // Update view
                                    placeHolderContext.commitInsertion { (insertionIndexPath) in
                                        //                                        self?.images[self!.DictionaryKey]!.insert(image, at: insertionIndexPath.item)
                                        self?.gallery.gallery?[self!.DictionaryKey]?.insert( image , at: insertionIndexPath.item)
                                        print(insertionIndexPath.item)
                                        coordinator.drop(item.dragItem, toItemAt: insertionIndexPath)
                                    }
                                    
                                })
                            }
                        }
                        
                        
                    }else{
                        placeHolderContext.deletePlaceholder()
                    }
                    
                    //                                if let image = provider as? UIImage {
                    //                                    placeHolderContext.commitInsertion { (insertionIndexPath) in self.images[self.DictionaryKey]!.insert(image, at: insertionIndexPath.item)
                    //                                    }
                    //                                }else{
                    //                                    placeHolderContext.deletePlaceholder()
                    //                                }
                }
            }
        }
        
    }
    
    //        func fetchImage (forArr DictKey: String , forCell cell: ImageGalleryCollectionViewCell , for indexPath: IndexPath) {
    //
    //
    //            imageURL = Bundle.main.url(forResource: images[DictKey]![indexPath.row], withExtension: "jpg")
    //
    //                   if let url = imageURL {
    //                       DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
    //                           let urlContent = try? Data(contentsOf: url)
    //                           DispatchQueue.main.async {
    //                               if let imageData = urlContent , url == self?.imageURL {
    //                                print(UIImage(data:imageData))
    //                                cell.uiImage.image = UIImage(data: imageData)
    //                                self?.imageGalleryView.setNeedsDisplay()
    //                                self?.imageGalleryView.setNeedsLayout()
    //                               }
    //                           }
    //                       }
    //
    //                   }
    //        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowImage"{
            if let imageViewImage = (sender as? ImageGalleryCollectionViewCell)?.uiImage.image{
                if let cvc = segue.destination as? ImageViewController{
                    cvc.image = imageViewImage
                }
            }
        }
    }
    
    
    
}

extension UIImage {
    func getImageRatio() -> CGFloat{
        let imageRatio = CGFloat(self.size.width/self.size.height)
        return imageRatio
    }
    
    
}
