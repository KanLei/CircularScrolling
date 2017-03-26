//
//  SegmentPageControl.swift
//  CircularScroll
//
//  Created by KanLei on 26/03/2017.
//  Copyright © 2017 kanlei. All rights reserved.
//

import UIKit


/// 指示器风格 - - -
class SegmentPageControl: UIPageControl {
    
    private var segments = [UILabel]()
    
    override var numberOfPages: Int {
        didSet {
            setupSegments()
        }
    }
    
    override var currentPage: Int {
        didSet {
            updateCurrentPage()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for i in 0..<segments.count {
            segments[i].frame = CGRect(x: CGFloat(i * 15), y: self.bounds.height / 2, width: CGFloat(13) , height: CGFloat(5))
            segments[i].layer.cornerRadius = 2
            segments[i].layer.masksToBounds = true
        }
    }
    
    private func setupSegments() {
        segments.forEach { $0.removeFromSuperview() }
        segments.removeAll()
        
        for _ in 0..<numberOfPages {
            let lbl = UILabel()
            lbl.layer.cornerRadius = 2
            lbl.layer.masksToBounds = true
            lbl.backgroundColor = UIColor.white
            self.addSubview(lbl)
            segments.append(lbl)
        }
    }
    
    private func updateCurrentPage() {
        if 0 < segments.count && currentPage < segments.count {
            segments.forEach { $0.backgroundColor = UIColor.white }
            segments[currentPage].backgroundColor = UIColor.red
        }
    }
}
