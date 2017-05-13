//
//  LCRefreshView.swift
//  刷新控件
//
//  Created by 郭连城 on 2017/5/2.
//  Copyright © 2017年 郭连城. All rights reserved.
//

import UIKit

class LCRefreshView: UIView {
    var refreshState : LCRefreshState = .normal{
        didSet{
            switch refreshState {
            case .normal:
                tipIcon?.isHidden = false
                indicator?.stopAnimating()
                
                tipLabel.text = "继续使劲拉"
                UIView.animate(withDuration: 0.5){
                    self.tipIcon?.transform = CGAffineTransform.identity
                }
                break
            case .pulling:
                UIView.animate(withDuration: 0.5, animations: {
                    self.tipIcon?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi-0.001))
                })
                tipLabel.text = "放手就刷新"
                break
            case .willRefresh:
                tipLabel.text = "正在刷新"
                tipIcon?.isHidden = true
                indicator?.startAnimating()
                break
            }
        }
    }
    /// 指示器
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    /// 提示图标
    @IBOutlet weak var tipIcon: UIImageView?
    /// 提示标签
    @IBOutlet weak var tipLabel: UILabel!

    class func refreshView() -> LCRefreshView {
        
        let nib = UINib(nibName: "LCRefreshView", bundle: nil)
        
        return nib.instantiate(withOwner: nil, options: nil)[0] as! LCRefreshView
    }
    override func awakeFromNib() {
        backgroundColor = UIColor.clear
    }
}
