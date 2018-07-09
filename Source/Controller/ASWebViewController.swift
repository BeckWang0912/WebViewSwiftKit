//
//  ASWebViewController.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

// UIWebView
import UIKit
import JavaScriptCore

public typealias ASUIWebFinishLoadingBlock = (ASWebViewController) -> Swift.Void
public typealias ASUIWebNavigationBackBlock = () -> Swift.Void
public typealias ASUIWebNavigationCloseBlock = ASUIWebNavigationBackBlock

public class ASWebViewController: UIViewController {
    private var context: JSContext?
    public var webView: ASWebView = ASWebView(frame: CGRect.zero)
    public var progressProxy: ASWebViewProgress = ASWebViewProgress()
    fileprivate var viewModel: ASWebViewModel?
    public var customTitle: String? {
        didSet {
            navigationItem.title = customTitle
        }
    }

    public var backBlock: ASUIWebNavigationBackBlock?
    public var closeBlock: ASUIWebNavigationCloseBlock?
    public var finishBlock: ASUIWebFinishLoadingBlock?

    fileprivate var backButtonItem: ASWebViewBarButtonItem?
    fileprivate var closeButtonItem: ASWebViewBarButtonItem?
    fileprivate var spaceForLeftItem: UIBarButtonItem?

    public init(locationURL: String) {
        super.init(nibName: nil, bundle: nil)

        viewModel = ASWebViewModel(url: locationURL)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupSubViews()
        setupDelegate()
        loadRequest()
    }

    func setupSubViews() {
        self.edgesForExtendedLayout = []
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        backButtonItem = ASWebViewBarButtonItem(image: (viewModel?.backImage)!, target: self, action: #selector(backAction))
        closeButtonItem = ASWebViewBarButtonItem(image: (viewModel?.closeImage)!, target: self, action: #selector(closeAction))
        spaceForLeftItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        navigationItem.setLeftBarButtonItems([backButtonItem!], animated: true)
    }

    func setupDelegate() {
        webView.delegate = progressProxy
        progressProxy.progressDelegate = self
        progressProxy.webViewProxyDelegate = self
    }

    private func loadRequest() {
        let request = viewModel?.webViewRequest()
        if let req = request {
            webView.loadRequest(req)
        }
    }

    // MARK: - GoBack & Close
    @objc private func backAction() {
        if webView.canGoBack {
            webView.goBack()
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

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        print("\(self.classForCoder) is deinit")
    }

}

// MARK: - ASWebViewProgressDelegate
extension ASWebViewController: ASWebViewProgressDelegate {
    public func webViewProgress(_ webViewProgress: ASWebViewProgress, updateProgress progress: Float) {
        webView.progressView.progress = progress
    }
}

// MARK: - UIWebViewDelegate
extension ASWebViewController: UIWebViewDelegate {
    public func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")
    }

    public func webViewDidFinishLoad(_ webView: UIWebView) {
        // jscore
        self.context = self.webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext

        // title
        if let title = customTitle {
            navigationItem.title = title
        } else {
            let htmlTitle = webView.stringByEvaluatingJavaScript(from: "document.title")
            if let title = htmlTitle,
                let limitLength = viewModel?.titleLimitLength,
                title.count >= limitLength {
                let index = title.index(title.startIndex, offsetBy: limitLength)
                navigationItem.title = String(title[...index])
            } else {
                navigationItem.title = htmlTitle
            }
        }

        // navigation
        if webView.canGoBack {
            navigationItem.setLeftBarButtonItems([backButtonItem!, closeButtonItem!, spaceForLeftItem!], animated: true)
        } else {
            navigationItem.setLeftBarButtonItems([backButtonItem!], animated: true)
        }

        // finish block
        if self.finishBlock != nil {
            self.finishBlock!(self)
        }
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error)
    }
}

// MARK: - ASUIWebViewJSProtocol
extension ASWebViewController: ASUIWebViewJSProtocol {
    public func registerBridgeHandler(_ name: String, handler: @escaping (String) -> Void) {
        guard let jsContext: JSContext = self.context else {
            return
        }

        // 第一种定义方式
        let swiftClosure: @convention(block) (String) -> Void = handler

        // 第二步: 将闭包快转换成一个 AnyObject 对象
        let swiftAnyObject = unsafeBitCast(swiftClosure, to: AnyObject.self)

        /**
         * 第三步: 将swiftAnyObject 传递给 jsContext
         * 将闭包块与JS进行关联, JavaScriptCallSwift就是即将要执行的JS方法, 这个方法会调用都到swift的原生代码
         */
        jsContext.setObject(swiftAnyObject, forKeyedSubscript: name as (NSCopying&NSObjectProtocol)?)
    }

    public func callBridgeHandler(_ name: String!, data: Any!) {
        let method = self.context?.objectForKeyedSubscript(name)
        _ = method?.call(withArguments: data as! [Any])
    }
}

// MARK: - ASUIWebViewProtocol
extension ASWebViewController: ASUIWebViewProtocol {
    public func loadWebViewWithUrl(_ url: URL) {
        viewModel?.aisURL = url.absoluteString
        let request = viewModel?.webViewRequest()
        if let req = request {
            webView.loadRequest(req)
        }
    }

    public func loadWebViewWithUrlString(_ urlString: String) {
        guard !urlString.isEmpty else { return }
        viewModel?.aisURL = urlString
        let request = viewModel?.webViewRequest()
        if let req = request {
            webView.loadRequest(req)
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
