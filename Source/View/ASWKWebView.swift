//
//  ASWKWebView.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

let AS_TOP_HEIGHT = 64
let AS_X_TOP_HEIGHT = 88
let AS_PROGRESSVIEW_HEIGHT = 2

open class ASWKWebView: WKWebView {

    var progressView = ASWebViewProgressView(style: .default, tintColor: UIColor.orange, trackTintColor: UIColor.lightGray)

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }

    public convenience init(frame: CGRect, webConfiguration: WKWebViewConfiguration, uiDelegate: Any?, navigationDelegate: Any?) {
        self.init(frame: frame, configuration: webConfiguration)

        self.uiDelegate = uiDelegate as? WKUIDelegate
        self.navigationDelegate = navigationDelegate as? WKNavigationDelegate
        self.allowsBackForwardNavigationGestures = true

        setupSubView()
        setupObservers()
    }

    func setupSubView() {
        self.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(AS_PROGRESSVIEW_HEIGHT)
        }
    }

    func setupObservers() {
        addObserver(self, forKeyPath: #keyPath(ASWKWebView.estimatedProgress), options: [.old, .new, .initial], context: nil)
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(ASWKWebView.estimatedProgress) {
            let progress: Float = Float(self.estimatedProgress)
            self.progressView.progress = progress
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeObserver(self, forKeyPath: #keyPath(ASWKWebView.estimatedProgress))
        print("---\(self.classForCoder) is dealloc----")
    }
}

