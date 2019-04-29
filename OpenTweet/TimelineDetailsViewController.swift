//
//  TimelineDetailsViewController.swift
//  OpenTweet
//
//  Created by Kyle Sun on 4/28/19.
//  Copyright © 2019 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

class TimelineDetailsViewController : UIViewController
{
    @IBOutlet weak var tableView : UITableView!
    
    var item : Post? = nil

    override func viewDidLoad() {
        
        self.title = "OpenTweet"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        Utils.setupInterface("PostCell", tableView: tableView)
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

extension TimelineDetailsViewController : UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (item?.replies.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let c = cell as? PostCell
        {
            if indexPath.row == 0
            {
                c.bind(item: item!)
            }
            else
            {
                c.bind(item: item!.replies[indexPath.row - 1])
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "TimelineDetailsViewController") as? TimelineDetailsViewController
        {
            vc.item = item?.replies[indexPath.row - 1]
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
}
