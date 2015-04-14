//
//  GameViewController.swift
//  finaltest
//
//  Created by itolab on 2015/03/24.
//  Copyright (c) 2015年 wen. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var skView : SKView?
    var webSocket: WebSocketRailsDispatcher!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // websocket 初期化
        webSocket = WebSocketRailsDispatcher(url: NSURL(string: "ws://133.68.108.19:3000/websocket"))
        
        skView = self.view as? SKView
        let scene = GameScene(size:self.view.bounds.size, webSocket: webSocket)
        skView?.presentScene(scene)
        
        // サーバに接続
        webSocket.connect()
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
