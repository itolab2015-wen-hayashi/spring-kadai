//
//  GameScene.swift
//  finaltest
//
//  Created by itolab on 2015/03/24.
//  Copyright (c) 2015年 wen. All rights reserved.
//

import SpriteKit

let NumColumns = 6
let NumRows = 10
let TileSize:CGFloat = 50

let BoardLayerPosition = CGPointMake(20, -80)
let TextFieldPosition = CGPointMake(20, -20)
let TextFieldPosition2 = CGPointMake(20, -60)

class GameScene: BaseScene {
    var board = SKSpriteNode()
    let boardLayer = SKNode()
    let shapeLayer = SKNode()
    
    let textLayer = SKNode()
    let strLayer = SKNode()
    
    let score = SKLabelNode()
    let gameoverLabel = SKLabelNode()
    
    var tileArrayPos = Array(count: NumColumns, repeatedValue: Array(count: NumRows, repeatedValue: CGPoint()))
    var touchedNode = SKNode()
    var moveActionFlag = false
    var gameoverFlag = false
    var scorePoint = 0
    
    // タイルが表示された時刻
    var tileDisplayedTime:NSTimeInterval = NSTimeInterval(0)
    var elapsedTime:Double = -1.0
    
    // 次の triggerTime
    var prevCurrentTime: CFTimeInterval = 0
    var timeToWait: CFTimeInterval = 0
    
    
    override init(size: CGSize, gameViewController: GameViewController) {
        super.init(size: size, gameViewController: gameViewController)
        
        // websocket 設定
        initWebSocket();
        
        // scene 初期化
        initScene();
        
        // ゲーム参加通知
        webSocket().trigger("join_game", data: [
            "id": "*randomId*",
            "data": []
        ], success: nil, failure: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Error")
    }
    
    func initWebSocket() {
        // TODO: WebSocket のイベントハンドラを登録する
        
        // ------------------
        // テスト用サンプルコード
        // ------------------
        
        // --- ここからイベント登録 ---
        
        // ゲームイベント (new_round) 受信時のイベントハンドラ
        webSocket().bind("new_round", callback: { (data) -> Void in
            println("new_round")
            
            // 受信データ取り出し
            let _data = data as? Dictionary<String, AnyObject>
            let triggerTime: String = _data!["trigger_time"] as! String // msまで含めた次にタイルを表示してほしい時刻
            let nextTriggerTime = self.defaultDateFormatter().dateFromString(triggerTime)!
            
            println("triggerTime=\(triggerTime)")
            println("nextTriggerTime=\(nextTriggerTime)")
            
            // TODO: self.nextTriggerTime になったら (nextTriggerTime 以降に1回だけ) タイルを表示する
            self.timeToWait = nextTriggerTime.timeIntervalSinceNow
            println("timeToWait=\(self.timeToWait)")
        })
        
        // みんなから経過時間を集計するために呼ばれるイベントのイベントハンドラ
        webSocket().bind("winner_approval", callback: { (data) -> Void in
            // タイル消す
            // TODO: implement this
            /*
            ##########################################
            self.removeChildrenInArray([touchedNode])
            board.removeChildrenInArray([touchedNode])
            ##########################################
            */
            // 受信データ取り出し
            let _data = data as? Dictionary<String, AnyObject>
            let minElapsedTime: Double = _data!["elapsed_time"] as! Double
            
            // 送信データを生成
            var wsdata: Dictionary = [
                "id": "*randomId*",
                "data": []
            ]
            if (0 < self.elapsedTime) {
                if (self.elapsedTime < minElapsedTime) {
                    wsdata["data"] = [
                        "approve": false,
                        "elapsed_time": self.elapsedTime
                    ]
                }
            } else {
                // approve する
                wsdata["data"] = [
                    "approve": true
                ]
            }
            
            // データ送信
            self.webSocket().trigger("winner_approval", data: wsdata, success: nil, failure: nil)
        })
        
        // 一試合の終わりのイベントを受信したときのイベントハンドラ
        webSocket().bind("close_round", callback: { (data) -> Void in
            println("close_round")
            
            // データ取り出し
            let _data = data as? Dictionary<String, AnyObject>
            let winner: String = _data!["winner"] as! String // 勝者の id
            
            // TODO: 勝ったかどうか判断して表示する
            
            if (self.myId() == winner) {
                self.scorePoint += 100
            }
            //self.initMakeTile()
            
        })
        
        // 全試合の終わりのイベントを受信したときのイベントハンドラ
        webSocket().bind("close_game", callback: { (data) -> Void in
            println ("close_game")
            
            // データ取り出し
            let _data = data as? Dictionary<String, AnyObject>
            let winner: String = _data!["winner"] as! String // 勝者の id
            
            // TODO: 勝ったかどうか判断して表示する
            if (self.myId() == winner) {
                println("You win")
            }
        })
        
        // --- ここまでイベント登録 ---
    }
    
    func initScene() {
        self.backgroundColor = UIColor.orangeColor()
        //let background = SKSpriteNode(imageNamed: "table.png")
        //background.position = CGPointMake(self.size.width/2, self.size.height/2)
        //background.xScale = self.size.width /
        //self.addChild(background)
        
        anchorPoint = CGPointMake(0, 1.0)
        
        addChild(boardLayer)
        addChild(textLayer)
        
        board = SKSpriteNode(color:UIColor(red: 0, green: 0, blue: 0, alpha: 0),size:CGSizeMake(CGFloat(NumColumns)*TileSize, CGFloat(NumRows)*TileSize))
        board.name = "board"
        board.anchorPoint = CGPointMake(0, 1.0)
        board.position = BoardLayerPosition
        
        
        let textfield = SKSpriteNode(color:UIColor(red: 0, green: 0, blue: 0, alpha: 0),size:CGSizeMake(CGFloat(NumColumns)*TileSize, 80))
        textfield.position = TextFieldPosition
        textfield.anchorPoint = CGPointMake(0, 1.0)
        
        score.fontColor = UIColor.blackColor()
        score.position = CGPointMake(textfield.position.x*7, textfield.position.y-30)
        textfield.addChild(score)
        
        strLayer.position = TextFieldPosition
        strLayer.addChild(textfield)
        textLayer.addChild(strLayer)
        
        shapeLayer.position = BoardLayerPosition
        shapeLayer.addChild(board)
        boardLayer.addChild(shapeLayer)
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //initMakeTile()
        
    }
    
    func randomColor()->UIColor{
        //0:red,1:green,2:blue,3:yellow
        let rnd = arc4random()%4
        var color:UIColor!
        switch rnd{
        case 0:
            color = UIColor(red: 0.11, green: 0.71, blue: 0.56, alpha: 1)//like green
        case 1:
            color = UIColor(red: 0.94, green: 0.72, blue: 0.29, alpha: 1)//like yellow
        case 2:
            color = UIColor(red: 0.08, green: 0.56, blue: 0.65, alpha: 1)//mint
        case 3:
            color = UIColor(red: 0.93, green: 0.26, blue: 0.24, alpha: 1)// like red
        default:
            break
        }
        return color
    }
    
    func initMakeTile(){
        var i = Int(arc4random()) % 6
        var j = Int(arc4random()) % 10
        let sprite = makeTileOne()
        
        sprite.position = CGPointMake(CGFloat(i)*TileSize,-CGFloat(j)*TileSize)
        tileArrayPos[i][j] = sprite.position
        
        board.addChild(sprite)
        
        tileDisplayedTime = NSDate.timeIntervalSinceReferenceDate()
        elapsedTime = -1.0
    }
    
    
    func makeTileOne()->SKSpriteNode{
        let sprite = SKSpriteNode()
        sprite.anchorPoint = CGPointMake(0, 1.0)
        sprite.alpha *= 1.0
        sprite.color = randomColor()
        //sprite.color = UIColor.greenColor()
        sprite.size = CGSizeMake(TileSize-1, TileSize-1)
        
        return sprite
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        //var deleteColumnsArray = Array(arrayLiteral:SKNode())
        if(gameoverFlag == false){
            for touch in touches {
                let location = (touch as! UITouch).locationInNode(self)
                //printf(location)
                touchedNode = self.nodeAtPoint(location)
                for node in self.board.children{
                    if(touchedNode == node as! NSObject && !moveActionFlag){
                        let now = NSDate.timeIntervalSinceReferenceDate()
                        //println("now=\(now)")
                        elapsedTime = (now - self.tileDisplayedTime) * 1000
                        println("elapsed_Time=\(elapsedTime)")
                        
                        var data: Dictionary = [
                            "id": "*randomId*",
                            "data": [
                                "elapsed_time": elapsedTime
                            ]
                        ]
                        
                        // TODO webSocket.trigger でメッセージを送る
                        webSocket().trigger("tile_pushed", data: data, success: { (data) -> Void in
                            println("tile_pushed: success")
                        }, failure: { (data) -> Void in
                            println("tile_pushed: failure")
                        })
                        
                        self.removeChildrenInArray([touchedNode])
                        board.removeChildrenInArray([touchedNode])
                        //scorePoint += 100
                        //initMakeTile()
                        
                    }
                }
            }
        }
    }
    
    func gameover(){
        gameoverLabel.text = "You Win"
        gameoverLabel.fontSize = 100
        gameoverLabel.fontColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
        gameoverLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(gameoverLabel)
        gameoverFlag = true
    }
    
    func reset(){
        gameoverFlag = false
        
        gameoverLabel.removeFromParent()
        
        scorePoint = 0
    }
    
    override func update(currentTime: CFTimeInterval) {
        // 前回の update() からの経過時間
        let delta = currentTime - self.prevCurrentTime
        
        // タイルを表示する
        if (0 <= self.timeToWait && (self.timeToWait - delta) <= 0) {
            println("boom")
            initMakeTile()
        }
        self.timeToWait -= delta
        
        /* Called before each frame is rendered */
        score.text = "Score : \(scorePoint)"
        
        if(gameoverFlag == false){
            if(scorePoint >= 800){
                self.gameover()
            }
        }
        
        self.prevCurrentTime = currentTime
    }
}
