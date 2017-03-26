//
//  ScrollBanner.swift
//  CircularScroll
//
//  Created by KanLei on 25/03/2017.
//  Copyright © 2017 kanlei. All rights reserved.
//


import UIKit
import SnapKit


/// 图片指示器风格
/// dot    : ...
/// number : 1/5
/// custom : ***
enum IndicatorStyle {
    case dot
    case number
    case custom
}

/// 滚动条幅: 发现首页
class ScrollBanner: UIView {
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    
    // MARK: Properties
    
    private var timer: Timer?
    private var currentImageIndex = 0
    private var pageControl: UIView?
    fileprivate let mainScrollView = UIScrollView()
    private let mainContentView = UIView()
    fileprivate let screenWidth = UIScreen.main.bounds.width
    private let imageViewCount = 3
    
    private lazy var previousIV: UIImageView = {
        return self.createImageView()
    }()
    private lazy var currentIV: UIImageView = {
        return self.createImageView()
    }()
    private lazy var nextIV: UIImageView = {
        return self.createImageView()
    }()
    
    // 获取 [图片地址 : 导向地址] 中图片地址集合
    private var imagesUrl: [String] {
        return [String](imagesDict.keys)
    }
    
    // 获取图片数量
    var imagesCount: Int {
        return imagesDict.count
    }
    
    /// [图片地址 : 导向地址]
    var imagesDict = [String: String]() {
        didSet {
            resetScrollImages()
        }
    }
    
    /// 点击图片执行
    var imageTap: ((String) -> Void)?
    
    /// 轮播点默认颜色
    var pageIndicatorColor = UIColor.white
    
    /// 当前轮播点的颜色
    var currentPageIndicatorColor = UIColor.red
    
    /// 图片指示器风格
    var pageIndicatorStyle: IndicatorStyle = .dot
    
    /// 自定义 pageControl，需设置 pageIndicatorStyle = .custom
    var customPageControl: UIPageControl? {
        willSet {
            pageIndicatorStyle = .custom
            pageIndicatorColor = .clear
            currentPageIndicatorColor = .clear
        }
    }
    
    /// 是否开启自动滚动
    var isAutoScrollEnable: Bool = false {
        didSet{
            if isAutoScrollEnable {
                startAutoScrollImages()
            } else {
                stopAutoScrollImages()
            }
        }
    }
    
    /// 滚动时间间隔
    var interval: TimeInterval = 4 {
        didSet {
            startAutoScrollImages()
        }
    }
    
    /// 当前显示图片索引值
    var currentIndex: Int {
        return currentImageIndex
    }
    
    /// 当前 ScrollView
    var scrollView: UIScrollView {
        return mainScrollView
    }
    
    /// ScrollView 滑动通知回调
    var didScroll: (() -> Void)?
    
    private func initialize() {
        setupMainScrollView()
        setupMainContentView()
        setupImageViews()
        setuptapGesture()
    }
    
    private func setupMainScrollView() {
        mainScrollView.delegate = self
        mainScrollView.bounces = false
        mainScrollView.isPagingEnabled = true
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.scrollsToTop = false
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(mainScrollView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]|", options: .directionLeadingToTrailing, metrics: nil, views: ["scrollview": mainScrollView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .directionLeadingToTrailing, metrics: nil, views: ["scrollview": mainScrollView]))
    }
    
    private func setupMainContentView() {
        mainContentView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.addSubview(mainContentView)
        
        mainContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            
            // 约束 mainScrollView 的 contentSize
            make.width.equalToSuperview().multipliedBy(imageViewCount)
            make.height.equalToSuperview()
        }
    }
    
    private func setuptapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageViewTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func imageViewTap(_ sender: UITapGestureRecognizer) {
        if let linkUrl = currentIV.accessibilityLabel {
            imageTap?(linkUrl)
        }
    }
    
    // 根据当前图片资源，重置图片滚动
    private func resetScrollImages() {
        stopAutoScrollImages()
        resetImageViews()
        setupPageControl()
        
        mainScrollView.contentOffset = CGPoint(x: screenWidth, y: 0)
    }
    
    // 关闭自动滚动
    fileprivate func stopAutoScrollImages() {
        timer?.invalidate()
    }
    
    private func resetImageViews() {
        
        if imagesCount >= 3 {
            mainScrollView.isScrollEnabled = true
            configImageUrl(imageView: previousIV, urlString: imagesUrl[imagesCount - 1])
            configImageUrl(imageView: currentIV, urlString: imagesUrl[0])
            currentImageIndex = 0;
            configImageUrl(imageView: nextIV, urlString: imagesUrl[1])
            startAutoScrollImages()
        } else if imagesCount == 2 {
            mainScrollView.isScrollEnabled = true
            configImageUrl(imageView: previousIV, urlString: imagesUrl[1])
            configImageUrl(imageView: currentIV, urlString: imagesUrl[0])
            currentImageIndex = 0;
            configImageUrl(imageView: nextIV, urlString: imagesUrl[1])
            startAutoScrollImages()
        } else {
            mainScrollView.isScrollEnabled = false
            configImageUrl(imageView: currentIV, urlString: imagesUrl[0])
            currentImageIndex = 0
        }
    }
    
    @objc private func startScroll() {
        mainScrollView.setContentOffset(CGPoint.zero, animated: false)
        
        configImageUrl(imageView: previousIV, urlString: imagesUrl[currentImageIndex])
        increaseImageIndex()
        configImageUrl(imageView: currentIV, urlString: imagesUrl[currentImageIndex])
        increaseImageIndex()
        configImageUrl(imageView: nextIV, urlString: imagesUrl[currentImageIndex])
        
        mainScrollView.setContentOffset(CGPoint(x: screenWidth, y: 0), animated: true)
        
        decreaseImageIndex()
        decreasePage()
    }
    
    
    // 开启自动滚动
    fileprivate func startAutoScrollImages() {
        stopAutoScrollImages()
        
        if imagesCount > 1 && isAutoScrollEnable {
            timer = Timer.scheduledTimer(timeInterval: interval /* 延迟 interval 秒 */, target: self, selector: #selector(self.startScroll), userInfo: nil, repeats: true)
        }
    }
    
    private func removePageControl() {
        pageControl?.removeFromSuperview()
    }
    
    private func removeImageViews() {
        mainContentView.subviews.forEach {
            v in v.removeFromSuperview()
        }
    }
    
    private func setupImageViews() {
        mainContentView.addSubview(previousIV)
        mainContentView.addSubview(currentIV)
        mainContentView.addSubview(nextIV)
        
        previousIV.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        currentIV.snp.makeConstraints { make in
            make.left.equalTo(previousIV.snp.right)
            make.centerY.equalTo(previousIV.snp.centerY)
            make.size.equalTo(previousIV.snp.size)
        }
        
        nextIV.snp.makeConstraints { make in
            make.left.equalTo(currentIV.snp.right)
            make.centerY.equalTo(currentIV.snp.centerY)
            make.size.equalTo(currentIV.snp.size)
            make.right.equalToSuperview()
        }
    }
    
    func createImageView() -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }
    
    private func configImageUrl(imageView: UIImageView, urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        imageView.sd_setImage(with: url, placeholderImage: nil)
        
        if let linkUrl = imagesDict[urlString] {
            imageView.accessibilityLabel = linkUrl   // 临时存储图片导向链接地址
        }
    }
    
    
    // MARK: Scroll
    
    // 左滑
    fileprivate func scrollLeft() {
        configImageUrl(imageView: previousIV, urlString: imagesUrl[currentImageIndex])
        increaseImageIndex()
        configImageUrl(imageView: currentIV, urlString: imagesUrl[currentImageIndex])
        increaseImageIndex()
        configImageUrl(imageView: nextIV, urlString: imagesUrl[currentImageIndex])
        
        mainScrollView.setContentOffset(CGPoint(x: screenWidth, y: 0), animated: false)
        decreaseImageIndex()
        decreasePage()
    }
    
    // 右滑
    fileprivate func scrollRight() {
        configImageUrl(imageView: nextIV, urlString: imagesUrl[currentImageIndex])
        decreaseImageIndex()
        configImageUrl(imageView: currentIV, urlString: imagesUrl[currentImageIndex])
        decreaseImageIndex()
        configImageUrl(imageView: previousIV, urlString: imagesUrl[currentImageIndex])
        
        mainScrollView.setContentOffset(CGPoint(x: screenWidth, y: 0), animated: false)
        increaseImageIndex()
        increasePage()
    }
    
    
    private func setupPageControl() {
        removePageControl()
        
        switch pageIndicatorStyle {
        case .dot:
            setupDotPageControl()
        case .number:
            setupNumberPageControl()
        case .custom:
            setupCustomPageControl()
        }
    }
    
    // 指示器风格 ...
    private func setupDotPageControl() {
        pageControl = UIPageControl()
        let pc = pageControl as! UIPageControl
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.numberOfPages = imagesCount
        pc.pageIndicatorTintColor = pageIndicatorColor
        pc.currentPageIndicatorTintColor = currentPageIndicatorColor
        pc.currentPage = 0
        pc.isHidden = (imagesCount <= 1)
        self.insertSubview(pc, aboveSubview: mainScrollView)
        
        pc.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
        }
    }
    
    // 指示器风格: 1/5
    private func setupNumberPageControl() {
        pageControl = UIButton(type: .custom)
        let pc = pageControl as! UIButton
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.layer.cornerRadius = 10
        pc.layer.masksToBounds = true
        pc.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        pc.setTitleColor(UIColor.white, for: .normal)
        pc.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        pc.setTitle("1/\(imagesCount)", for: .normal)
        self.insertSubview(pc, aboveSubview: mainScrollView)
        
        pc.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(20)
            make.width.equalTo(pc.snp.height).multipliedBy(2)
        }
    }
    
    // 自定义风格指示器
    private func setupCustomPageControl() {
        guard let pc = customPageControl else {
            setupDotPageControl()
            return
        }
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.numberOfPages = imagesCount
        pc.pageIndicatorTintColor = pageIndicatorColor
        pc.currentPageIndicatorTintColor = currentPageIndicatorColor
        pc.currentPage = 0
        pc.isHidden = (imagesCount <= 1)
        self.insertSubview(pc, aboveSubview: mainScrollView)
        
        pc.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
        }
        
        pageControl = pc
    }
    
    // MARK: Override Methods
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        stopAutoScrollImages()
    }
    
    private func increaseImageIndex() {
        currentImageIndex = (currentImageIndex + 1) % imagesCount
    }
    
    private func decreaseImageIndex() {
        currentImageIndex = (currentImageIndex - 1 + imagesCount) % imagesCount
    }
    
    private func increasePage() {
        switch pageIndicatorStyle {
        case .dot, .custom:
            let pc = pageControl as! UIPageControl
            pc.currentPage = (pc.currentPage - 1 + pc.numberOfPages) % pc.numberOfPages
        case .number:
            let pc = pageControl as! UIButton
            let firstNumber = pc.title(for: .normal)?.components(separatedBy: "/").first
            let number = Int(firstNumber!)! - 1  // -1 是由于 Indicator 显示从 1 开始
            let i = ((number - 1 + imagesCount) % imagesCount ) + 1
            pc.setTitle("\(i)/\(imagesCount)", for: .normal)
        }
    }
    
    private func decreasePage() {
        switch pageIndicatorStyle {
        case .dot, .custom:
            let pc = pageControl as! UIPageControl
            pc.currentPage = (pc.currentPage + 1) % pc.numberOfPages
        case .number:
            let pc = pageControl as! UIButton
            let firstNumber = pc.title(for: .normal)?.components(separatedBy: "/").first
            let number = Int(firstNumber!)! - 1  // -1 是由于 Indicator 显示从 1 开始
            let i = ((number + 1) % imagesCount ) + 1
            pc.setTitle("\(i)/\(imagesCount)", for: .normal)
        }
    }
}


// MARK: UIScrollViewDelegate

extension ScrollBanner: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScrollImages()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startAutoScrollImages()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if imagesCount <= 1 {
            return
        }
        
        if scrollView.isDragging || scrollView.isDecelerating {
            if mainScrollView.contentOffset.x >= screenWidth * 2 {
                scrollLeft()
            } else if(mainScrollView.contentOffset.x <= 0) {
                scrollRight()
            }
        }
        
        didScroll?()
    }
}
