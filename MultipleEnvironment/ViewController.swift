//
//  ViewController.swift
//  MultipleEnvironment
//
//  Created by 雷广 on 2018/7/26.
//  Copyright © 2018年 雷广. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        #if dev
        print("dev")
        #elseif adhoc
        print("adhoc")
        #elseif appstore
        print("appstore")
        #endif
        
        
        
        #if dev && DEBUG
        print("dev && debug")
        #endif
        
        
        
        #if dev || adhoc
        print("dev || adhoc")
        #else
        print("appstore")
        #endif
    }
}

