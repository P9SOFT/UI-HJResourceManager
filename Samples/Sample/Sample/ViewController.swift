//
//  ViewController.swift
//  Sample
//
//  Created by Tae Hyun Na on 2016. 2. 11.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var imageListTableView:UITableView!
    private var imageList:[String] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for _ in 0  ..< 32  {
            imageList.append("http://www.p9soft.com/images/sample.jpg")
        }
        let nibName = UINib(nibName:"SampleTableViewCell", bundle:nil)
        self.imageListTableView.registerNib(nibName, forCellReuseIdentifier:"sampleCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.imageList.count
    }
    
    func  tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:SampleTableViewCell = self.imageListTableView.dequeueReusableCellWithIdentifier("sampleCell")! as! SampleTableViewCell
        cell.urlLabel.text = self.imageList[indexPath.row]
        cell.thumbnailImageView?.setImageUrl(self.imageList[indexPath.row], placeholderImage:nil, cutInLine:true, completion:nil)
        cell.helloButton.setBackgroundImageUrl(self.imageList[indexPath.row], placeholderImage:nil, cutInLine:true, forState:.Normal, completion:nil)
        return cell
    }
    
}

