//
//  GameoverScene.swift
//  finaltest
//
//  Created by better on 2015/04/22.
//  Copyright (c) 2015年 wen. All rights reserved.
//

import Foundation
import SpriteKit

class GameoverScene : BaseScene, UITableViewDataSource, UITableViewDelegate {
    
    var devices: NSMutableDictionary = [:]
    var scores: NSMutableDictionary = [:]
    var titleLabel: SKLabelNode?
    var scoreTable: UITableView?
    var restartButton: SKLabelNode?
    
    init(size: CGSize, gameViewController: GameViewController, scores: NSMutableDictionary) {
        super.init(size: size, gameViewController: gameViewController)
        self.devices = gameViewController.devices
        self.scores = scores
        
        initScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* シーン初期化 */
    func initScene() {
        // 背景の設定
        self.backgroundColor = UIColor.orangeColor()
        
        // 各プレーヤーの得点を表示する
        var titleLabel = SKLabelNode(text: "Score")
        titleLabel.fontSize = 50
        titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 150)
        self.titleLabel = titleLabel
        
        // リスタートボタンを表示する
        let restartButton = SKLabelNode(text: "RESTART")
        restartButton.name = "restartButton"
        restartButton.fontSize = 30
        restartButton.position = CGPointMake(CGRectGetMidX(self.frame), 150)
        self.restartButton = restartButton
        
        self.addChild(titleLabel)
        self.addChild(restartButton)
    }
    
    override func didMoveToView(view: SKView) {
        // UITableView
        let scoreTableHeight = (titleLabel!.frame.minY - restartButton!.frame.maxY)*0.8
        
        let scoreTable = UITableView()
        scoreTable.frame = CGRectMake(
            self.frame.size.width*0.1,
            self.frame.height - (titleLabel!.frame.minY - scoreTableHeight/0.8*0.1),
            self.frame.size.width*0.8,
            scoreTableHeight)
        scoreTable.backgroundColor = UIColor.clearColor()
        scoreTable.separatorStyle = UITableViewCellSeparatorStyle.None
        scoreTable.layer.masksToBounds = true
        scoreTable.delegate = self
        scoreTable.dataSource = self
        self.scoreTable = scoreTable
        
        self.view?.addSubview(scoreTable)
    }
    
    override func willMoveFromView(view: SKView) {
        removeSubViews()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let point = (touches.first as! UITouch).locationInNode(self)
        var touchedNode = nodeAtPoint(point)
        
        if (touchedNode.name == "restartButton") {
            // ゲーム開始
            let scene = TitleScene(size: size, gameViewController: self.gameViewController)
            let transition = SKTransition.fadeWithDuration(0.5)
            
            (self.gameViewController.view as! SKView).presentScene(scene, transition: transition)
        }
    }
    
    func removeSubViews() {
        dispatch_async(dispatch_get_main_queue(), {
            self.scoreTable?.removeFromSuperview()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        
        let client_id: String = (scores.allKeys[indexPath.row] as? String)!
        let name: String = ((devices[client_id] as! NSMutableDictionary)["name"] as? String)!
        let score: Int = (scores[client_id] as? Int)!
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = String(score)
        println(" row=\(indexPath.row), name=\(name), score=\(score)")
        
        return cell
    }
    
}