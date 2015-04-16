//
//  TitleScene.swift
//  finaltest
//
//  Created by Masayuki Hayashi on 2015/04/16.
//  Copyright (c) 2015年 wen. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene : SKScene {
    
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // 背景の設定
        self.backgroundColor = UIColor.orangeColor()
        
        // タイトルを表示する
        var titleLabel = SKLabelNode(text: "GuGame")
        titleLabel.fontSize = 50
        titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 200)
        
        // ボタンを表示する
        // TODO
        
        self.addChild(titleLabel)
        // TODO
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}