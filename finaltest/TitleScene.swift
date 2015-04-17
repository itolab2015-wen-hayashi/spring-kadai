//
//  TitleScene.swift
//  finaltest
//
//  Created by Masayuki Hayashi on 2015/04/16.
//  Copyright (c) 2015年 wen. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene : BaseScene {
    
    override init(size: CGSize, gameViewController: GameViewController) {
        super.init(size: size, gameViewController: gameViewController)
        
        initScene()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initScene() {
        // 背景の設定
        self.backgroundColor = UIColor.orangeColor()
        
        // タイトルを表示する
        var titleLabel = SKLabelNode(text: "GuGame")
        titleLabel.fontSize = 50
        titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 200)
        
        // ボタンを表示する
        var startButton = SKLabelNode(text: "START")
        startButton.name = "startButton"
        startButton.fontSize = 30
        startButton.position = CGPointMake(CGRectGetMidX(self.frame), 200)
        
        self.addChild(titleLabel)
        self.addChild(startButton)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let point = (touches.first as! UITouch).locationInNode(self)
        var touchedNode = nodeAtPoint(point)
        
        if (touchedNode.name == "startButton") {
            // ゲーム開始
            let scene = GameScene(size: size, gameViewController: self.gameViewController)
            let transition = SKTransition.fadeWithDuration(0.5)
            
            self.view!.presentScene(scene, transition: transition)
        }
    }
    
}