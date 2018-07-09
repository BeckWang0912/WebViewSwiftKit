//
//  ASSafariViewControllerProtocol.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

import SafariServices

@available(iOS 9.0, *)
public protocol ASSafariViewControllerProtocol {

    /// 点击按钮
    ///
    /// - Parameter controller: SFSafariViewController
    func aisSafariViewControllerDidFinish(_ controller: SFSafariViewController)

    /// 加载完成
    ///
    /// - Parameters:
    ///   - controller: SFSafariViewController
    ///   - didLoadSuccessfully: Bool
    func aisSafariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool)
}
