//
//  GocNativeExpressFeedAdViewDelegate.swift
//  pangle_ad_flutter
//
//  Created by liang on 2020/12/23.
//

import Foundation
import BUAdSDK

internal final class GocNativeExpressFeedAdViewDelegate: NSObject, BUNativeExpressAdViewDelegate {
    typealias Success = ([String]) -> Void
    typealias Fail = (Error?) -> Void

    let success: Success?
    let fail: Fail?

    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }

    public func nativeExpressAdSuccess(toLoad nativeExpressAd: BUNativeExpressAdManager, views: [BUNativeExpressAdView]) {
        /// 设置view的关联对象，让delegate随着view的销毁一起销毁
        views.forEach {
            $0.delegate = self
            $0.manager = nativeExpressAd
        }
        /// 存入缓存
        PangleAdManager.shared.setExpressAd(views)
        self.success?(views.map { String($0.hash) })
    }

    public func nativeExpressAdFail(toLoad nativeExpressAd: BUNativeExpressAdManager, error: Error?) {
        self.fail?(error)
    }

    public func nativeExpressAdViewRenderFail(_ nativeExpressAdView: BUNativeExpressAdView, error: Error?) {
        nativeExpressAdView.didReceiveRenderFail?(error)
    }

    func nativeExpressAdViewRenderSuccess(_ nativeExpressAdView: BUNativeExpressAdView) {
        nativeExpressAdView.didReceiveRenderSuccess?()
    }

    public func nativeExpressAdView(_ nativeExpressAdView: BUNativeExpressAdView, dislikeWithReason filterWords: [BUDislikeWords]) {
        nativeExpressAdView.didReceiveDislike?(filterWords)
    }
}

private var managerKey = "net.goc.oceantide/manager"
private var delegateKey = "net.goc.oceantide/delegate"
private var dislikeDelegateKey = "net.goc.oceantide/delegate_dislike"
private var renderSuccessDelegateKey = "net.goc.oceantide/delegate_render_success"
private var renderFailDelegateKey = "net.goc.oceantide/delegate_render_fail"

extension BUNativeExpressAdView {
    var manager: BUNativeExpressAdManager? {
        get {
            return objc_getAssociatedObject(self, &managerKey) as? BUNativeExpressAdManager
        } set {
            objc_setAssociatedObject(self, &managerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var delegate: BUNativeExpressAdViewDelegate? {
        get {
            return objc_getAssociatedObject(self, &delegateKey) as? BUNativeExpressAdViewDelegate
        } set {
            objc_setAssociatedObject(self, &delegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 设置dislike的点击事件
    var didReceiveDislike: (([BUDislikeWords]) -> Void)? {
        get {
            objc_getAssociatedObject(self, &dislikeDelegateKey) as? (([BUDislikeWords]) -> Void)
        } set {
            objc_setAssociatedObject(self, &dislikeDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var didReceiveRenderFail: ((Error?) -> Void)? {
        get {
            objc_getAssociatedObject(self, &renderFailDelegateKey) as? ((Error?) -> Void)
        } set {
            objc_setAssociatedObject(self, &renderFailDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var didReceiveRenderSuccess: (() -> Void)? {
        get {
            objc_getAssociatedObject(self, &renderSuccessDelegateKey) as? (() -> Void)
        } set {
            objc_setAssociatedObject(self, &renderSuccessDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
