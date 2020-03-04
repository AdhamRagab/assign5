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
    
    var newGallery : String?
    @IBAction func AddItem(_ sender: UIBarButtonItem) {
        
        
        let alert = UIAlertController(title: "Add new gallery", message: "Please enter the name of the gallery", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter the name of the new gallery"
        }
        
        alert.addAction(UIAlertAction(title: "Add gallery", style: .default, handler: { (action) in
            if let tf = alert.textFields?.first {
                self.tableSections[0] += [tf.text!]
//                NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: nil, userInfo: [tf : tf.text!])
                self.newGallery = tf.text
                self.tableView.reloadData()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
        
        //        tableSections[0] += ["Image Gallery".madeUnique(withRespectTo: tableSections[0] as! [String])]
        //        let newItem = tableSections[0].last
        //        print(newItem!)
        //        galleryController.gallery.gallery?[newItem as! String] = []
        //
        //        print(gallery.gallery?[(tableSections[0].last as? String)!])
        //        tableView.reloadData()
        
    }
    
    var deletedItem = ""
    var recoveredItem = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Image Galleries"
        navigationController?.navigationBar.prefersLargeTitles = true
        
       
    }
    var index : IndexPath?
    @objc func doubleTapped(){
        
        let alert = UIAlertController(title: "Change Gallery's Name", message: "Please change the gallery's name or cancel", preferredStyle: .alert)
              
              alert.addTextField { (textField) in
                  textField.placeholder = "change the name of the  gallery"
              }
              
              alert.addAction(UIAlertAction(title: "Submit change", style: .default, handler: { (action) in
                  if let tf = alert.textFields?.first {
                    if let indexPath = self.index{
                        print(self.tableSections[0][indexPath.row])
                        self.tableSections[indexPath.section][indexPath.row] = tf.text!
                      self.tableView.reloadData()
                    }
                  }
              }))
              
              alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
              
              present(alert, animated: true, completion: nil)
    }
    var tableSections = [ ["FootballPlayers","Fields"] , [] ]
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = section == 0 ? "Image Galleries" : "Deleted Image Galleries"
        label.backgroundColor = UIColor.lightGray
        return label
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableSections[section].count
    }
    
   
   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageGalleryCell", for: indexPath)
        
        let gallery = tableSections[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = gallery
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
               tap.numberOfTapsRequired = 2
               cell.addGestureRecognizer(tap)
        
        return cell
    }
    
   
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                deletedItem = tableSections[0][indexPath.row]
                tableSections[0].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableSections[1] += [deletedItem]
                tableView.reloadData()
            }else {
                tableSections[1].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            
        } else if editingStyle == .insert {
            //
        }    
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 1 {
            let recover = UIContextualAction(style: .normal, title: "Recover") { (contextualAction, view, actionPerformed: (Bool) -> ()) in
                self.recoveredItem = self.tableSections[1][indexPath.row]
                self.tableSections[1].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableSections[0] += [self.recoveredItem]
                tableView.reloadData()
            }
            return UISwipeActionsConfiguration(actions: [recover])
        }else {
            return nil
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChooseGallery" {
            if let galleryName = (sender as? UITableViewCell)?.textLabel {
                if let cvc = segue.destination as? ImageGalleryViewController{
                    cvc.gallery.gallery = ["FootballPlayers":[#imageLiteral(resourceName: "mosalah.jpg"),#imageLiteral(resourceName: "messi.jpg"),#imageLiteral(resourceName: "ibra.jpg"),#imageLiteral(resourceName: "cr7.jpg"),#imageLiteral(resourceName: "son.jpg")],
                           "Fields":[#imageLiteral(resourceName: "field1"),#imageLiteral(resourceName: "field2.jpg"),#imageLiteral(resourceName: "field3.jpg"),#imageLiteral(resourceName: "field4.jpg"),#imageLiteral(resourceName: "field5.jpg")]]
                    if self.newGallery != nil {
                        cvc.gallery.gallery?[newGallery!] = []
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
