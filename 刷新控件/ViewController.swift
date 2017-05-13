//
//  ViewController.swift
//  刷新控件
//
//  Created by 郭连城 on 2017/4/30.
//  Copyright © 2017年 郭连城. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    let refresh = LCRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableview.refreshControl = refresh
        // Do any additional setup after loading the view, typically from a nib.
        tableview.addSubview(refresh)
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    func loadData(){
        refresh.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) { 
            self.refresh.endRefreshing()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

