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
    var webSocket: MyWebSocketRailsDispatcher!
    
    var myId: String = ""
    var clients: Array<String> = []
    var devices: NSMutableDictionary = [:]
    let myDateFormatter: NSDateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        myDateFormatter.locale = NSLocale(localeIdentifier: "ja")
        myDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
        
        super.viewDidLoad()
        
        initWebSocket()
        
        skView = self.view as? SKView
        let scene = TitleScene(size: self.skView!.bounds.size, gameViewController: self)
        skView?.presentScene(scene)
        
        // サーバに接続
        webSocket.connect()
    }
    
    func initWebSocket() {
        // websocket 準備
        webSocket = MyWebSocketRailsDispatcher(url: NSURL(string: "ws://133.68.108.19:8080/websocket"))
        
        // 接続時のイベントハンドラ
        webSocket.bind("connection_opened", callback: { (data) -> Void in
            println("接続した！")
            
            let device = UIDevice.currentDevice()
            self.webSocket.trigger("authenticate", data: [
                "id": "*randomId*",
                "data": [
                    "name": device.name
                ]
            ], success: nil, failure: nil)
        })
        
        // 切断時のイベントハンドラ
        webSocket.bind("connection_closed", callback: { (data) -> Void in
            println("切断された")
        })
        
        // 接続後最初のイベント connect_accepted のイベントハンドラ
        webSocket.bind("connect_accepted", callback: { (data) -> Void in
            println("connect_accepted")
            
            // 自分の id を記録
            let dict = (data as? NSMutableDictionary)!
            self.myId = (dict["id"] as? String)! // 自分のid
            
            println("myId=\(self.myId)")
        })
        
        //
        webSocket.bind("check_delay", callback: { (data) -> Void in
            println("check_delay")
            
            // 受信データ取り出し
            let dict = (data as? NSMutableDictionary)!
            let recv_time: String = dict["sent_time"] as! String
            
            // 現在時刻を送る
            self.webSocket.trigger("update_delay", data: [
                "id": "*randomId*",
                "data": [
                    "recv_time": recv_time,
                    "sent_time": self.myDateFormatter.stringFromDate(NSDate.new())
                ]
            ], success: nil, failure: nil)
        })
        
        // クライアントリスト受信時のイベントハンドラ
        webSocket.bind("client_list", callback: { (data) -> Void in
            println("client_list")
            
            // クライアントリストを更新する
            let dict = (data as? NSMutableDictionary)!
            self.clients = (dict["clients"] as? Array<String>)!
            self.devices = (dict["devices"] as? NSMutableDictionary)!
            println("clients = \(self.clients)")
            println("devices = \(self.devices)")
            
            if (self.skView?.scene is BaseScene) {
                (self.skView?.scene as! BaseScene).onClientListUpdated()
            }
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
