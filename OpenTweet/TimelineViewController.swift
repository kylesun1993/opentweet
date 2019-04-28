//
//  ViewController.swift
//  OpenTweet
//
//  Created by Olivier Larivain on 9/30/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

import UIKit
import Foundation

class TimelineViewController: UIViewController {

    fileprivate var items : [Post] = []
	override func viewDidLoad() {
		super.viewDidLoad()
        
        readJsonFile()
        
        print(items)
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
                            let obj : Post
                            
                            if let irt = inReplyTo, let iirt = Int(irt)
                            {
                                obj = Post(author: author, avatar: avatar ?? nil, inReplyTo: iirt, content: content, date: time, id: id)
                            }
                            else
                            {
                                obj = Post(author: author, avatar: avatar ?? nil, inReplyTo: nil, content: content, date: time, id: id)
                            }
                            
                            self.items.append(obj)
                        }
                    }
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

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}


}

