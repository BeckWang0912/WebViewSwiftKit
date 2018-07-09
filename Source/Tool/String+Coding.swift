//
//  String+Coding.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

import UIKit

extension String {
    // url 编码
    public func webUrlEncoded() -> String? {
        let encodeString = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return encodeString
    }

    // url 解码
    public func webUrlDecoded() -> String? {
        return self.removingPercentEncoding
    }
}
