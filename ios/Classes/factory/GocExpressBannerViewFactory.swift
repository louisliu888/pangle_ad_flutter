//
//  GocBannerViewFactory.swift
//  pangle_ad_flutter
//
//  Created by liang on 2020/12/22.
//

import Foundation
import Flutter

public class GocExpressBannerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: NSObjectProtocol & FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return GocExpressBannerView(frame, id: viewId, params: (args as? [String: Any?]) ?? [:], messenger: self.messenger)
    }
}
