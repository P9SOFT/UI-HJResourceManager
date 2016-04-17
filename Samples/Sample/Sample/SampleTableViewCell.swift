//
//  SampleTableViewCell.swift
//  Sample
//
//  Created by Tae Hyun Na on 2016. 2. 11.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import Foundation

class SampleTableViewCell: UITableViewCell {
    
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var urlLabel: UILabel!
    @IBOutlet var helloButton: UIButton!
    
    override func awakeFromNib() {
        
        helloButton?.layer.borderColor = UIColor.lightGrayColor().CGColor
        helloButton?.layer.borderWidth = 3.0
    }
    
    @IBAction func helloButtonTouchUpInside(sender: AnyObject) {
        
        print("hello, button!")
    }
}