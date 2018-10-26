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
    
    var data:String? {
        get {
            return urlLabel.text
        }
        set {
            urlLabel.text = newValue
            thumbnailImageView.setImageUrl(newValue, placeholderImage:nil)
            helloButton.setBackgroundImageUrl(newValue, placeholderImage:nil, for:.normal)
        }
    }
    
    override func awakeFromNib() {
        
        helloButton?.layer.borderColor = UIColor.lightGray.cgColor
        helloButton?.layer.borderWidth = 3.0
    }
    
    @IBAction func helloButtonTouchUpInside(_ sender: AnyObject) {
        
        print("hello, button!")
    }
}
