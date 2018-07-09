//
//  ASWebViewProgress.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

import UIKit

public protocol ASWebViewProgressDelegate: class {
    func webViewProgress(_ webViewProgress: ASWebViewProgress, updateProgress progress: Float)
}

public class ASWebViewProgress: NSObject {
    public weak var progressDelegate: ASWebViewProgressDelegate?
    public weak var webViewProxyDelegate: UIWebViewDelegate?
    public var progress: Float = 0

    fileprivate var loadingCount: Int?
    fileprivate var maxLoadCount: Int?
    fileprivate var currentUrl: URL?
    fileprivate var interactive: Bool?
    fileprivate let completePRCURLPath = "/aiswebviewprogressproxy/complete"

    private let InitialProgressValue: Float = 0.1
    private let InteractiveProgressValue: Float = 0.5
    private let FinalProgressValue: Float = 0.9

    // MARK: - Init
    override public init() {
        super.init()
        maxLoadCount = 0
        loadingCount = 0
        interactive = false
    }

    fileprivate func startProgress() {
        if progress < InitialProgressValue {
            setProgress(InitialProgressValue)
        }
    }

    fileprivate func incrementProgress() {
        var progress = self.progress
        let maxProgress = interactive == true ? FinalProgressValue : InteractiveProgressValue
        let remainPercent = Float(Float(loadingCount ?? 0) / Float(maxLoadCount ?? 1))
        let increment = (maxProgress - progress) * remainPercent
        progress += increment
        progress = fminf(progress, maxProgress)
        setProgress(progress)
    }

    fileprivate func completeProgress() {
        setProgress(1.0)
    }

    fileprivate func setProgress(_ progress: Float) {
        guard progress > self.progress || progress == 0 else { return }
        self.progress = progress
        progressDelegate?.webViewProgress(self, updateProgress: progress)
    }

    public func reset() {
        maxLoadCount = 0
        loadingCount = 0
        interactive = false
        setProgress(0.0)
    }
}

extension ASWebViewProgress: UIWebViewDelegate {
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url else { return false }
        if url.path == completePRCURLPath {
            completeProgress()
            return false
        }

        var finalReturn = true
        if webViewProxyDelegate != nil && webViewProxyDelegate!.responds(to: #selector(UIWebViewDelegate.webView(_:shouldStartLoadWith:navigationType:))) {
            finalReturn = webViewProxyDelegate?.webView?(webView, shouldStartLoadWith: request, navigationType: navigationType) ?? false
        }

        // fragment解释: http://www.ruanyifeng.com/blog/2011/03/url_hash.html
        var isFragmentJump = false
        if let fragmentURL = url.fragment {
            let nonFragmentURL = url.absoluteString.replacingOccurrences(of: "#"+fragmentURL, with: "")
            isFragmentJump = nonFragmentURL == url.absoluteString
        }

        let isTopLevelNavigation = request.mainDocumentURL == url
        let isHTTP = (url.scheme == "http" || url.scheme == "https")
        if finalReturn && !isFragmentJump && isHTTP && isTopLevelNavigation {
            currentUrl = request.url
            reset()
        }

        return finalReturn
    }

    public func webViewDidStartLoad(_ webView: UIWebView) {
        if webViewProxyDelegate != nil && webViewProxyDelegate!.responds(to: #selector(UIWebViewDelegate.webViewDidStartLoad(_:))) {
            webViewProxyDelegate?.webViewDidStartLoad!(webView)
        }

        if let loadingCount = loadingCount {
            self.loadingCount = loadingCount + 1
        }

        maxLoadCount = Int(fmax(Double(maxLoadCount ?? 0), Double(loadingCount ?? 0)))
        startProgress()
    }

    public func webViewDidFinishLoad(_ webView: UIWebView) {
        if webViewProxyDelegate != nil  && webViewProxyDelegate!.responds(to: #selector(UIWebViewDelegate.webViewDidFinishLoad(_:))) {
            webViewProxyDelegate?.webViewDidFinishLoad!(webView)
        }

        if let loadingCount = loadingCount {
            self.loadingCount = loadingCount - 1
        }
        incrementProgress()

        let readyState = webView.stringByEvaluatingJavaScript(from: "document.readyState")

        let interactive = readyState == "interactive"
        if interactive {
            self.interactive = true
            let waitForCompleteJS = "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(String(describing: webView.request?.mainDocumentURL?.scheme))://\(String(describing: webView.request?.mainDocumentURL?.host))\(completePRCURLPath)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScript(from: waitForCompleteJS)
        }

        let isNotRedirect: Bool
        if let currentUrl = currentUrl {
            isNotRedirect = currentUrl == webView.request?.mainDocumentURL
        } else {
            isNotRedirect = false
        }

        let complete = readyState == "complete"
        if complete && isNotRedirect {
            completeProgress()
        }
    }

    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if webViewProxyDelegate != nil && webViewProxyDelegate!.responds(to: #selector(UIWebViewDelegate.webView(_:didFailLoadWithError:))) {
            webViewProxyDelegate?.webView!(webView, didFailLoadWithError: error)
        }

        if let loadingCount = loadingCount {
            self.loadingCount = loadingCount - 1
        }
        incrementProgress()

        let readyState = webView.stringByEvaluatingJavaScript(from: "document.readyState")
        let interactive = readyState == "interactive"
        if interactive {
            self.interactive = true
            let waitForCompleteJS = "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(String(describing: webView.request?.mainDocumentURL?.scheme))://\(String(describing: webView.request?.mainDocumentURL?.host))\(completePRCURLPath)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScript(from: waitForCompleteJS)
        }

        let isNotRedirect: Bool
        if let currentUrl = currentUrl {
            isNotRedirect = currentUrl == webView.request?.mainDocumentURL
        } else {
            isNotRedirect = false
        }

        let complete = readyState == "complete"
        if complete && isNotRedirect {
            completeProgress()
        }
    }
}
