//
//  PangleAdManager.swift
//  pangle_ad_flutter
//
//  Created by liang on 2020/12/22.
//

import Foundation
import BUAdSDK
import Flutter

public final class PangleAdManager: NSObject {
    public static let shared = PangleAdManager()
    private var feedAdCollection: [String: BUNativeAd] = [:]
    private var expressAdCollection: [String: BUNativeExpressAdView] = [:]
    private var taskList: [GocTaskProtocol] = []
    private var fullExpressScreenVideoAdCollection: [Any] = []
    
    public func initialize(_ args: [String: Any?]) {
        let appId: String = args["appId"] as! String
        let logLevel: Int? = args["logLevel"] as? Int
        let coppa: UInt? = args["coppa"] as? UInt
        let isPaidApp: Bool? = args["coppa"] as? Bool
        BUAdSDKManager.setTerritory(BUAdSDKTerritory.CN)
        BUAdSDKManager.setAppID(appId)
        if isPaidApp != nil {
            BUAdSDKManager.setIsPaidApp(isPaidApp!)
        }
        if logLevel != nil {
            BUAdSDKManager.setLoglevel(BUAdSDKLogLevel(rawValue: logLevel!)!)
        }
        if coppa != nil {
            BUAdSDKManager.setCoppa(coppa!)
        }
        print(" init......................................")
    }
    
    fileprivate func execTask(_ task: GocTaskProtocol, _ loadingType: LoadingType? = nil) -> (@escaping (Any) -> Void) -> Void {
        self.taskList.append(task)
        return { result in
            if loadingType == nil {
                task.execute()({ [weak self] task, data in
                    self?.taskList.removeAll(where: { $0 === task })
                    result(data)
                })
            } else {
                task.execute(loadingType!)({ [weak self] task, data in
                    self?.taskList.removeAll(where: { $0 === task })
                    result(data)
                })
            }
        }
    }
    
    
}

extension PangleAdManager {
    public func setExpressAd(_ nativeExpressAdViews: [BUNativeExpressAdView]?) {
        guard let nativeAds = nativeExpressAdViews else {
            return
        }
        var expressAds: [String: BUNativeExpressAdView] = [:]
        for nativeAd in nativeAds {
            expressAds[String(nativeAd.hash)] = nativeAd
        }
        self.expressAdCollection.merge(expressAds, uniquingKeysWith: { _, last in last })
    }
    
    public func getExpressAd(_ key: String) -> BUNativeExpressAdView? {
        return self.expressAdCollection[key]
    }
    
    public func removeExpressAd(_ key: String?) {
        if key != nil {
            self.expressAdCollection.removeValue(forKey: key!)
        }
    }
    
    public func loadExpressFeedAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let task = GocNativeExpressFeedAdTask(args)
        self.execTask(task)({ data in
            print("信息流广告加载返回：\(data)")
            result(data)
        })
         
    }
}

// 模板插屏广告
extension PangleAdManager {
    public func loadExpressInterstitialAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let task = GocExpressInterstitialAdTask(args)
        self.execTask(task)({ data in
            result(data)
        })
    }
}

extension PangleAdManager {
    
    public func setExpressFullScreenVideoAd(_ ad: NSObject?) {
        if ad != nil {
            self.fullExpressScreenVideoAdCollection.append(ad!)
        }
    }
    
    public func loadExpressFullscreenVideoAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        
        let loadingTypeIndex: Int = args["loadingType"] as! Int
        var loadingType = LoadingType(rawValue: loadingTypeIndex)!
        
        if loadingType == .preload || loadingType == .normal {
            let success = self.showExpressFullScreenVideoAd()({ object in
                result(object)
            })
            if success {
                if loadingType == .normal {
                    return
                }
                return
            } else {
                loadingType = .normal
            }
        }
        
       
        let task = GocExpressFullscreenVideoAdTask(args)
        self.execTask(task, loadingType)({ data in
            if loadingType == .normal || loadingType == .preload_only {
                result(data)
            }
        })
         
    }
 

    public func showExpressFullScreenVideoAd() -> (@escaping (Any) -> Void) -> Bool {
        return { result in
            if self.fullExpressScreenVideoAdCollection.count > 0 {
                let obj = self.fullExpressScreenVideoAdCollection[0]
                 let ad = obj as! BUNativeExpressFullscreenVideoAd
                    ad.didReceiveSuccess = {
                        self.fullExpressScreenVideoAdCollection.removeFirst()
                        result(["code": 0])
                    }
                    ad.didReceiveFail = { error in
                        self.fullExpressScreenVideoAdCollection.removeFirst()
                        let e = error as NSError?
                        result(["code": e?.code ?? -1, "message": e?.localizedDescription ?? ""])
                    }
                    let vc = AppUtil.getVC()
                    ad.show(fromRootViewController: vc)
                    return true
            }
            return false
        }
    }

}
