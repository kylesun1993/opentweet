//
//  PostCell.swift
//  OpenTweet
//
//  Created by Kyle Sun on 4/28/19.
//  Copyright © 2019 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

class PostingCell : UITableViewCell
{
    var avatar : UIImageView = UIImageView()
    var author : UILabel = UILabel()
    var content : PostCellTextView = PostCellTextView()
    var date : UILabel = UILabel()
    var replies : UILabel = UILabel()
    
    let avatarSize : Int = 50
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // adding all the view to cell programmatically, so we can set constraints for better visual.
        self.contentView.addSubview(avatar)
        self.contentView.addSubview(author)
        self.contentView.addSubview(content)
        self.contentView.addSubview(date)
        self.contentView.addSubview(replies)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        author.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        date.translatesAutoresizingMaskIntoConstraints = false
        replies.translatesAutoresizingMaskIntoConstraints = false
        
        let marginGuide = contentView.layoutMarginsGuide
        
        avatar.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor, constant: 8).isActive = true
        avatar.topAnchor.constraint(equalTo: marginGuide.topAnchor, constant: 8).isActive = true
        avatar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: 50).isActive = true

        author.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16).isActive = true
        author.topAnchor.constraint(equalTo: marginGuide.topAnchor, constant: 8).isActive = true
        
        date.leadingAnchor.constraint(equalTo: author.trailingAnchor, constant: 8).isActive = true
        date.centerYAnchor.constraint(equalTo: author.centerYAnchor, constant: 0).isActive = true
        
        content.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16).isActive = true
        content.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor, constant: 8).isActive = true
        content.topAnchor.constraint(equalTo: author.bottomAnchor, constant: 4).isActive = true
        content.bottomAnchor.constraint(equalTo: replies.topAnchor, constant: -8).isActive = true
        
        replies.topAnchor.constraint(equalTo: content.bottomAnchor, constant: 8).isActive = true
        replies.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor, constant: -8).isActive = true
        replies.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16).isActive = true
        replies.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor, constant: 8).isActive = true
        
        // set the avatar image to round
        self.avatar.layer.cornerRadius = CGFloat(avatarSize / 2)
        self.avatar.clipsToBounds = true
        
        // always set the default avatar image
        self.avatar.image = UIImage(named: "userDefault")
        
        // set different font size
        self.author.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.date.font = UIFont.systemFont(ofSize: 13.0)
        self.content.font = UIFont.systemFont(ofSize: 14.0)
        self.replies.font = UIFont.systemFont(ofSize: 13.0)
        
        // make content not editable and not scrollable
        self.content.isEditable = false
        self.content.isScrollEnabled = false
        
        // make content background clear, so it inherits the color of the cell
        self.content.backgroundColor = UIColor.clear

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func bind(items : [Post], indexPath : IndexPath)
    {
        let item = items[indexPath.row]
        
        // fetch avatar
        getAvatar(item: item)
        
        // setting text
        self.author.text = item.author
        self.content.text = item.content
        
        // highlights the url and username
        self.highlightLinks(item.content, textView: self.content)

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy HH:mm"
        
        // set the time text
        self.date.text = formatter.string(from: item.date)

        if let r = items[indexPath.row].replyTo
        {
            if let user = items.first(where: { (p) -> Bool in
                return p.id == r
            })
            {
                self.replies.text = "replying to " + user.author
            }
        }
        else
        {
            self.replies.text = ""
        }
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
                                    self.avatar.image = UIImage(data: d)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    func highlightLinks(_ fullString : String, textView : UITextView)
    {
        let setTextAttr = { (str : String, range : NSRange) in
            // assume only the very first token of string will have the username
            if str.count > 0
            {
                // set the link attr, so link will be redirect to the url set below
                let linkAttributes = [
                    NSAttributedString.Key.link: URL(string: str.starts(with: "@") ? "http://www.tweet.com/" + str : str)!,
                    NSAttributedString.Key.foregroundColor: UIColor.blue,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14.0)
                    ] as [NSAttributedString.Key : Any]
                let s = NSMutableAttributedString(string: fullString)
                
                s.setAttributes(linkAttributes, range: range)
                
                textView.attributedText = s
            }
        }
        
        // use regex to check for username
        if let userMatch = Utils.matches(for: "^@[A-Za-z0-9._]{1,20}", in: fullString)
        {
            setTextAttr(userMatch.0, userMatch.1)
        }
        
        // use regex to check for url
        if let urlMatch = Utils.matches(for: "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)", in: fullString)
        {
            setTextAttr(urlMatch.0, urlMatch.1)
        }
    }
}

class PostCellTextView: UITextView
{
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
