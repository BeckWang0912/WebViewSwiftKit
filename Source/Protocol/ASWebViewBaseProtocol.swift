//
//  ASWebViewBaseProtocol.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

/** webView 基础协议*/
import UIKit

public enum ASProgressViewProperty {
    case ASProgressTintColor
    case ASTrackTintColor
    case ASProgressImage
    case ASTrackImage
}

public protocol ASWebViewBaseProtocol {

    // MARK: - load
    /// 网页加载 -- URL
    ///
    /// - Parameter url: URL
    func loadWebViewWithUrl(_ url: URL)

    /// 网页加载 -- URL 字符串
    ///
    /// - Parameter urlString: URL 字符串
    func loadWebViewWithUrlString(_ urlString: String)

    // MARK: - config
    /// 配置导航栏的返回和关闭图标
    ///
    /// - Parameters:
    ///   - backImage: UIImage
    ///   - closeImage: UIImage
    func configNavigationItemsImages(backImage: UIImage?, closeImage: UIImage?)

    /// 配置进度条属性
    ///
    /// - Parameter propertys: [.ASProgressTintColor: UIColor.red]
    func configProgressViewPropertys(_ propertys: [ASProgressViewProperty: AnyObject])

    /// 配置过滤关键字
    ///
    /// - Parameter words: array --> ["tencent", "baidu"]
    func configUrlFilterKeywords(_ words: [String])

    /// 控制导航栏标题显示长度
    ///
    /// - Parameter length: Int
    func configTitleLengthToShow(_ length: Int?)

    // MARK: - helper
    /// 监听通知
    ///
    /// - Parameters:
    ///   - name: NSNotification.Name
    ///   - block: 回调
    func addObserverWithName(_ name: NSNotification.Name?, using block: @escaping () -> Swift.Void)
}

extension ASWebViewBaseProtocol {
    public func addObserverWithName(_ name: NSNotification.Name?, using block: @escaping () -> Swift.Void) {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) {_ in
            block()
        }
    }
}

