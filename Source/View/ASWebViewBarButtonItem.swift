//
//  ASWebViewBarButtonItem.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//
import UIKit

class ASWebViewBarButtonItem: UIBarButtonItem {
    // MARK: - init
    convenience init(image: UIImage, target: Any?, action: Selector?) {
        let barButton = UIButton()
        barButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        barButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        barButton.contentHorizontalAlignment = .left
        barButton.setImage(image, for: UIControlState())
        barButton.addTarget(target!, action: action!, for: .touchUpInside)
        self.init(customView: barButton)
    }
}
