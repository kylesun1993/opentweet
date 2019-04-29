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
    fileprivate var selectedIndex : Int? = nil
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        // set the title to OpenTweet
        self.title = "OpenTweet"
        
        // removes the text on the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // reading the json file and parses it
        
        if items.count == 0
        {
            self.items = Utils.readJsonFile()
        }
        
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
            print(indexPath.row, c.frame.height, c.contentView.frame.height, c.content.frame.height)
            // bind function attaches all labels, views, and image
            c.bind(item: items[indexPath.row])
            
            if let i = selectedIndex, i == indexPath.row
            {
                c.backgroundColor = UIColor(displayP3Red: 135/255, green: 181/255, blue: 255/255, alpha: 1.0)
            }
            
            if let r = items[indexPath.row].replyTo
            {
                if let user = items.first(where: { (p) -> Bool in
                    return p.id == r
                })
                {
                    c.replies.text = "replying to " + user.author
                }
            }
            else
            {
                if c.replies != nil
                {
                    c.replies.text = ""
                    c.replies.removeFromSuperview()
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Initializes view to push
        if let vc = Utils.initializeViewController("Main", "TimelineViewController") as? TimelineViewController
        {
            if selectedIndex == nil || (selectedIndex != indexPath.row && items.count > 2)
            {
                let item = items[indexPath.row]
                var itemsForNextVC : [Post] = []
                if let replyTo = item.replyTo
                {
                    for i in items
                    {
                        if i.replyTo == item.id
                        {
                            itemsForNextVC.append(i)
                        }
                        else if i.id == replyTo
                        {
                            itemsForNextVC.append(i)
                        }
                    }
                    
                    itemsForNextVC.append(item)
                    
                    itemsForNextVC.sort { (p1, p2) -> Bool in
                        return p1.date < p2.date
                    }
                }
                else
                {
                    for i in items
                    {
                        if let replyTo = i.replyTo
                        {
                            if replyTo == item.id
                            {
                                itemsForNextVC.append(i)
                            }
                        }
                    }
                    
                    itemsForNextVC.sort { (p1, p2) -> Bool in
                        return p1.date < p2.date
                    }
                    
                    itemsForNextVC.insert(item, at: 0)
                }
                
                
                vc.items = itemsForNextVC
                vc.selectedIndex = itemsForNextVC.firstIndex(where: { (p) -> Bool in
                    return p.id == item.id
                })
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }
    }
}
