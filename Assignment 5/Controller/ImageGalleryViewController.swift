//
//  ImageGalleryViewController.swift
//  Assignment 5
//
//  Created by Adham Ragab on 2/24/20.
//  Copyright © 2020 Adham Ragab. All rights reserved.
//

import UIKit


class ImageGalleryViewController: UIViewController , UIDropInteractionDelegate, UIScrollViewDelegate , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    
    
    var galleryBetterModel = ImageGalleryModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var identifier : Int?
    private var textFieldObserver: NSObjectProtocol?
    private var tableCount = 0
    private var imageFetcher: ImageFetcher!
    private var scaleForCollectionViewCell: CGFloat = 1.0
    
    
    
    //MARK: - Drop Zone
    
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
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textFieldObserver = NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: nil,
            queue: OperationQueue.main,
            using: {(notification) in
//                if let info  = notification.userInfo?.values.first {
//                    //                    self.galleryModel.gallery?[info as! String] = []
//
//                }
        })
    }
    
    
    //MARK: - CollectionView
    
    @IBOutlet weak var imageGalleryCollectionView: UICollectionView!{
        didSet{
            imageGalleryCollectionView.delegate = self
            imageGalleryCollectionView.dataSource = self
            imageGalleryCollectionView.dragDelegate = self
            imageGalleryCollectionView.dropDelegate = self
            if let layout = imageGalleryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumInteritemSpacing = 1
                layout.minimumLineSpacing = 1
            }
            imageGalleryCollectionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(scaleCollectionViewCells(with:))))
        }
        
        
    }
    
    
    @objc func scaleCollectionViewCells(with recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scaleForCollectionViewCell *= recognizer.scale
            recognizer.scale = 0.5
            imageGalleryCollectionView.collectionViewLayout.invalidateLayout()
        default:
            break
        }
    }
    
    //MARK: - CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableCount
    }
    
    var flowLayout : UICollectionViewFlowLayout?{
        return imageGalleryCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.imageCellIdentifier, for: indexPath)
        if let imageCell = cell as? ImageGalleryCollectionViewCell , let image = galleryBetterModel.imageGalleries[identifier!].images?[indexPath.item]{
            imageCell.uiImageView.image = image
        }
        
        return (cell as? ImageGalleryCollectionViewCell)!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: (collectionView.frame.width), height: collectionView.frame.height / (galleryBetterModel.imageGalleries[identifier!].images?[indexPath.row].getImageRatio())!  )
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        if let image = (imageGalleryCollectionView.cellForItem(at: indexPath) as? ImageGalleryCollectionViewCell)?.uiImageView.image{
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
    
    func ChangeImagePlace (from sourceIndexPath : IndexPath? , to destinationIndexPath : IndexPath? , image : UIImage?){
        galleryBetterModel.imageGalleries[identifier!].images?.remove(at: sourceIndexPath!.item)
        galleryBetterModel.imageGalleries[identifier!].images?.insert(image!, at: destinationIndexPath!.item)
        imageGalleryCollectionView.deleteItems(at: [sourceIndexPath!])
        imageGalleryCollectionView.insertItems(at: [destinationIndexPath!])
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath, let image = item.dragItem.localObject as? UIImage {
                collectionView.performBatchUpdates({
                    ChangeImagePlace(from: sourceIndexPath, to: destinationIndexPath, image: image)
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else {
                
                dragPhotoFromWebAndFetchIt(with: item, coordinator: coordinator, in: destinationIndexPath)
                
            }
        }
    }
    
    func initPlaceHolderContext (item: UICollectionViewDropItem , coordinator: UICollectionViewDropCoordinator , destinationIndexPath : IndexPath ) -> UICollectionViewDropPlaceholderContext {
        let placeHolderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: Constants.dropPlaceHolderCell))
        return placeHolderContext
    }
    
    func dragPhotoFromWebAndFetchIt (with item: UICollectionViewDropItem , coordinator: UICollectionViewDropCoordinator , in destinationIndexPath: IndexPath) {
        let placeHolderContext = initPlaceHolderContext(item: item, coordinator: coordinator, destinationIndexPath: destinationIndexPath)
        item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { [weak self] (provider, error) in
            
            if let url = provider as? URL {
                DispatchQueue.global().async { [weak self] in
                    guard let image =  self?.galleryBetterModel.fetchImage(withURL: url) else {
                        return
                    }
                    self?.dropItemAndUpdateModel(placeHolderContext: placeHolderContext, item: item, coordinator: coordinator, image: image)
                }
                
            }else{
                placeHolderContext.deletePlaceholder()
            }
        }
    }
    
    
    
    func dropItemAndUpdateModel(placeHolderContext: UICollectionViewDropPlaceholderContext , item: UICollectionViewDropItem , coordinator: UICollectionViewDropCoordinator , image: UIImage ) {
        
        DispatchQueue.main.async {
            self.imageGalleryCollectionView.performBatchUpdates({
                placeHolderContext.commitInsertion { (insertionIndexPath) in
                    self.galleryBetterModel.imageGalleries[self.identifier!].images?.insert(image, at: insertionIndexPath.item)
                    self.tableCount += 1
                    coordinator.drop(item.dragItem, toItemAt: insertionIndexPath)
                    
                }
            })
        }
        
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showImage{
            if let imageViewImage = (sender as? ImageGalleryCollectionViewCell)?.uiImageView.image{
                if let cvc = segue.destination as? ImageViewController{
                    cvc.image = imageViewImage
                }
            }
        }
    }
    
    
    
}

extension UIImage {
    func getImageRatio() -> CGFloat?{
        let imageRatio = CGFloat(self.size.width/self.size.height)
        return imageRatio
    }
    
    
}
