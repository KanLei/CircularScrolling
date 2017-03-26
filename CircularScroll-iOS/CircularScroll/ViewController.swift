//
//  ViewController.swift
//  CircularScroll
//
//  Created by KanLei on 25/03/2017.
//  Copyright © 2017 kanlei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dotStyleScrollBanner: ScrollBanner!
    @IBOutlet weak var numberStyleScrollBanner: ScrollBanner!
    @IBOutlet weak var customStyleScrollBanner: ScrollBanner!

    private let urls = ["https://c2.staticflickr.com/8/7140/8153507018_7407c28481_b.jpg" : "1",
                        "https://c1.staticflickr.com/3/2141/32144086123_24cde86fd8_b.jpg" : "2",
                        "https://c2.staticflickr.com/6/5046/5319460042_8b719c69d7_b.jpg": "3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dotStyleScrollBanner.isAutoScrollEnable = true
        dotStyleScrollBanner.imagesDict = urls
        
        numberStyleScrollBanner.pageIndicatorStyle = .number
        numberStyleScrollBanner.isAutoScrollEnable = true
        numberStyleScrollBanner.imagesDict = urls
        
        customStyleScrollBanner.pageIndicatorStyle = .custom
        customStyleScrollBanner.isAutoScrollEnable = true
        customStyleScrollBanner.customPageControl = SegmentPageControl()
        customStyleScrollBanner.imagesDict = urls
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

}

