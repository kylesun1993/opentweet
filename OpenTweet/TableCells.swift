//
//  PostCell.swift
//  OpenTweet
//
//  Created by Kyle Sun on 4/28/19.
//  Copyright © 2019 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

class PostCell : UITableViewCell
{
    @IBOutlet weak var avatar : UIImageView!
    @IBOutlet weak var author : UILabel!
    @IBOutlet weak var content : UITextView!
    @IBOutlet weak var timestamp : UILabel!
    @IBOutlet weak var replies : UILabel!
    
    func bind(item : Post)
    {
        // set the avatar image to round
        self.avatar.layer.cornerRadius = avatar.frame.width / 2
        self.avatar.clipsToBounds = true
        
        // always set the default avatar image
        self.avatar.image = UIImage(named: "userDefault")
        
        // fetch avatar image
        self.getAvatar(item: item)

        // set author text
        self.author.text = item.author
        
        // set content text
        self.content.text = item.content

        // set content background color to clear so that when selected, the color inherits from the cell background
        self.content.backgroundColor = UIColor.clear
        
        // highlight the @{username} only, because link highlight checked in storyboard
        self.highlightUsername(item.content, textView: self.content)
        
        // format the date to desired format
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy HH:mm"
        
        // set the time text
        self.timestamp.text = formatter.string(from: item.date)
    }
    
    func getAvatar(item : Post)
    {
        // check that item.avatar is not null
        if let avatar = item.avatar
        {
            if let url = URL(string: avatar)
            {
                // put download on background thread so that calls can be async
                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                    Utils.downloadImage(url: url) { (data, response, error) in
                        if error != nil
                        {
                            // error handling
                            print(url)
                            print("failed to download image")
                        }
                        else
                        {
                            if let d = data
                            {
                                // switching back to main thread to set image
                                DispatchQueue.main.async {
                                    self.avatar?.image = UIImage(data: d)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    func highlightUsername(_ fullString : String, textView : UITextView)
    {
        // use regex to check for username
        let userMatch = Utils.matches(for: "^@[A-Za-z0-9._]{1,20}", in: fullString)
        
        // assume only the very first token of string will have the username
        if userMatch.count > 0, let user = userMatch.first
        {
            // set the link attr, so link will be redirect to the url set below
            let linkAttributes = [
                NSAttributedString.Key.link: URL(string: "https://www.tweet.com/" + user)!,
                NSAttributedString.Key.foregroundColor: UIColor.blue
                ] as [NSAttributedString.Key : Any]
            let str = NSMutableAttributedString(string: fullString)
            
            str.setAttributes(linkAttributes, range: NSMakeRange(0, user.count))
            
            textView.attributedText = str
        }
    }
}

@IBDesignable class PostCellTextView: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // removes the extra padding in the textView
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        // check that the hit point is within the textView's range
        if point.x > 0, point.y > 0, point.x < self.contentSize.width, point.y < self.contentSize.height
        {
            // get the character where the text is touched
            let characterIndex = self.layoutManager.characterIndex(for: point, in: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            // check if the character is within the text size
            if characterIndex < self.textStorage.length
            {
                // set the attribute of link to be clickable
                if (self.textStorage.attribute(NSAttributedString.Key.link, at: characterIndex, effectiveRange: nil) != nil) {
                    return self
                }
            }
        }
        
        // otherwise do nothing
        return nil
    }
}
