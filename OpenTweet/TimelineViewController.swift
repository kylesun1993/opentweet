//
//  ViewController.swift
//  OpenTweet
//
//  Created by Olivier Larivain on 9/30/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

import UIKit
import Foundation

class TimelineViewController: UIViewController
{
    @IBOutlet weak var tableView : UITableView!
    
    fileprivate var items : [Post] = []
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.title = "OpenTweet"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        readJsonFile()
        Utils.setupInterface("PostCell", tableView: tableView)
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func readJsonFile()
    {
        if let filePath = Bundle.main.path(forResource: "timeline", ofType: "json")
        {
            do
            {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? Dictionary<String, AnyObject>,
                    let timeline = json["timeline"] as? [Dictionary<String, AnyObject>]
                {
                    self.parseJson(timeline)
                }
            }
            catch
            {
                print("fail to fetch data from file")
            }
        }
        else
        {
            print("file not found")
        }
    }
    
    func parseJson(_ timeline : [Dictionary<String, AnyObject>])
    {
        for item in timeline
        {
            let author = item["author"] as! String
            let avatar = item["avatar"] as? String
            let content = item["content"] as! String
            let inReplyTo = item["inReplyTo"] as? String
            let date = item["date"] as! String
            let id = item["id"] as! String
            
            let formatter = ISO8601DateFormatter()
            
            if let time = formatter.date(from: date), let id = Int(id)
            {
                if let irt = inReplyTo, let replyTo = Int(irt)
                {
                    if let post = self.findItemById(replyTo, self.items)
                    {
                        let obj = Post(author: author, avatar: avatar ?? nil, replies: [], content: content, date: time, id: id)
                        post.replies.append(obj)
                    }
                }
                else
                {
                    let obj = Post(author: author, avatar: avatar ?? nil, replies: [], content: content, date: time, id: id)
                    self.items.append(obj)
                }
            }
        }
        
        self.items.sort { (p1, p2) -> Bool in
            return p1.date > p2.date
        }
    }
    
    func findItemById(_ id : Int, _ objs: [Post]) -> Post?
    {
        for item in objs
        {
            if item.id == id
            {
                return item
            }
            
            if item.replies.count != 0
            {
                return findItemById(id, item.replies)
            }
        }
        
        return nil
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

extension TimelineViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let c = cell as? PostCell, indexPath.row < items.count
        {
            c.bind(item: items[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "TimelineDetailsViewController") as? TimelineDetailsViewController
        {
            vc.item = items[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
