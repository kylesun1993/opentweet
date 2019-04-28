//
//  ImageFetcher.swift
//  OpenTweet
//
//  Created by Kyle Sun on 4/28/19.
//  Copyright © 2019 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

class ImageFetcher
{
    static func downloadImage(url: URL, callback: @escaping (Data?, URLResponse?, Error?) -> ())
    {
        URLSession.shared.dataTask(with: url, completionHandler: callback).resume()
    }
}
