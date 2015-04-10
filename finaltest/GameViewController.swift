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
        
        skView = self.view as? SKView
        let scene = GameScene(size:self.view.bounds.size)
        skView?.presentScene(scene)
        
        
        // ------------------
        // テスト用サンプルコード
        // ------------------
        
        // websocket 初期化
        var webSocket = WebSocketRailsDispatcher(url: NSURL(string: "ws://127.0.0.1:3000/websocket"))
        
        // --- ここからイベント登録 ---
        
        // 接続時のイベントハンドラ
        webSocket.bind("connection_opened", callback: { (data) -> Void in
            println("接続した！")
            
            // 適当にサーバにメッセージを送ってみる
            // 送信するデータは Dictionary でないといけないっぽい
            var data: Dictionary = ["id": "*randomId*", "data": "ここにデータが入る"]
            // webSocket.trigger メソッドでサーバ側のイベントを指定して送信する.
            // 今は送ったデータをすぐ全クライアントにブロードキャストするだけなので
            // websocket_game イベントハンドラが呼ばれるはず
            webSocket.trigger("websocket_game", data: data, success: nil, failure: nil)
        })
        
        // 切断時のイベントハンドラ
        webSocket.bind("connection_closed", callback: { (data) -> Void in
            println("切断された")
        })
        
        // ゲームイベント (websocket_game) 受信時のイベントハンドラ
        webSocket.bind("websocket_game", callback: { (data) -> Void in
            println("game: \(data)")
        })
        
        // --- ここまでイベント登録 ---
        
        println("ready to connect")
        
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
