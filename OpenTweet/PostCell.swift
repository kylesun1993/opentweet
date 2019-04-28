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
        if let avatar = item.avatar
        {
            if let url = URL(string: avatar)
            {
                ImageFetcher.downloadImage(url: url) { (data, response, error) in
                    if error != nil
                    {
                        print(url)
                        print("failed to download image")
                    }
                    else
                    {
                        if let d = data
                        {
                            DispatchQueue.main.async {
                                self.avatar?.image = UIImage(data: d)
                            }
                        }
                    }
                }
            }
        }
        
        avatar.layer.cornerRadius = avatar.frame.width / 2
        avatar.clipsToBounds = true

        self.author.text = item.author
        self.content.text = item.content
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy HH:mm"
        self.timestamp.text = formatter.string(from: item.date)
        
        self.replies.text = String(describing: item.replies.count) + (item.replies.count > 1 ? " replies" : " reply")
    }
}

@IBDesignable class OpenTweetTextView: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
