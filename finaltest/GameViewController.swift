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
    
    let myDateFormatter: NSDateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        myDateFormatter.locale = NSLocale(localeIdentifier: "ja")
        myDateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        super.viewDidLoad()
        
        initWebSocket()
        
        skView = self.view as? SKView
        let scene = TitleScene(size:self.view.bounds.size, webSocket: webSocket)
        skView?.presentScene(scene)
        
        // サーバに接続
        webSocket.connect()
    }
    
    func initWebSocket() {
        // websocket 準備
        webSocket = WebSocketRailsDispatcher(url: NSURL(string: "ws://133.68.108.19:3000/websocket"))
        
        // 接続時のイベントハンドラ
        webSocket.bind("connection_opened", callback: { (data) -> Void in
            println("接続した！")
        })
        
        // 切断時のイベントハンドラ
        webSocket.bind("connection_closed", callback: { (data) -> Void in
            println("切断された")
        })
        
        //
        webSocket.bind("check_delay", callback: { (data) -> Void in
            println("check_delay")
            
            // 現在時刻を送る
            self.webSocket.trigger("update_delay", data: [
                "id": "*randomId*",
                "data": [
                    "sent_time": self.myDateFormatter.stringFromDate(NSDate.new())
                ]
                ], success: nil, failure: nil)
        })
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
