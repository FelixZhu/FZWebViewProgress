//
//  FZWebViewProgress.swift
//  FZWebViewProgress
//
//  Created by Felix Zhu on 15/11/23.
//  Copyright © 2015年 Felix Zhu. All rights reserved.
//

import UIKit

public protocol FZWebViewProgressDelegate {
    func webViewProgress(webViewProgress: FZWebViewProgress, updateProgress progress: Float)
}

public class FZWebViewProgress: NSObject, UIWebViewDelegate {
    
    var progressDelegate: FZWebViewProgressDelegate?
    var webViewProxyDelegate: UIWebViewDelegate?
    var progress: Float = 0.0
    var scheduledTime: Float = 5.0
    
    private var timer: NSTimer?
    private var loadingCount: Int!
    private var maxLoadCount: Int!
    private var currentUrl: NSURL?
    private var interactive: Bool!
    
    private let kInitialProgressValue: Float = 0.1
    private let kInteractiveProgressValue: Float = 0.5
    private let kFinalProgressValue: Float = 0.9
    private let kCompletePRCURLPath = "/fzwebviewprogress/complete"
    
    // MARK: Initializer
    override init() {
        super.init()

        maxLoadCount = 0
        loadingCount = 0
        interactive = false
    }

    // MARK: Private Method
    private func startProgress() {
        if progress < kInitialProgressValue {
            setProgress(kInitialProgressValue)
        }
    }
    
    // call after webview load finished
    private func incrementProgress() {
        var progress = self.progress
        let maxProgress = interactive == true ? kFinalProgressValue : kInteractiveProgressValue
        let remainPercent = Float(Float(loadingCount) / Float(maxLoadCount))
        let increment = (maxProgress - progress) * remainPercent
        progress += increment
        progress = fmin(progress, maxProgress)
        setProgress(progress)
    }
    
    private func completeProgress() {
        setProgress(1.0)
    }
    
    private func setProgress(progress: Float) {
        guard progress > self.progress || progress == 0 else {
            return
        }
        self.progress = progress
        progressDelegate?.webViewProgress(self, updateProgress: progress)
    }
    
    // MARK: Public Method
    func reset() {
        maxLoadCount = 0
        loadingCount = 0
        interactive = false
        setProgress(0.0)
    }
    
    func timerCallback(timer: NSTimer) {
        if (progress < 0.85) {
            let newProgress = progress + 1.0 / (60.0 * scheduledTime)
            setProgress(newProgress)
        } else {
            timer.invalidate()
        }
    }
    
    // MARK: - UIWebViewDelegate
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        guard let url = request.URL else {
            return false
        }
        if url.path == kCompletePRCURLPath {
            completeProgress()
            return false
        }
        
        var ret = true
        if webViewProxyDelegate!.respondsToSelector("webView:shouldStartLoadWithRequest:navigationType:") {
            ret = webViewProxyDelegate!.webView!(webView, shouldStartLoadWithRequest: request, navigationType: navigationType)
        }
        
        var isFragmentJump = false
        if let fragmentURL = url.fragment {
            let nonFragmentURL = url.absoluteString.stringByReplacingOccurrencesOfString("#" + fragmentURL, withString: "")
            isFragmentJump = nonFragmentURL == webView.request!.URL!.absoluteString
        }
        
        let isTopLevelNavigation = request.mainDocumentURL! == request.URL
        let isHTTP = url.scheme == "http" || url.scheme == "https"
        if ret && !isFragmentJump && isHTTP && isTopLevelNavigation {
            currentUrl = request.URL
            reset()
        }
        return ret
    }
    
    public func webViewDidStartLoad(webView: UIWebView) {
        if webViewProxyDelegate!.respondsToSelector("webViewDidStartLoad:") {
            webViewProxyDelegate!.webViewDidStartLoad!(webView)
        }
        
        loadingCount = loadingCount + 1
        maxLoadCount = Int(fmax(Double(maxLoadCount), Double(loadingCount)))
        
        // set progress to kInitialProgressValue
        startProgress()
        if (timer == nil) {
            timer = NSTimer(timeInterval: 1.0 / 60.0, target: self, selector: "timerCallback:", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        }
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        if webViewProxyDelegate!.respondsToSelector("webViewDidFinishLoad:") {
            webViewProxyDelegate!.webViewDidFinishLoad!(webView)
        }
        
        loadingCount = loadingCount - 1
        incrementProgress()
        
        let readyState = webView.stringByEvaluatingJavaScriptFromString("document.readyState")
        
        if readyState == "interactive" {
            self.interactive = true
            let iframeUrl = "\(webView.request!.mainDocumentURL!.scheme)://\(webView.request!.mainDocumentURL!.host!)\(kCompletePRCURLPath)"
            let waitForCompleteJS = "window.addEventListener('load', function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(iframeUrl)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScriptFromString(waitForCompleteJS)
        } else if (readyState == "complete") {
            let isRedirect = (currentUrl == webView.request?.mainDocumentURL) ? false : true
            if (!isRedirect) {
                completeProgress()
            }
        }
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if webViewProxyDelegate!.respondsToSelector("webView:didFailLoadWithError:") {
            webViewProxyDelegate!.webView!(webView, didFailLoadWithError: error)
        }
        
        loadingCount = loadingCount - 1
        incrementProgress()
        
        let readyState = webView.stringByEvaluatingJavaScriptFromString("document.readyState")
        
        if readyState == "interactive" {
            self.interactive = true
            let iframeUrl = "\(webView.request!.mainDocumentURL!.scheme)://\(webView.request!.mainDocumentURL!.host!)\(kCompletePRCURLPath)"
            let waitForCompleteJS = "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(iframeUrl)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScriptFromString(waitForCompleteJS)
        } else if (readyState == "complete") {
            let isRedirect = (currentUrl == webView.request?.mainDocumentURL) ? false : true
            if (!isRedirect) {
                completeProgress()
            }
        }
    }
}
