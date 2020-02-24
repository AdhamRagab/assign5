//
//  ImageGalleryTableViewController.swift
//  Assignment 5
//
//  Created by Adham Ragab on 2/24/20.
//  Copyright © 2020 Adham Ragab. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {

    @IBAction func AddItem(_ sender: UIBarButtonItem) {
        tableSections[0] += ["Image Gallery".madeUnique(withRespectTo: tableSections[0])]
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Image Galleries"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    var tableSections = [
        ["One" , "Two" , "Three"],
        ["DeletedOne" ,"DTwo", "DThree"]
    ]
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
        
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableSections[1] += [tableSections[indexPath.section][indexPath.row]]
            tableSections[0].remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewWillLayoutSubviews() {
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
}
