//
//  GocSplashExpressAd.swift
//  pangle_ad_flutter
//
//  Created by liang on 2020/12/23.
//

import BUAdSDK
import Flutter
import WebKit

public class GocExpressSplashView: NSObject, FlutterPlatformView {
    private let methodChannel: FlutterMethodChannel
    private let container: UIView
    private var methodResult: FlutterResult?
    private let uiGesture = SplashTouchGesture()
    private weak var bannerView: BUNativeExpressSplashView?
    
    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        let channelName = String(format: "net.goc.oceantide/pangle_expresssplashview_%lld", id)
        self.methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        self.container = SplashView(frame: frame)
        super.init()
        let gesture = UITapGestureRecognizer()
        gesture.delegate = self.uiGesture
        self.container.addGestureRecognizer(gesture)
        self.methodChannel.setMethodCallHandler(self.handle(_:result:))
        self.loadAd(params)
    }
    
    public func view() -> UIView {
        return self.container
    }
    
    deinit {
        self.disposeView()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
        switch call.method {
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func loadAd(_ params: [String: Any?]) {
        let slotId = params["iOSSlotId"] as? String
        guard slotId != nil else {
            return
        }
        
        let tolerateTimeout: Double? = params["tolerateTimeout"] as? Double
        let hideSkipButton: Bool? = params["hideSkipButton"] as? Bool
        
        let vc = AppUtil.getVC()
        
        let expressArgs: [String: Double] = params["expressSize"] as! [String: Double]
        let width = expressArgs["width"]!
        let height = expressArgs["height"]!
        let adSize = CGSize(width: width, height: height)
        
        let viewWidth: Double = width
        let viewHeight: Double = height
        let splashAdView = BUNativeExpressSplashView(slotID: slotId!, adSize: adSize, rootViewController: vc)
        splashAdView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        splashAdView.center = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
        self.container.addSubview(splashAdView)
        
        if tolerateTimeout != nil {
            splashAdView.tolerateTimeout = tolerateTimeout!
        }
        if hideSkipButton != nil {
            splashAdView.hideSkipButton = hideSkipButton!
        }
        splashAdView.delegate = self
        splashAdView.loadAdData()
        self.bannerView = splashAdView
            
         
        self.container.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        self.container.updateConstraints()
    }
    
    private func disposeView() {
        self.methodChannel.setMethodCallHandler(nil)
    }
    
    private func invokeAction(_ code: Int = 0, message: String = "") {
        let args: [String: Any] = ["code": code, "message": message]
        methodChannel.invokeMethod("action", arguments: args)
    }
}

extension GocExpressSplashView: BUNativeExpressSplashViewDelegate {
    public func nativeExpressSplashViewDidLoad(_ splashAdView: BUNativeExpressSplashView) {}
    
    public func nativeExpressSplashView(_ splashAdView: BUNativeExpressSplashView, didFailWithError error: Error?) {
        let e = error as NSError?
        self.invokeAction(e?.code ?? -1, message: e?.localizedDescription ?? "")
    }
    
    public func nativeExpressSplashViewRenderSuccess(_ splashAdView: BUNativeExpressSplashView) {
        self.invokeAction(0, message: "show")
    }
    
    public func nativeExpressSplashViewRenderFail(_ splashAdView: BUNativeExpressSplashView, error: Error?) {
        let e = error as NSError?
        self.invokeAction(e?.code ?? -1, message: e?.localizedDescription ?? "")
    }
    
    public func nativeExpressSplashViewWillVisible(_ splashAdView: BUNativeExpressSplashView) {}
    
    public func nativeExpressSplashViewDidClick(_ splashAdView: BUNativeExpressSplashView) {
        self.invokeAction(0, message: "click")
    }
    
    public func nativeExpressSplashViewDidClickSkip(_ splashAdView: BUNativeExpressSplashView) {
        self.invokeAction(0, message: "skip")
    }
    
    public func nativeExpressSplashViewCountdown(toZero splashAdView: BUNativeExpressSplashView) {
        self.invokeAction(0, message: "timeover")
    }
    
    public func nativeExpressSplashViewDidClose(_ splashAdView: BUNativeExpressSplashView) {}
    
    public func nativeExpressSplashViewFinishPlayDidPlayFinish(_ splashView: BUNativeExpressSplashView, didFailWithError error: Error) {}
    
    public func nativeExpressSplashViewDidCloseOtherController(_ splashView: BUNativeExpressSplashView, interactionType: BUInteractionType) {}
}

//extension FLTSplashView: BUSplashAdDelegate {
//    public func splashAdCountdown(toZero splashAd: BUSplashAdView) {
//        self.invokeAction(0, message: "timeover")
//    }
//
//    public func splashAdDidClick(_ splashAd: BUSplashAdView) {
//        self.invokeAction(0, message: "click")
//    }
//
//    public func splashAdDidClose(_ splashAd: BUSplashAdView) {}
//
//    public func splashAdDidClickSkip(_ splashAd: BUSplashAdView) {
//        self.invokeAction(0, message: "skip")
//    }
//
//    public func splashAdWillVisible(_ splashAd: BUSplashAdView) {
//        self.invokeAction(0, message: "show")
//    }
//
//    public func splashAdDidLoad(_ splashAd: BUSplashAdView) {}
//
//    public func splashAd(_ splashAd: BUSplashAdView, didFailWithError error: Error?) {
//        let e = error as NSError?
//        self.invokeAction(e?.code ?? -1, message: e?.localizedDescription ?? "")
//    }
//}

class SplashView: UIView {}

private class SplashTouchGesture: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is SplashView {
            return true
        }
        
        return false
    }
}
