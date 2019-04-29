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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.register(UINib(nibName: cellNibName, bundle: nil), forCellReuseIdentifier: "Cell")
    }
}
