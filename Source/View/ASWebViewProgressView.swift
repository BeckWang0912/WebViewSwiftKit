//
//  ASWebViewProgressView.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
///

import UIKit

let barAnimationDuration = 0.27
let fadeAnimationDuration = 0.27
let fadeOutDelay = 0.1

public class ASWebViewProgressView: UIProgressView {

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override public var progress: Float {
        didSet {
            setProgress(progress, animated: true)
        }
    }

    convenience init(style: UIProgressViewStyle = .default, tintColor: UIColor = UIColor.orange, trackTintColor: UIColor = UIColor.lightGray) {
        self.init(frame: CGRect.zero)
        self.progressViewStyle = style
        self.tintColor = tintColor
        self.trackTintColor = trackTintColor
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func setProgress(_ progress: Float, animated: Bool) {
        if progress == 1 {
            UIView.animate(withDuration: animated ? fadeAnimationDuration : 0, delay: fadeOutDelay, options: .curveEaseInOut, animations: { [weak self] in
                self?.alpha = 0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: animated ? fadeAnimationDuration : 0, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                self?.alpha = 1
            }, completion: nil)
        }
    }
}
