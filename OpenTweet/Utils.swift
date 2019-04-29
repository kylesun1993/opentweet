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
        // set the estimated row height to 150 to guess approx. cell height
        tableView.estimatedRowHeight = 200
        
        // sets the cell to dynamic according content size
        tableView.rowHeight = UITableView.automaticDimension
        
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
                    // we construct object for reply
                    let obj = Post(author: author, avatar: avatar ?? nil, replyTo: replyTo, content: content, date: time, id: id)
                    
                    items.append(obj)
                }
                else
                {
                    let obj = Post(author: author, avatar: avatar ?? nil, replyTo: nil, content: content, date: time, id: id)
                    
                    items.append(obj)
                }
            }
        }
        
        // we sort by ascending chronological order
        items.sort { (p1, p2) -> Bool in
            return p1.date > p2.date
        }
        
        // return the items
        return items
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
