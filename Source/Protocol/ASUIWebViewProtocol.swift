//
//  ASUIWebViewProtocol.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

import Foundation

public protocol ASUIWebViewProtocol: ASWebViewBaseProtocol {

}

public protocol ASUIWebViewJSProtocol {

    /// js 调用原生
    ///
    /// - Parameters:
    ///   - name: 方法名
    ///   - handler: 回调
    func registerBridgeHandler(_ name: String, handler: @escaping (String) -> Void)

    /// 原生调用JS
    ///
    /// - Parameters:
    ///   - bridgeName: js方法名
    ///   - data: 数据
    func callBridgeHandler(_ name: String!, data: Any!)
}


