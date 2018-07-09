//
//  ASSafariViewController.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

import UIKit
import SafariServices

@available(iOS, introduced: 9.0, message: "Please use after iOS 9.0")
open class ASSafariViewController: SFSafariViewController {

    init(url: URL) {
        if #available(iOS 11.0, *) {
            super.init(url: url, configuration: SFSafariViewController.Configuration())
        } else {
            super.init(url: url, entersReaderIfAvailable: false)
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        // Do any additional setup after loading the view.
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

@available(iOS 9.0, *)
extension ASSafariViewController: SFSafariViewControllerDelegate {

    final public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        aisSafariViewControllerDidFinish(controller)
    }

    final public func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        aisSafariViewController(controller, didCompleteInitialLoad: didLoadSuccessfully)
    }
}

@available(iOS 9.0, *)
extension ASSafariViewController: ASSafariViewControllerProtocol {

    public func aisSafariViewControllerDidFinish(_ controller: SFSafariViewController) {
    }

    public func aisSafariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
    }
}
