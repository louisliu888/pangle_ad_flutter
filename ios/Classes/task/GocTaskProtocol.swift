//
//  GocTaskProtocol.swift
//  pangle_ad_flutter
//
//  Created by liang on 2020/12/23.
//

import Foundation

enum LoadingType: Int {
    case normal
    case preload
    case preload_only
}

protocol GocTaskProtocol: class {
    func execute() -> (@escaping (GocTaskProtocol, Any) -> Void) -> Void

    func execute(_ loadingType: LoadingType) -> (@escaping (GocTaskProtocol, Any) -> Void) -> Void
}

extension GocTaskProtocol {
    func execute() -> (@escaping (GocTaskProtocol, Any) -> Void) -> Void {
        return { _ in }
    }

    func execute(_ loadingType: LoadingType) -> (@escaping (GocTaskProtocol, Any) -> Void) -> Void {
        return { _ in }
    }
}
