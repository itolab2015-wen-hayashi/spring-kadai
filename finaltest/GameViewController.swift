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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // websocket 初期化
        var webSocket = WebSocketRailsDispatcher(url: NSURL(string: "ws://127.0.0.1:3000/websocket"))
        
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
