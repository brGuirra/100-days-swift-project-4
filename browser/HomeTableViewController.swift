//
//  HomeTableViewController.swift
//  browser
//
//  Created by Bruno Guirra on 09/01/22.
//

import UIKit

class HomeTableViewController: UITableViewController {
    let websites = ["apple.com", "hackingwithswift.com", "dev.to", "swiftbysundell.com", "avanderlee.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Websites"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.setHidesBackButton(true, animated: true)
    }

    // Set the number of rows based in how many websites
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    // Creates a cell with the website index content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Website", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = websites[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
    
    // Navigate to the selected page
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Page") as? PageViewController {
            vc.selectedWebsite = websites[indexPath.row]
            vc.websites = websites
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
