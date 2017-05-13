//
//  LCRefreshControl.swift
//  刷新控件
//
//  Created by 郭连城 on 2017/4/30.
//  Copyright © 2017年 郭连城. All rights reserved.
//

import UIKit
/// 刷新状态切换的临界点
private let LCRefreshOffset: CGFloat = 126
/// 刷新状态
///
/// - Normal:      普通状态，什么都不做
/// - Pulling:     超过临界点，如果放手，开始刷新
/// - WillRefresh: 用户超过临界点，并且放手
enum LCRefreshState {
    case normal
    case pulling
    case willRefresh
}
class LCRefreshControl: UIControl {
    
    // MARK: - 属性
    /// 刷新控件的父视图，下拉刷新控件应该适用于 UITableView / UICollectionView
    private weak var scrollView: UIScrollView?
    /// 刷新视图
    private lazy var refreshView: LCRefreshView = LCRefreshView.refreshView()
    
    // MARK: - 构造函数
    init() {
        super.init(frame: CGRect())
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        
        // 判断父视图的类型
        guard let sv = newSuperview as? UIScrollView else {
            return
        }
        
        // 记录父视图
        scrollView = sv
        
        // KVO 监听父视图的 contentOffset
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    // 本视图从父视图上移除
    // 提示：所有的下拉刷新框架都是监听父视图的 contentOffset
    // 所有的框架的 KVO 监听实现思路都是这个！
    override func removeFromSuperview() {
        // superView 还存在
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        
        super.removeFromSuperview()
        
        // superView 不存在
    }
    // 所有 KVO 方法会统一调用此方法
    // 在程序中，通常只监听某一个对象的某几个属性，如果属性太多，方法会很乱！
    // 观察者模式，在不需要的时候，都需要释放
    // - 通知中心：如果不释放，什么也不会发生，但是会有内存泄漏，会有多次注册的可能！
    // - KVO：如果不释放，会崩溃！
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // contentOffset 的 y 值跟 contentInset 的 top 有关
        //print(scrollView?.contentOffset)
        
        guard let sv = scrollView else {
            return
        }
        
        // 初始高度就应该是 0
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        
        if height < 0 {
            return
        }
        
        // 可以根据高度设置刷新控件的 frame
        self.frame = CGRect(x: 0,
                            y: -height,
                            width: sv.bounds.width,
                            height: height)
        //判断临界点
        if sv.isDragging {
            
            if height>LCRefreshOffset && refreshView.refreshState == .normal{
                print("放手刷新")
                refreshView.refreshState = .pulling
            }else if height<=LCRefreshOffset && refreshView.refreshState == .pulling{
                refreshView.refreshState = .normal
                print("在下拉")
            }
            
        }else{
            if refreshView.refreshState == .pulling {
                print("正在刷新")
               beginRefreshing()
               sendActions(for: .valueChanged)
            }
        }
        
    }
    
    
    
    open func beginRefreshing(){
        guard let sv = scrollView else {
            return
        }
        if refreshView.refreshState == .willRefresh{
            return
        }
        refreshView.refreshState = .willRefresh
        
        var inset = sv.contentInset
        inset.top += LCRefreshOffset
        
        sv.contentInset = inset
        
    }
    
    // Must be explicitly called when the refreshing has completed
    
    open func endRefreshing(){
        guard  let sv = scrollView else {
            return
        }
        if refreshView.refreshState != .willRefresh{
            return
        }
        refreshView.refreshState = .normal
        
        var inset = sv.contentInset
        inset.top -= LCRefreshOffset
        
        sv.contentInset = inset
    }
    
    
    func setupUI(){
        backgroundColor = superview?.backgroundColor
        
        // 添加刷新视图 - 从 xib 加载出来，默认是 xib 中指定的宽高
        addSubview(refreshView)
        
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.width))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.height))
    }
}
