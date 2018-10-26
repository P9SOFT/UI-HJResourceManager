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
    
    fileprivate var imageList:[String] = []
    fileprivate let cellIdentifier = "sampleCell"
    
    @IBOutlet var imageListTableView:UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for _ in 0  ..< 32  {
            imageList.append("http://www.p9soft.com/images/sample.jpg")
        }
        self.imageListTableView.register(UINib(nibName:"SampleTableViewCell", bundle:nil), forCellReuseIdentifier:cellIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.imageList.count
    }
    
    func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SampleTableViewCell = self.imageListTableView.dequeueReusableCell(withIdentifier: cellIdentifier)! as! SampleTableViewCell
        cell.data = self.imageList[indexPath.row]
        return cell
    }
    
}

