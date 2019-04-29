//
//  ViewController.swift
//  OpenTweet
//
//  Created by Olivier Larivain on 9/30/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

import UIKit
import Foundation

// Default view when landing, only shows the post but no replies
class TimelineViewController: UIViewController
{
    @IBOutlet weak var tableView : UITableView!
    
    fileprivate var items : [Post] = []
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        // set the title to OpenTweet
        self.title = "OpenTweet"
        
        // removes the text on the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // reading the json file and parses it
        self.items = Utils.readJsonFile()
        
        // uses the custom view for tablecell
        Utils.setupInterface("PostCell", tableView: tableView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

extension TimelineViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // this check if we can convert to PostCell, and checks if goes beyond index
        if let c = cell as? PostCell, indexPath.row < items.count
        {
            // bind function attaches all labels, views, and image
            c.bind(item: items[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Initializes view to push
        if let vc = Utils.initializeViewController("Main", "TimelineDetailsViewController") as? TimelineDetailsViewController
        {
            // pass the object to the next viewController
            vc.item = items[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
