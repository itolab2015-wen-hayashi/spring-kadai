//
//  TitleScene.swift
//  finaltest
//
//  Created by Masayuki Hayashi on 2015/04/16.
//  Copyright (c) 2015年 wen. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene : BaseScene, UITableViewDataSource, UITableViewDelegate {
    
    var isStartButtonEnabled: Bool = false
    var titleLabel: SKLabelNode?
    var clientTable: UITableView?
    var startButton: SKLabelNode?
    
    override init(size: CGSize, gameViewController: GameViewController) {
        super.init(size: size, gameViewController: gameViewController)
        
        initWebSocket()
        
        initScene()
        
        // 新規ゲームのリクエスト
        webSocket().trigger("request_game", data: wsData([:]), success: nil, failure: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initWebSocket() {
        func whenUnavailable(data: AnyObject!) {
            let startButton = self.childNodeWithName("startButton") as! SKLabelNode
            startButton.text = "WAITING..."
            startButton.fontColor = SKColor.grayColor()
            self.isStartButtonEnabled = false        }
    
        func whenAvailable(data: AnyObject!) {
            let startButton = self.childNodeWithName("startButton") as! SKLabelNode
            startButton.text = "START"
            startButton.fontColor = SKColor.whiteColor()
            self.isStartButtonEnabled = true
        }
        
        webSocket().bind("request_game_rejected", callback: whenUnavailable)
        webSocket().bind("request_game_accepted", callback: whenAvailable)
        webSocket().bind("close_game", callback: whenAvailable)
    }
    
    func initScene() {
        // 背景の設定
        self.backgroundColor = UIColor.orangeColor()
        
        // タイトルを表示する
        let titleLabel = SKLabelNode(text: "TôT")
        titleLabel.fontSize = 50
        titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 200)
        self.titleLabel = titleLabel
        
        // ボタンを表示する
        let startButton = SKLabelNode(text: "CONNECTING")
        startButton.name = "startButton"
        startButton.fontSize = 30
        startButton.fontColor = SKColor.whiteColor()
        startButton.position = CGPointMake(CGRectGetMidX(self.frame), 200)
        self.startButton = startButton
        
        self.addChild(titleLabel)
        self.addChild(startButton)
    }
    
    override func didMoveToView(view: SKView) {
        // UITableView
        let clientTableHeight = (titleLabel!.frame.minY - startButton!.frame.maxY)*0.8
        
        let clientTable = UITableView()
        clientTable.frame = CGRectMake(
            self.frame.size.width*0.1,
            self.frame.height - (titleLabel!.frame.minY - clientTableHeight/0.8*0.1),
            self.frame.size.width*0.8,
            clientTableHeight)
        clientTable.backgroundColor = UIColor.clearColor()
        clientTable.separatorStyle = UITableViewCellSeparatorStyle.None
        clientTable.layer.masksToBounds = true
        clientTable.delegate = self
        clientTable.dataSource = self
        self.clientTable = clientTable
        
        self.view?.addSubview(clientTable)
    }
    
    override func willMoveFromView(view: SKView) {
        removeSubViews()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let point = (touches.first as! UITouch).locationInNode(self)
        var touchedNode = nodeAtPoint(point)
        
        if (touchedNode.name == "startButton" && isStartButtonEnabled) {
            removeSubViews()
            
            // ゲーム開始
            let scene = GameScene(size: size, gameViewController: self.gameViewController)
            let transition = SKTransition.fadeWithDuration(0.5)
            
            (self.gameViewController.view as! SKView).presentScene(scene, transition: transition)
        }
    }
    
    override func onClientListUpdated() {
        self.clientTable?.reloadData()
    }
    
    func removeSubViews() {
        dispatch_async(dispatch_get_main_queue(), {
            self.clientTable?.removeFromSuperview()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        
        let client_id: String = clients()[indexPath.row]
        let name: String = ((devices()[client_id] as! NSMutableDictionary)["name"] as? String)!
        cell.textLabel?.text = name
        println(" row=\(indexPath.row), name=\(name)")
        
        return cell
    }
}