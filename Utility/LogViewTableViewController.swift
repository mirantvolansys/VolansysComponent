//
//  LogViewTableViewController.swift
//  Component_Mirant
//
//  Created by Mirant Patel on 16/07/19.
//  Copyright © 2019 Mirant Patel. All rights reserved.
//

import UIKit

class LogViewTableViewController: UITableViewController {
    
    //Array of file's urls which we want to display it in tableview
    var urlsOfLogFiles = getAllFilesOfDirectory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Log Files"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return urlsOfLogFiles?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let strCellIdentifier = "cellReuseLog"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: strCellIdentifier)

        if(cell == nil) {
           cell = UITableViewCell(style: .default, reuseIdentifier: strCellIdentifier)
        }

        cell?.textLabel?.text = urlsOfLogFiles![indexPath.row].lastPathComponent
        
        cell!.selectionStyle = .none
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showPreviewByPath(urlsOfLogFiles![indexPath.row])
    }
}
