//
//  ExpressNterstitialAdTask.swift
//  pangle_ad_flutter
//
//  Created by liang on 2020/12/23.
//

import Foundation
import BUAdSDK

internal final class GocExpressInterstitialAdTask: GocTaskProtocol {
    private var manager: BUNativeExpressInterstitialAd
    private var delegate: BUNativeExpresInterstitialAdDelegate?
    
    internal init(_ manager: BUNativeExpressInterstitialAd) {
        self.manager = manager
    }
    
    convenience init(_ args: [String: Any?]) {
        let slotId: String = args["iOSSlotId"] as! String
        let expressArgs = args["expressSize"] as! [String: Double]
        let width = expressArgs["width"]!
        let height = expressArgs["height"]!
        let adSize = CGSize(width: width, height: height)
        let manager = BUNativeExpressInterstitialAd(slotID: slotId, adSize: adSize)
        self.init(manager)
    }
    
    func execute() -> (@escaping (GocTaskProtocol, Any) -> Void) -> Void {
        return { result in
            let delegate = GocExpressInterstitialAdDelegate(success: { [weak self] () in
                guard let self = self else { return }
                result(self, ["code": 0])
            }, fail: { [weak self] error in
                guard let self = self else { return }
                let e = error as NSError?
                result(self, ["code": e?.code ?? -1, "message": error?.localizedDescription ?? ""])
               })
            
            self.manager.delegate = delegate
            self.delegate = delegate
            
            self.manager.loadData()
        }
    }
}
