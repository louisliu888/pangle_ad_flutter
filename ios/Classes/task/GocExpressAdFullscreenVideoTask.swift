//
//  GocExpressAdFullscreenVideoTask.swift
//  pangle_ad_flutter
//
//  Created by liang on 2020/12/23.
//

import Foundation
import BUAdSDK

internal final class GocExpressFullscreenVideoAdTask: GocTaskProtocol {
    private var manager: BUNativeExpressFullscreenVideoAd
    private var delegate: BUNativeExpressFullscreenVideoAdDelegate?
    
    internal init(_ manager: BUNativeExpressFullscreenVideoAd) {
        self.manager = manager
    }
    
    convenience init(_ args: [String: Any?]) {
        let slotId: String = args["iOSSlotId"] as! String
        let manager = BUNativeExpressFullscreenVideoAd(slotID: slotId)
        self.init(manager)
    }
    
    func execute(_ loadingType: LoadingType) -> (@escaping (GocTaskProtocol, Any) -> Void) -> Void {
        return { result in
            let delegate = GocExpressFullscreenVideoAdDelegate(loadingType, success: { [weak self] () in
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
