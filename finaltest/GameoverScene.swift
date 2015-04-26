//
//  GameoverScene.swift
//  finaltest
//
//  Created by better on 2015/04/22.
//  Copyright (c) 2015年 wen. All rights reserved.
//

import Foundation
import SpriteKit

class GameoverScene : BaseScene {
    
    var devices: NSMutableDictionary = [:]
    var scores: NSMutableDictionary = [:]
    
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
        //var titleLabel = SKLabelNode(text: "Score")
        //titleLabel.fontSize = 50
        //titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 200)
        
        // リスタートボタンを表示する
        var restartButton = SKLabelNode(text: "RESTART")
        restartButton.name = "restartButton"
        restartButton.fontSize = 30
        restartButton.position = CGPointMake(CGRectGetMidX(self.frame), 200)
        
        //self.addChild(titleLabel)
        self.addChild(restartButton)
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
    
}