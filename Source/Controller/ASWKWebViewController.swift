//
//  ASWKWebViewController.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

/**
 注意:
 1. 因为重新定义了返回按钮, 所以需要在外面处理侧滑手势
 */

import UIKit
import WebKit
import SnapKit
import WebViewJavascriptBridge

public typealias ASWKWebFinishLoadingBlock = (ASWKWebViewController) -> Swift.Void
public typealias ASWKWebNavigationBackBlock = () -> Swift.Void
public typealias ASWKWebNavigationCloseBlock = ASWKWebNavigationBackBlock

open class ASWKWebViewController: UIViewController {

    // MARK: - 属性
    fileprivate var webViewBridge: WKWebViewJavascriptBridge!
    fileprivate var backButtonItem: ASWebViewBarButtonItem?
    fileprivate var closeButtonItem: ASWebViewBarButtonItem?
    fileprivate var spaceForLeftItem: UIBarButtonItem?
    @objc public var webView: ASWKWebView!

    public var backBlock: ASWKWebNavigationBackBlock?
    public var closeBlock: ASWKWebNavigationCloseBlock?
    public var finishBlock: ASWKWebFinishLoadingBlock?
    fileprivate var viewModel: ASWebViewModel?
    public var customTitle: String? {
        didSet {
            navigationItem.title = customTitle
        }
    }

    // MARK: - 初始化

    /// 初始化 webView 控制器
    ///
    /// - Parameters:
    ///   - locationURL: 链接地址字符串
    ///   - configuration: WKWebViewConfiguration
    public init(locationURL: String, configuration: WKWebViewConfiguration = ASWKWebViewConfiguration()) {
        super.init(nibName: nil, bundle: nil)
        webView = ASWKWebView(frame: .zero, webConfiguration: configuration, uiDelegate: self, navigationDelegate: self)
        viewModel = ASWebViewModel(url: locationURL)
        setupWebviewBridge()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - life Cycle
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []

        setupSubViews()
        setupObservers()
        loadRequest()
    }

    private func loadRequest() {
        let request = viewModel?.webViewRequest()
        if let req = request {
            webView.load(req)
        }
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: 初始化组件
    private func setupSubViews() {
        self.view.backgroundColor = UIColor.white
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        backButtonItem = ASWebViewBarButtonItem(image: (viewModel?.backImage)!, target: self, action: #selector(backAction))
        closeButtonItem = ASWebViewBarButtonItem(image: (viewModel?.closeImage)!, target: self, action: #selector(closeAction))
        spaceForLeftItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        navigationItem.setLeftBarButtonItems([backButtonItem!], animated: true)
    }

    private func setupWebviewBridge() {
        WKWebViewJavascriptBridge.enableLogging()
        webViewBridge = WKWebViewJavascriptBridge(for: self.webView)
        webViewBridge.setWebViewDelegate(self)
    }

    private func setupObservers() {
        addObserver(self, forKeyPath: #keyPath(webView.title), options: [.old, .new, .initial], context: nil)
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(webView.title) {
            if let title = customTitle {
                navigationItem.title = title
                return
            }
            if let limitLength = viewModel?.titleLimitLength {
                if let title = self.webView.title {
                    if title.count >= limitLength {
                        let index = title.index(title.startIndex, offsetBy: limitLength)
                        navigationItem.title = String(title[...index])
                    } else {
                        navigationItem.title = title
                    }
                }
            } else {
                navigationItem.title = self.webView.title
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // MARK: web 过滤
    private func filterBackItem() -> WKBackForwardListItem? {
        if let currentUrl = viewModel?.aisURL {
            if let filters = viewModel?.filterWords {
                for filter in filters where currentUrl.contains(filter) {
                    return nil
                }
                return webView.backForwardList.backList.first
            } else {
                return webView.backForwardList.backList.first
            }
        } else {
            return nil
        }
    }
    
    // MARK: - 返回 关闭
    @objc private func backAction() {
        if webView.canGoBack {
            let backItem = filterBackItem()
            if backItem != nil {
                self.webView.go(to: backItem!)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        if backBlock != nil {
            backBlock!()
        }
    }

    @objc private func closeAction() {
        navigationController?.popViewController(animated: true)
        if closeBlock != nil {
            closeBlock!()
        }
    }

    // MARK: 注销
    deinit {
        removeObserver(self, forKeyPath: #keyPath(webView.title))
        NotificationCenter.default.removeObserver(self)
        print("---\(self.classForCoder) is dealloc----")
    }
}

// MARK: - WKUIDelegate
extension ASWKWebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertVC = UIAlertController(title: "提醒", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: { (_) in
            completionHandler()
        }))
        self.present(alertVC, animated: true, completion: nil)
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertVC = UIAlertController(title: "确认框", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            completionHandler(true)
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            completionHandler(false)
        }))
        self.present(alertVC, animated: true, completion: nil)
    }

    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertVC = UIAlertController(title: "输入框", message: prompt, preferredStyle: .alert)
        alertVC.addTextField { (textField) in
            textField.backgroundColor = UIColor.orange
        }
        alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            completionHandler(alertVC.textFields?.last?.text)
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
}

// MARK: - WKNavigationDelegate
extension ASWKWebViewController: WKNavigationDelegate {
    final public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

    }

    final public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        let cred = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, cred)
    }

    final public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        var decision = self.aisWebView(webView, decidePolicyFor: navigationAction)
        guard decision != false else {
            decisionHandler(.cancel)
            return
        }
        let url: URL? = navigationAction.request.url
        if url != nil {
            if let scheme = url?.scheme, scheme == "tel" {
                DispatchQueue.main.async {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url!, options: [String: Any](), completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(url!)
                    }
                }
                decision = false
            } else {
                viewModel?.aisURL = url?.absoluteString
                decision = true
            }
        } else {
            decision = false
        }

        decision ? decisionHandler(.allow) : decisionHandler(.cancel)
    }

    final public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.aisWebView(webView, didFailProvisionalNavigation: navigation, withError: error)
    }

    final public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.canGoBack {
            navigationItem.setLeftBarButtonItems([backButtonItem!, closeButtonItem!, spaceForLeftItem!], animated: true)
        } else {
            navigationItem.setLeftBarButtonItems([backButtonItem!], animated: true)
        }

        webView.evaluateJavaScript("var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}") { (code, error) in
            print("\(code as? String ?? "")\(error.debugDescription)")
        }

        self.aisWebView(webView, didFinish: navigation)
        if self.finishBlock != nil {
            self.finishBlock!(self)
        }
    }
}

// MARK: - ASWWKWebViewProtocol
extension ASWKWebViewController: ASWKWebViewBridgeProtocol {
    public func webViewPushController(_ bridgeName: String!, viewController: UIViewController) {
        webViewBridge.registerHandler(bridgeName) { (response, _) in
            print("web view javascript bridge response = \(String(describing: response))")
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    public func registerBridgeHandler(_ bridgeName: String!, handler: WVJBHandler!) {
        webViewBridge.registerHandler(bridgeName, handler: handler)
    }

    public func callBridgeHandler(_ bridgeName: String!, data: Any!) {
        webViewBridge.callHandler(bridgeName, data: data) { (response) in
            print("web view javascript bridge response = \(String(describing: response))")
        }
    }
}

// MARK: - 提供给子类重写
extension ASWKWebViewController: ASWKWebViewNavigationProtocol {
    @objc open func aisWebView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) -> Bool {
        return true
    }

    @objc open func aisWebView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    }

    @objc open func aisWebView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
}

extension ASWKWebViewController: ASWKWebViewProtocol {
    public func loadWebViewWithUrl(_ url: URL) {
        viewModel?.aisURL = url.absoluteString
        let request = viewModel?.webViewRequest()
        if let req = request {
            webView.load(req)
        }
    }

    public func loadWebViewWithUrlString(_ urlString: String) {
        guard !urlString.isEmpty else { return }
        viewModel?.aisURL = urlString
        let request = viewModel?.webViewRequest()
        if let req = request {
            webView.load(req)
        }
    }

    public func configNavigationItemsImages(backImage: UIImage?, closeImage: UIImage?) {
        if backImage != nil {
            viewModel?.backImage = backImage
        }
        if closeImage != nil {
            viewModel?.closeImage = closeImage
        }
    }

    public func configProgressViewPropertys(_ propertys: [ASProgressViewProperty: AnyObject]) {
        guard !propertys.isEmpty else { return }
        for (propertyName, propertyValue) in propertys {
            switch propertyName {
            case .ASProgressTintColor:
                webView.progressView.progressTintColor = propertyValue as? UIColor
            case .ASTrackTintColor:
                webView.progressView.trackTintColor = propertyValue as? UIColor
            case .ASProgressImage:
                webView.progressView.progressImage = propertyValue as? UIImage
            case .ASTrackImage:
                webView.progressView.trackImage = propertyValue as? UIImage
            }
        }
    }

    public func configUrlFilterKeywords(_ words: [String]) {
        viewModel?.filterWords = words
    }

    public func configTitleLengthToShow(_ length: Int?) {
        if let limitLength = length, limitLength > 0 {
            viewModel?.titleLimitLength = limitLength
        }
    }
}

