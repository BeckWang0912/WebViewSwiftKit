//
//  ASWebViewModel.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

import UIKit

class ASWebViewModel: NSObject {
    var aisURL: String?
    var filterWords: [String]?
    var backImage: UIImage?
    var closeImage: UIImage?
    var titleLimitLength: Int?

    override init() {
        super.init()
    }

    convenience init(url: String) {
        self.init()
        self.aisURL = url
        self.backImage = imageFromBundle(name: "back_normal")
        self.closeImage = imageFromBundle(name: "close_normal")
    }
}

extension ASWebViewModel {
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func webViewRequest() -> URLRequest? {
        if let url = aisURL,
            let myURL = URL(string: url){
            var myRequest = URLRequest(url: myURL)
            myRequest.timeoutInterval = 10
            return myRequest
        } else {
            return nil
        }
    }
    
    /// 作为 pod 第三方库取图片资源
    ///
    /// - Parameter name: 图片名
    /// - Returns: 图片
    func imageFromBundle(name: String) -> UIImage {
        let podBundle = Bundle(for: self.classForCoder)
        let bundleURL = podBundle.url(forResource: "resource", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)
        let image = UIImage(named: String(name), in: bundle, compatibleWith: nil)
        return image!
    }
}
