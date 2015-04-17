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
    
    let gameViewController: GameViewController
    
    init(size: CGSize, gameViewController: GameViewController) {
        self.gameViewController = gameViewController
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // WebSocketRailsDispatcher インスタンスを返す
    //
    func webSocket() -> WebSocketRailsDispatcher {
        return gameViewController.webSocket
    }
    
    //
    // 自分の id を返す
    //
    func myId() -> String {
        return gameViewController.myId
    }
}