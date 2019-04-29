//
//  Utils.swift
//  OpenTweet
//
//  Created by Kyle Sun on 4/28/19.
//  Copyright © 2019 OpenTable, Inc. All rights reserved.
//

import UIKit
import Foundation

class Utils
{
    static func setupInterface(_ cellNibName: String, tableView: UITableView)
    {
        // sets the cell to dynamic according content size
        tableView.rowHeight = UITableView.automaticDimension
        
        // set the estimated row height to 300 to guess approx. cell height
        tableView.estimatedRowHeight = 300
        
        // this removes additional seperate line beyond items count
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: cellNibName, bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    static func downloadImage(url: URL, callback: @escaping (Data?, URLResponse?, Error?) -> ())
    {
        // using a URLSession data task to download the image
        URLSession.shared.dataTask(with: url, completionHandler: callback).resume()
    }
    
    static func readJsonFile() -> [Post]
    {
        // set the file path for timeline.json
        if let filePath = Bundle.main.path(forResource: "timeline", ofType: "json")
        {
            do
            {
                // try to fetch data from timeline.json
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                
                // checking if the json read is the JSON format
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? Dictionary<String, AnyObject>,
                    let timeline = json["timeline"] as? [Dictionary<String, AnyObject>]
                {
                    // returns the parsed json
                    return Utils.parseJson(timeline)
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
        
        return []
    }
    
    static func parseJson(_ timeline : [Dictionary<String, AnyObject>]) -> [Post]
    {
        // local variable to be returned
        var items : [Post] = []
        
        // iterate json dictionary
        for item in timeline
        {
            // avatar and inReplyTo can be nil
            let author = item["author"] as! String
            let avatar = item["avatar"] as? String
            let content = item["content"] as! String
            let inReplyTo = item["inReplyTo"] as? String
            let date = item["date"] as! String
            let id = item["id"] as! String
            
            let formatter = ISO8601DateFormatter()
            
            // format date from string, and cast id from string to int
            if let time = formatter.date(from: date), let id = Int(id)
            {
                // check if inReplyTo is null
                if let irt = inReplyTo, let replyTo = Int(irt)
                {
                    // if inReplyTo is not null, then we need find the parent by id
                    if let post = Utils.findItemById(replyTo, items)
                    {
                        // we construct object for reply
                        let obj = Post(author: author, avatar: avatar ?? nil, replies: [], content: content, date: time, id: id)
                        
                        // we append the reply to its parent post
                        Utils.insert(&post.replies, obj)
                    }
                }
                else
                {
                    // if inReplyTo is null, which means its the original, we just construct the object.
                    let obj = Post(author: author, avatar: avatar ?? nil, replies: [], content: content, date: time, id: id)
                    items.append(obj)
                }
            }
        }
        
        // we sort by ascending chronological order
        items.sort { (p1, p2) -> Bool in
            return p1.date < p2.date
        }
        
        // return the items
        return items
    }
    
    static func insert(_ replies : inout [Post], _ obj: Post)
    {
        var c = 0
        for r in replies
        {
            if r.date > obj.date
            {
                replies.insert(obj, at: c)
            }
            
            c += 1
        }
        
        replies.append(obj)
    }
    
    static func findItemById(_ id : Int, _ objs: [Post]) -> Post?
    {
        // we iterate the array of objects
        for item in objs
        {
            // if id matches, then return the object
            if item.id == id
            {
                return item
            }
            
            // if id doesnt match, then we check if we try to iterate the replies.
            if item.replies.count != 0
            {
                return findItemById(id, item.replies)
            }
        }
        
        // if nothing is found, we return nil
        return nil
    }
    
    static func initializeViewController(_ storyboardName: String, _ restorationId: String) -> UIViewController
    {
        // initialize view by finding storyboard
        let storyBoard : UIStoryboard = UIStoryboard(name: storyboardName, bundle:nil)
        
        // return initialized view by using restorationId
        return storyBoard.instantiateViewController(withIdentifier: restorationId)
    }
    
    static func matches(for regex: String, in text: String) -> [String]
    {
        do {
            // stuff the regex expression in NSRegularExpression
            let regex = try NSRegularExpression(pattern: regex)
            
            // cast String to NSString to use matches function
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            
            // returns the substring of matched string
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            
            // print error
            print("\(error.localizedDescription)")
        }
        
        // return empty array if nothing is found
        return []
    }
}
