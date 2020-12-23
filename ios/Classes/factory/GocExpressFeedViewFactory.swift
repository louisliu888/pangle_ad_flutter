//
//  GocExpressFeedViewFactory.swift
//  pangle_ad_flutter
//
//  Created by liang on 2020/12/23.
//

import Foundation

public class GocExpressFeedViewFactory: NSObject, FlutterPlatformViewFactory {
    public static func initWithMessenger(with messenger: FlutterBinaryMessenger) -> GocExpressFeedViewFactory {
        let instance = GocExpressFeedViewFactory(messenger: messenger)
        return instance
    }

    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return GocExpressFeedView(frame, id: viewId, params: (args as? [String: Any]) ?? [:] as [String : Any], messenger: messenger)
    }
}
