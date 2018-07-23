//
//  NewsFeedTableViewController.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 23/07/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit

class NewsFeedTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        return cell
    }
}
