//
//  ASWKWebViewProtocol.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//
import Foundation
import WebKit
import WebViewJavascriptBridge

public protocol ASWKWebViewProtocol: ASWebViewBaseProtocol {

}

// MARK: - js 交互
public protocol ASWKWebViewBridgeProtocol {

    /// 监测具体的 JS 事件名进行跳转
    ///
    /// - Parameters:
    ///   - bridgeName: JS 事情名
    ///   - viewController: 跳控制器
    func webViewPushController(_ bridgeName: String!, viewController: UIViewController)

    /// 监听 JS 事件名进行处理
    ///
    /// - Parameters:
    ///   - bridgeName: JS 事情名
    ///   - handler: 利用 JS 传过来的参数进行回调
    func registerBridgeHandler(_ bridgeName: String!, handler: WVJBHandler!)

    /// 调用 JS 方法
    ///
    /// - Parameters:
    ///   - bridgeName: JS 事情名
    ///   - data: 传数据
    func callBridgeHandler(_ bridgeName: String!, data: Any!)
}

//public protocol ASWKWebViewHelperProtocol {
//
//    /// 网页加载 -- URL
//    ///
//    /// - Parameter url: URL
//    func loadWebViewWithUrl(_ url: URL)
//
//    /// 网页加载 -- URL 字符串
//    ///
//    /// - Parameter urlString: URL 字符串
//    func loadWebViewWithUrlString(_ urlString: String)
//}

public protocol ASWKWebViewNavigationProtocol {

    /// 是否允许跳转回调 -- 子类重写
    ///
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - navigationAction: WKNavigationAction
    /// - Returns: Bool
    func aisWebView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) -> Bool

    /// 跳转失败回调
    ///
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - navigation: WKNavigation
    ///   - error: Error
    func aisWebView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)

    /// 完成加载回调
    ///
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - navigation: WKNavigation
    func aisWebView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
}
