//
//  ViewController.swift
//  Demo
//
//  Created by Felix Zhu on 15/11/23.
//  Copyright © 2015年 Felix Zhu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let button = UIButton(frame: CGRect(x: 0, y: 200, width: 100, height: 20))
        let button = UIButton()
        button.setTitle("Show Web", forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: "click:", forControlEvents: .TouchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        self.view.addConstraints([
            NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 0.66, constant: 0),
            ])
    }
    
    
    internal func click(sender: AnyObject) {
        NSLog("will show web controller")
        
        let controller = FZWebViewController()
        controller.url = "https://www.github.com"
//        controller.url = "https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener"
//        controller.url = "https://www.google.com"
//        controller.url = "https://baidu.com/"
        controller.url = "https://91yungou.cn"
        self.navigationController?.pushViewController(controller, animated: true)
    }
}