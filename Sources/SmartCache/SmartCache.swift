//
//  SmartCache.swift
//  Globics
//
//  Created by Hoang Tran on 9/25/21.
//  Copyright © 2021 Hoang Tran. All rights reserved.
//

import Foundation

private let KeepTimeInterval: TimeInterval = 2 * 60
private let CheckInterval: TimeInterval = 30
typealias SmartCacheFactoryCallback<T> = (() -> T)
protocol SmartInitializable {
    init()
}

protocol StaticSmartInitializable {
    static func getInstance() -> Self
}

let smartCache = SmartCache.shared
/// Class to cache and re-use instance in 'keepTime'
class SmartCache {
    private init() { }
    static let shared = SmartCache()
    
    private var caches = [CacheItem]()
    private var factories = [Any]()
    private var timer: Timer?
    
    var printDebugLog = false
    
    func register<T>(_ handler: @escaping SmartCacheFactoryCallback<T>) {
        factories.append(Factory(factory: handler))
    }
    
    func resolve<T>(_ type: T.Type, keepTime: TimeInterval? = nil) -> T {
        return resolve(type, keepTime: keepTime) {
            let factory = factories.first { ($0 as? Factory<T>) != nil }
            if let factory = factory as? Factory<T> {
                return factory.factory()
            }
            fatalError("Don't have factory for type: \(type). Please register first!")
        }
    }
    
    func resolve<T: SmartInitializable>(_ type: T.Type, keepTime: TimeInterval? = nil) -> T {
        return resolve(type, keepTime: keepTime) {
            type.init()
        }
    }
    
    func resolve<T: StaticSmartInitializable>(_ type: T.Type, keepTime: TimeInterval? = nil) -> T {
        return resolve(type, keepTime: keepTime) {
            type.getInstance()
        }
    }
    
    func resolve<T: NSObject>(_ type: T.Type, keepTime: TimeInterval? = nil) -> T {
        return resolve(type, keepTime: keepTime) {
            type.init()
        }
    }
    
    func resolve<T>(_ type: T.Type, keepTime: TimeInterval? = nil, factory: SmartCacheFactoryCallback<T>) -> T {
        let cacheItem: CacheItem
        if let first = caches.first(where: { $0.instance is T }) {
            cacheItem = first
        }
        else {
            cacheItem = CacheItem(instance: factory())
            caches.append(cacheItem)
            if printDebugLog {
                print("Spawn \(cacheItem.instance)")
            }
        }
        if let keepTime = keepTime {
            cacheItem.keepTimeInterval = keepTime
        }
        cacheItem.lastAccessDate = Date()
        if timer == nil {
            self.timer = Timer(timeInterval: CheckInterval, target: self, selector: #selector(self.onFired(_:)), userInfo: nil, repeats: true)
        }
        return cacheItem.instance as! T
    }
    
    @objc private func onFired(_ timer: Timer) {
        clean()
    }
    
    private func clean() {
        let now = Date()
        caches.removeAll(where: {
            let result = $0.lastAccessDate.addingTimeInterval($0.keepTimeInterval).compare(now) != .orderedDescending
            if printDebugLog && result {
                print("Kill \($0.instance)")
            }
            return result
        })
        if caches.count == 0 {
            timer?.invalidate()
            timer = nil
        }
    }
}

private class CacheItem {
    let instance: Any
    var lastAccessDate: Date
    var keepTimeInterval: TimeInterval
    
    init(instance: Any) {
        self.instance = instance
        lastAccessDate = Date()
        keepTimeInterval = KeepTimeInterval
    }
}

private struct Factory<T> {
    let type: T.Type
    let factory: SmartCacheFactoryCallback<T>
    
    init(factory: @escaping SmartCacheFactoryCallback<T>) {
        type = T.self
        self.factory = factory
    }
}
