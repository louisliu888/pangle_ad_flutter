//
//  GocNativeExpressFeedAdTask.swift
//  pangle_ad_flutter
//
//  Created by liang on 2020/12/23.
//

import Foundation
import BUAdSDK

internal final class GocNativeExpressFeedAdTask: GocTaskProtocol {
    public let manager: BUNativeExpressAdManager
    private var delegate:GocNativeExpressFeedAdViewDelegate?
    private var count: Int
    
    internal init(manager: BUNativeExpressAdManager, count: Int) {
        self.manager = manager
        self.count = count
    }
    
    convenience init(_ args: [String: Any?]) {
        let slotId: String = args["iOSSlotId"] as! String
        let count = args["count"] as? Int ?? 3
        
        let expressArgs = args["expressSize"] as! [String: Double]
        let width = expressArgs["width"]!
        let height = expressArgs["height"]!
        let imgSizeIndex = args["imgSize"] as! Int
        let imgSize = BUSize(by: BUProposalSize(rawValue: imgSizeIndex)!)!
        
        let adSize = CGSize(width: width, height: height)
        
        let slot = BUAdSlot()
        slot.id = slotId
        slot.adType = .feed
        slot.position = .feed
        slot.imgSize = imgSize
        
        let nad = BUNativeExpressAdManager(slot: slot, adSize: adSize)
        nad.adSize = adSize
        
        self.init(manager: nad, count: count)
    }
    
    func execute() -> (@escaping (GocTaskProtocol, Any) -> Void) -> Void {
        return { result in
            let delegate = GocNativeExpressFeedAdViewDelegate(success: { [weak self] data in
                guard let self = self else { return }
                result(self, ["code": 0, "count": data.count, "data": data])
            }, fail: { [weak self] error in
                guard let self = self else { return }
                let e = error as NSError?
                result(self, ["code": e?.code ?? -1, "message": error?.localizedDescription ?? "", "count": 0, "data": []])
            })
            
            self.manager.delegate = delegate
            self.delegate = delegate
            
            self.manager.loadAdData(withCount: self.count)
        }
    }
    
}
