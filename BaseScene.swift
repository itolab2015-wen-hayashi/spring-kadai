//
//  BaseScene.swift
//  finaltest
//
//  Created by Masayuki Hayashi on 2015/04/16.
//  Copyright (c) 2015年 wen. All rights reserved.
//

import Foundation
import SpriteKit

class BaseScene : SKScene {
    
    var webSocket: WebSocketRailsDispatcher
    
    init(size: CGSize, webSocket: WebSocketRailsDispatcher) {
        self.webSocket = webSocket
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}