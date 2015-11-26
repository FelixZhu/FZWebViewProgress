//
//  FZWebViewController.swift
//  Demo
//
//  Created by Felix Zhu on 15/11/24.
//  Copyright © 2015年 Felix Zhu. All rights reserved.
//

import UIKit

public class FZWebViewController: UIViewController, UIWebViewDelegate, FZWebViewProgressDelegate {
    private var webView: UIWebView!
    private var progressView: FZWebViewProgressView!
    private var progressProxy: FZWebViewProgress!
    var url: String = ""
    var disableUserSelect = true
    var disableTouch = true
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        webView = UIWebView(frame: self.view.bounds)
        self.view.addSubview(webView)
        
        progressProxy = FZWebViewProgress()
        webView.delegate = progressProxy
        progressProxy.webViewProxyDelegate = self
        progressProxy.progressDelegate = self
        
        let progressBarHeight: CGFloat = 2.0
        let navigationBarBounds = self.navigationController!.navigationBar.bounds
        let barFrame = CGRect(x: 0, y: navigationBarBounds.size.height - progressBarHeight, width: navigationBarBounds.width, height: progressBarHeight)
        progressView = FZWebViewProgressView(frame: barFrame)
        progressView.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
    }
    
    override public func viewDidAppear(animated: Bool) {
        guard let loadUrl = NSURL(string: url) else {
            NSLog("FZWebViewController Get Invalid Url: %@", url)
            return
        }
        
        self.title = "Loading"
        self.navigationController?.navigationBar.addSubview(progressView)
        webView.loadRequest(NSURLRequest(URL: loadUrl))
    }
    
    override public func viewDidDisappear(animated: Bool) {
        progressView.removeFromSuperview()
    }
    
    public func webViewProgress(webViewProgress: FZWebViewProgress, updateProgress progress: Float) {        
        progressView.setProgress(progress, animated: true)
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        
        self.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        
        if (disableUserSelect) {
            webView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.webkitUserSelect='none';")
        }
        
        if (disableTouch) {
            webView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.webkitTouchCallout='none';")
        }
    }
}