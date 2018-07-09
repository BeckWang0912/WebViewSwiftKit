//
//  ViewController.swift
//  WebView
//
//  Created by Aissen on 2018/7/8.
//  Copyright © 2018年 aissen.intl. All rights reserved.
//

import UIKit
import SafariServices
import WebViewJavascriptBridge

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bridge: WebViewJavascriptBridge!
    var tableView: UITableView!
    
    var arrayItems: [String] = [
        "UIWebViewController",
        "WKWebViewController",
        "SFSafariViewController",
        "js调用native注册",
        "native调用js获取用户信息",
        "native调用js弹窗输出",
        "native调用js插入图片",
        "native调用js界面跳转",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.lightGray
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18), NSAttributedStringKey.foregroundColor: UIColor.white]
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        view.addSubview(tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath as IndexPath)
        cell.textLabel?.text = arrayItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            jumpUIWeb()
        case 1:
            jumpWKWeb()
        case 2:
            jumpSFWeb()
        case 3:
            loadIndex()
        case 4:
            getUserInfo()
        case 5:
            alterJs()
        case 6:
            insertImgToWebPage()
        case 7:
            pushJsView()
        default:
            return
        }
    }
}

extension ViewController {
    
    func jumpUIWeb() {
        let webVC = ASWebViewController(locationURL: "https://mp.weixin.qq.com/s/sIM7CSoKyDUWMXe8Z0dM7A")
        webVC.view.backgroundColor = UIColor.white
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    func jumpWKWeb() {
        let webVC = ASWKWebViewController(locationURL: "https://mp.weixin.qq.com/s/sIM7CSoKyDUWMXe8Z0dM7A")
        webVC.customTitle = "自定义标题"
        webVC.view.backgroundColor = UIColor.white
        let tintColor = UIColor(red: 22 / 255.0, green: 126 / 255.0, blue: 251 / 255.0, alpha: 1.0)
        webVC.configProgressViewPropertys([.ASTrackTintColor: UIColor.clear, .ASProgressTintColor: tintColor])
        webVC.configTitleLengthToShow(10)
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    func jumpSFWeb() {
        let url = URL(string: "https://mp.weixin.qq.com/s/sIM7CSoKyDUWMXe8Z0dM7A")
        if #available(iOS 9.0, *) {
            let a = ASSafariViewController.init(url: url!)
            self.present(a, animated: true)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func loadIndex() {
        let webView = UIWebView.init(frame: CGRect(x: 0, y: 400, width: self.view.bounds.size.width, height: 200))
        let bundleURL = Bundle.main.path(forResource: "index", ofType: "html")
        do {
            let htmlString = try NSString.init(contentsOfFile: bundleURL!, encoding: String.Encoding.utf8.rawValue)
            webView.loadHTMLString(htmlString as String  , baseURL: NSURL.fileURL(withPath: bundleURL!))
            self.view.addSubview(webView)
        } catch {
            
        }
        
        WebViewJavascriptBridge.enableLogging()
        bridge = WebViewJavascriptBridge.init(forWebView: webView)
        bridge.setWebViewDelegate(self)
        
        jsCallNative()
    }
    
    // js调用native
    func jsCallNative() {
        bridge.registerHandler("openCamera") { (data, responseCallback) in
            let imageVC = UIImagePickerController.init()
            imageVC.sourceType = .photoLibrary
            self.present(imageVC, animated: true, completion: nil)
        }
        
        bridge.registerHandler("showSheet") { (data, responseCallback) in
            print("调用native的弹窗")
        }
    }
    
    // native调用JS中的API
    func getUserInfo() {
        bridge.callHandler("getUserInfo", data: ["userId":"DX001"]) { (responseData) in
            print(responseData as Any)
        }
    }
    
    // native调用JS中的alter
    func alterJs() {
        bridge.callHandler("alertMessage", data: "调用了js中的Alert弹窗!") { (responseData) in
            print(responseData as Any)
        }
    }
    
    // native调用JS中的push
    func pushJsView() {
        bridge.callHandler("pushToNewWebSite", data: ["url":"http://m.jd.com"]) { (responseData) in
            print(responseData as Any)
        }
    }
    
    // native调用JS中的method
    func insertImgToWebPage() {
        let dict = ["url" : "https://avatars2.githubusercontent.com/u/26214723?s=400&u=4514b66c2fb532639c1532d5d74cfb471a9ec0fb&v=4"]
       
        bridge.callHandler("pushToNewWebSite", data: dict) { (responseData) in
            print(responseData as Any)
        }
    }
}

