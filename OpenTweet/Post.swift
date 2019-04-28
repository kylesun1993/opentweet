//
//  Post.swift
//  OpenTweet
//
//  Created by Kyle Sun on 4/28/19.
//  Copyright © 2019 OpenTable, Inc. All rights reserved.
//

import Foundation

class Post
{
    var author : String
    var avatar : String?
    var inReplyTo: Int?
    var content : String
    var date : Date
    var id : Int

    
    init(author: String, avatar: String?, inReplyTo: Int?, content: String, date: Date, id: Int) {
        self.author = author
        self.avatar = avatar
        self.inReplyTo = inReplyTo
        self.content = content
        self.date = date
        self.id = id
    }
}
