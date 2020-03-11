//
//  ImageGalleryTableViewController.swift
//  Assignment 5
//
//  Created by Adham Ragab on 2/24/20.
//  Copyright © 2020 Adham Ragab. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {
    
    let galleryController = ImageGalleryViewController()
    let K = Constants()
    
    var newGallery : String?
    var deletedItem = ""
    var recoveredItem = ""
    var tfg = UITextField()
    var edited = false
    var oldValue = ""
    var tableSections = [ [] , [] ]
    
    
    @IBAction func AddItem(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: Constants.AddNewGallery ,
                                      message: Constants.PleaseEnterGalleryName ,
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = Constants.EnterGalleryName
        }
        alert.addAction(UIAlertAction(title: Constants.AddAction , style: .default, handler: { (action) in
            if let tf = alert.textFields?.first {
                self.tableSections[0] += [tf.text!]
                self.newGallery = tf.text
                self.tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: Constants.Cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Constants.ImageGalleries
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
    }
    
    @objc func doubleTapped(){
        
        let alert = UIAlertController(title: Constants.ChangeGalleryName, message: Constants.PleaseChangeName , preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = Constants.ChangeNamePlaceHolder
        }
        
        alert.addAction(UIAlertAction(title: Constants.ChangeAction , style: .default, handler: { (action) in
            self.ChangeGalleryName(alert)
        })
        )
        
        alert.addAction(UIAlertAction(title: Constants.Cancel , style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func ChangeGalleryName(_ alert: UIAlertController ){
        
        if let tf = alert.textFields?.first {
            self.tfg.text = tf.text
            self.edited = true
            if self.edited {
                if let index = self.tableView.indexPathForSelectedRow?.row{
                    SwitchKey(of: index)
                }
            }
            
        }
    }
    
    func SwitchKey(of index: Int){
        self.oldValue = self.tableSections[0][index] as! String
        self.tableSections[0][index] = self.tfg.text!
        self.galleryController.galleryModel.gallery?.switchKey(fromKey: self.oldValue , toKey: self.tfg.text! )
        self.edited = false
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = section == 0 ? Constants.ImageGalleries : Constants.DeletedImageGalleries
        label.backgroundColor = UIColor.lightGray
        return label
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSections[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ImageGalleryCell, for: indexPath)
        let gallery = tableSections[indexPath.section][indexPath.row]
        cell.textLabel?.text = gallery as? String
        addDoubleTapGesture(to: cell)
        return cell
        
    }
    
    func addDoubleTapGesture(to cell : UITableViewCell){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        cell.addGestureRecognizer(tap)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.ShowImageGallery, sender: tableView.cellForRow(at: indexPath))
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            indexPath.section == 0 ? MoveGalleryToTrash(at: indexPath) : DeleteGallery(at: indexPath)
        }
    }
    
    func DeleteGallery(at indexPath : IndexPath){
        tableSections[1].remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func MoveGalleryToTrash(at indexPath: IndexPath){
        deletedItem = tableSections[0][indexPath.row] as! String
        tableSections[0].remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableSections[1] += [deletedItem]
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 1 {
            let recover = UIContextualAction(style: .normal, title: Constants.Recover ) { (contextualAction, view, actionPerformed: (Bool) -> ()) in
                self.RecoverRow(at :indexPath)
            }
            return UISwipeActionsConfiguration(actions: [recover])
        }else {
            return nil
        }
    }
    
    func RecoverRow(at indexPath: IndexPath){
        self.recoveredItem = self.tableSections[1][indexPath.row] as! String
        self.tableSections[1].remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        self.tableSections[0] += [self.recoveredItem]
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.ShowImageGallery {
            if let galleryName = (sender as? UITableViewCell)?.textLabel {
                if let cvc = segue.destination as? ImageGalleryViewController{
                    cvc.galleryModel.gallery = [:]
                    if self.newGallery != nil {
                        cvc.galleryModel.gallery?[newGallery!] = []
                    }
                    cvc.DictionaryKey = galleryName.text ?? ""
                }
            }
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
}



extension Dictionary {
    mutating func switchKey(fromKey: Key, toKey: Key) {
        if let entry = removeValue(forKey: fromKey) {
            self[toKey] = entry
        }
    }
}
