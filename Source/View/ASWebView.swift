//
//  ASWebView.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

/**
  *                                                         /---progressdelegate---vc
  *                                                        /
  * vc ---own--- uiwebview ---delegate--- uiwebviewprogress
  *                                                        \
  *                                                         \--webviewProxyDelegate---vc
 */

import UIKit

public class ASWebView: UIWebView {
    var progressView = ASWebViewProgressView(style: .default, tintColor: UIColor.orange, trackTintColor: UIColor.clear)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSubView() {
        self.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(AS_PROGRESSVIEW_HEIGHT)
        }
    }
}
