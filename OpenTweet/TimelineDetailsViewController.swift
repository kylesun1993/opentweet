//
//  TimelineDetailsViewController.swift
//  OpenTweet
//
//  Created by Kyle Sun on 4/28/19.
//  Copyright © 2019 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

// This is the child view of default view, which i contains the original post and replies
class TimelineDetailsViewController : UIViewController
{
    @IBOutlet weak var tableView : UITableView!
    
    var item : Post? = nil

    override func viewDidLoad() {
        
        // set the title to OpenTweet
        self.title = "OpenTweet"
        
        // removes the text on the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // uses the custom view for tablecell
        Utils.setupInterface("PostCell", tableView: tableView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

extension TimelineDetailsViewController : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        // set 2 sections, first is the original post, second being all replies
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            // only one row because its the original post
            return 1
        }
        
        // rest are replies
        return item?.replies.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0
        {
            return ""
        }
        
        let count = item?.replies.count ?? 0
        return String(describing: count) + (count > 1 ? " Replies" : " Reply")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let c = cell as? PostCell
        {
            if indexPath.section == 0
            {
                // bind cells
                c.bind(item: item!)
            }
            else
            {
                // check if theres replies in replies, if not, hide the replies count
                if item!.replies[indexPath.row].replies.count == 0
                {
                    c.bind(item: item!.replies[indexPath.row], true)
                }
                else
                {
                    c.bind(item: item!.replies[indexPath.row])
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section != 0
        {
            // Initializes view to push
            if let vc = Utils.initializeViewController("Main", "TimelineDetailsViewController") as? TimelineDetailsViewController
            {
                // Passing the Object to the next viewController
                vc.item = item?.replies[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
