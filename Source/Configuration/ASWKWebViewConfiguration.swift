//
//  ASWKWebViewConfiguration.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

import UIKit
import WebKit

public class ASWKWebViewConfiguration: WKWebViewConfiguration {
    public override init() {
        super.init()
        self.allowsInlineMediaPlayback = true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
