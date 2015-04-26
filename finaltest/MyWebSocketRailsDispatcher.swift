//
//  MyWebSocketRailsDispatcher.swift
//  finaltest
//
//  Created by MasayukiHayashi on 2015/04/26.
//  Copyright (c) 2015年 wen. All rights reserved.
//

import Foundation

class MyWebSocketRailsDispatcher: WebSocketRailsDispatcher {
    
    var callbacks: Dictionary<String,Array<EventCompletionBlock>> = [:]
    
    override init!(url: NSURL!) {
        super.init(url: url)
    }
    
    override func bind(eventName: String!, callback: EventCompletionBlock!) {
        if (self.callbacks[eventName] == nil) {
            self.callbacks[eventName] = []
            super.bind(eventName, callback: { (data) -> Void in
                let callbacks: Array<EventCompletionBlock> = self.callbacks[eventName]!
                for callback: EventCompletionBlock in callbacks {
                    callback(data)
                }
            })
        }
        // FIXME: 最後に bind したのしか残さない... 本当は unbind 実装して使いやすくしたいんだが...
        (self.callbacks[eventName]!).removeAll(keepCapacity: true)
        (self.callbacks[eventName]!).append(callback!)
    }
    
    // TODO: unbind 実装できてない, swift嫌い
//    func unbind(eventName: String!, callback: EventCompletionBlock!) {
//        if (self.callbacks[eventName] != nil) {
//            for (index, obj) in enumerate(self.callbacks[eventName]!) {
//                if (obj.dynamicType === callback.dynamicType) {
//                    
//                }
//            }
//        }
//    }
    
}