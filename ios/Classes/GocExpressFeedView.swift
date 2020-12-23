//
//  GocExpressFeedView.swift
//  pangle_ad_flutter
//
//  Created by liang on 2020/12/23.
//

import Foundation
import BUAdSDK
import Flutter
import WebKit

public class GocExpressFeedView: NSObject, FlutterPlatformView {
    private let methodChannel: FlutterMethodChannel
    private let container: UIView
    private var feedId: String?
    private let uiGesture = FeedTouchGesture()
    private var isUserInteractionEnabled = true

    init(_ frame: CGRect, id: Int64, params: [String: Any], messenger: FlutterBinaryMessenger) {
        self.container = FeedView(frame: frame)
        let channelName = String(format: "net.goc.oceantide/pangle_expressfeedview_%llld", id)
        print("channelName============\(channelName)");
        self.methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)

        self.feedId = params["feedId"] as? String
        self.isUserInteractionEnabled = params["isUserInteractionEnabled"] as? Bool ?? true
        super.init()

        let gesture = UITapGestureRecognizer()
        gesture.delegate = self.uiGesture
        self.container.addGestureRecognizer(gesture)

        self.methodChannel.setMethodCallHandler(self.handle(_:result:))
        if self.feedId != nil {
            let nad = PangleAdManager.shared.getExpressAd(self.feedId!)
            self.loadExpressAd(nad)
        }
    }

    deinit {
        if self.feedId != nil {
          PangleAdManager.shared.removeExpressAd(self.feedId!)
        }
        removeAllView()
    }

    public func view() -> UIView {
        return self.container
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "update":
            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
            let feedId = args["feedId"] as? String
            if feedId != nil {
                let nad = PangleAdManager.shared.getExpressAd(feedId!)
                self.loadExpressAd(nad)
            }
            result(nil)
        case "remove":
            self.onlyRemoveView()
        case "setUserInteractionEnabled":
            let enable: Bool = call.arguments as? Bool ?? false
            
            if self.feedId != nil {
                let nad = PangleAdManager.shared.getExpressAd(self.feedId!)
                nad?.isUserInteractionEnabled = enable
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func invoke(width: CGFloat, height: CGFloat) {
        var params = [String: Any]()
        params["width"] = width
        params["height"] = height
        self.methodChannel.invokeMethod("update", arguments: params)
    }

    private func removeAllView() {
        self.container.subviews.forEach {
            if $0 is BUNativeExpressAdView {
                let v = $0 as! BUNativeExpressAdView
                v.rootViewController = nil
                v.subviews.forEach {
                    if String(describing: $0.classForCoder) == "BUWKWebViewClient" {
                        let webview = $0 as! WKWebView
                        webview.navigationDelegate = nil
                        if #available(iOS 14.0, *) {
                            webview.configuration.userContentController.removeAllScriptMessageHandlers()
                        } else {
                            webview.configuration.userContentController.removeScriptMessageHandler(forName: "callMethodParams")
                        }
                    }
                }
            }
            $0.subviews.forEach { $0.removeFromSuperview() }
            $0.removeFromSuperview()
        }
    }

    private func onlyRemoveView() {
        self.removeAllView()
        PangleAdManager.shared.removeExpressAd(self.feedId)
    }

    private func disposeView() {
        self.onlyRemoveView()
        self.methodChannel.invokeMethod("remove", arguments: nil)
    }
    
    func loadExpressAd(_ ad: BUNativeExpressAdView?) {
        guard let expressAd: BUNativeExpressAdView = ad else {
            return
        }

        let size = expressAd.bounds.size
        let viewWidth = size.width
        let viewHeight = size.height
        self.removeAllView()
        expressAd.isUserInteractionEnabled = self.isUserInteractionEnabled
        let frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        expressAd.frame = frame
        expressAd.center = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
        let rootFrame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        self.container.frame = rootFrame
        self.container.addSubview(expressAd)
        self.container.updateConstraints()
        self.invoke(width: viewWidth, height: viewHeight)

        expressAd.rootViewController = AppUtil.getVC()
      
        expressAd.render()
    }
}

 

class FeedView: UIView {
 
}

private class FeedTouchGesture: NSObject, UIGestureRecognizerDelegate {
    /// 解决滑动PlatformView变成点击的问题
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is FeedView {
            return true
        }
        return false
    }
}
