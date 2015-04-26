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

let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
let myBoundSizeStr: NSString = "Bounds width: \(myBoundSize.width) height: \(myBoundSize.height)"

let TileSize:CGFloat = myBoundSize.width * 0.1

let BoardLayerPosition = CGPointMake(0.11*myBoundSize.width, -0.22*myBoundSize.width)
let TextFieldPosition = CGPointMake(20, -20)
let TextFieldPosition2 = CGPointMake(20, -60)

class GameScene: BaseScene {
    var board = SKSpriteNode()
    let boardLayer = SKNode()
    let shapeLayer = SKNode()
    
    let textLayer = SKNode()
    let strLayer = SKNode()
    
    let scoreLabel = SKLabelNode()
    
    var tileArrayPos = Array(count: NumColumns, repeatedValue: Array(count: NumRows, repeatedValue: CGPoint()))
    var touchedNode = SKNode()
    var moveActionFlag = false
    var score = 0
    
    // 最後に追加したタイル
    var currentTile: SKSpriteNode!
    
    // タイルが表示された時刻
    var tileDisplayedTime:NSTimeInterval = NSTimeInterval(0)
    var elapsedTime:Double = -1.0
    
    
    override init(size: CGSize, gameViewController: GameViewController) {
        super.init(size: size, gameViewController: gameViewController)
        
        // websocket 設定
        initWebSocket();
        
        // scene 初期化
        initScene();
        
        // ゲーム参加通知
        webSocket().trigger("join_game", data: wsData([:]), success: nil, failure: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Error")
    }
    
    func initWebSocket() {
        // WebSocket のイベントハンドラを登録する
        
        // --- ここからイベント登録 ---
        
        // ゲームイベント (new_round) 受信時のイベントハンドラ
        webSocket().bind("new_round", callback: { (data) -> Void in
            println("new_round")
            
            // 受信データ取り出し
            let dict: NSMutableDictionary = (data as? NSMutableDictionary)!
            let triggerTimeStr: String = dict["trigger_time"] as! String // msまで含めた次にタイルを表示してほしい時刻
            let triggerTime = self.defaultDateFormatter().dateFromString(triggerTimeStr)!
            let nextX = dict["x"] as! Int
            let nextY = dict["y"] as! Int
            let nextColor = dict["color"] as! Int
            
            println("nextX =\(nextX)")
            println("nextY =\(nextY)")
            
            // タイル生成
            let nextTile = self.makeTile(nextX, y: nextY, z: nextColor)
            
            println("triggerTime=\(triggerTime)")
            
            // 表示
            NSTimer.scheduledTimerWithTimeInterval(triggerTime.timeIntervalSinceNow, repeats: false, handler: { (timer) -> Void in
                self.showTile(nextTile)
            })
        })
        
        // みんなから経過時間を集計するために呼ばれるイベントのイベントハンドラ
        webSocket().bind("winner_approval", callback: { (data) -> Void in
            // タイル消す
            // TODO: implement this

            self.currentTile.removeFromParent()
            println("winner_approval")

            // 受信データ取り出し
            let dict: NSMutableDictionary = (data as? NSMutableDictionary)!
            let minElapsedTime: Double = dict["elapsed_time"] as! Double
            
            // 送信データを生成
            var wsdata: NSMutableDictionary = [:]
            if (0 < self.elapsedTime) {
                if (self.elapsedTime < minElapsedTime) {
                    wsdata["approve"] = false
                    wsdata["elapsed_time"] = self.elapsedTime
                } else {
                    // approve する
                    wsdata["approve"] = true
                }
            } else {
                // approve する
                wsdata["approve"] = true
            }
            
            // データ送信
            self.webSocket().trigger("winner_approval", data: self.wsData(wsdata), success: nil, failure: nil)
        })
        
        // 一試合の終わりのイベントを受信したときのイベントハンドラ
        webSocket().bind("close_round", callback: { (data) -> Void in
            println("close_round")
            
            // データ取り出し
            let dict: NSMutableDictionary = (data as? NSMutableDictionary)!
            let winner: String = dict["winner"] as! String // 勝者の id
            let addScore: Int = dict["add_score"] as! Int
            
            // TODO: 勝ったかどうか判断して表示する
            
            if (self.myId() == winner) {
                self.score += addScore
                self.updateScore()
            }
        })
        
        // 全試合の終わりのイベントを受信したときのイベントハンドラ
        webSocket().bind("close_game", callback: { (data) -> Void in
            println ("close_game")
            
            // データ取り出し
            let dict: NSMutableDictionary = (data as? NSMutableDictionary)!
            let winner: String = dict["winner"] as! String // 勝者の id
            let scores: NSMutableDictionary = (dict["scores"] as? NSMutableDictionary)!
            
            self.gameover(self.myId() == winner, scores: scores)
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
        
        board = SKSpriteNode(color:UIColor(red: 0, green: 0, blue: 0, alpha: 0),size:CGSizeMake(CGFloat(NumColumns)*TileSize, CGFloat(NumRows)*TileSize))
        board.name = "board"
        board.anchorPoint = CGPointMake(0, 1.0)
        board.position = BoardLayerPosition
        
        let textfield = SKSpriteNode(color:UIColor(red: 0, green: 0, blue: 0, alpha: 0),size:CGSizeMake(CGFloat(NumColumns)*TileSize, 80))
        textfield.position = TextFieldPosition
        //textfield.anchorPoint = CGPointMake(0, 1.0)
        
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame)*0.8, CGRectGetMidY(self.frame)*0.25)
        textfield.addChild(scoreLabel)
        
        strLayer.position = TextFieldPosition
        strLayer.addChild(textfield)
        textLayer.addChild(strLayer)
        
        shapeLayer.position = BoardLayerPosition
        shapeLayer.addChild(board)
        boardLayer.addChild(shapeLayer)
        
        addChild(boardLayer)
        addChild(textLayer)
        
        updateScore()
    }
    
    override func didMoveToView(view: SKView) {
        
    }
    
    func randomColor(x: Int)->UIColor{
        //0:red,1:green,2:blue,3:yellow
        let rnd = x
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
    
    func updateScore() {
        scoreLabel.text = "Score: \(score)"
    }
    
    func showTile(tile: SKSpriteNode) {
        board.addChild(tile)
        currentTile = tile
        tileDisplayedTime = NSDate.timeIntervalSinceReferenceDate()
        elapsedTime = -1.0
    }
    
    func makeTile(x: Int, y: Int, z:Int) -> SKSpriteNode {
        let sprite = makeTileOne(z)
        sprite.position = CGPointMake(CGFloat(x)*TileSize,-CGFloat(y)*TileSize)
        tileArrayPos[x][y] = sprite.position
        return sprite
    }
    
    func makeTileOne(x: Int) -> SKSpriteNode{
        let sprite = SKSpriteNode()
        sprite.anchorPoint = CGPointMake(0, 1.0)
        sprite.alpha *= 1.0
        sprite.color = randomColor(x)
        sprite.size = CGSizeMake(TileSize-1, TileSize-1)
        
        return sprite
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* タッチされるとき */
        
        for touch in touches {
            let location = (touch as! UITouch).locationInNode(self)
            //printf(location)
            touchedNode = self.nodeAtPoint(location)
            for node in self.board.children{
                if(touchedNode == node as! NSObject && !moveActionFlag){
                    let now = NSDate.timeIntervalSinceReferenceDate()

                    elapsedTime = (now - self.tileDisplayedTime) * 1000
                    println("elapsed_Time=\(elapsedTime)")
                    
                    var data: NSDictionary = self.wsData([
                        "elapsed_time": elapsedTime
                    ])
                    
                    // メッセージを送る
                    webSocket().trigger("tile_pushed", data: data,
                        success: { (data) -> Void in
                            println("tile_pushed: success")
                        },
                        failure: { (data) -> Void in
                            println("tile_pushed: failure")
                        }
                    )
                    
                    self.removeChildrenInArray([touchedNode])
                    board.removeChildrenInArray([touchedNode])
                }
            }
        }
    }
    
    /* ゲームオーバー */
    func gameover(won: Bool, scores: NSMutableDictionary) {
        // 画面に表示
        let gameoverLabel = SKLabelNode()
        gameoverLabel.text = won ? "You Win" : "Try again!"
        gameoverLabel.fontSize = myBoundSize.width*0.2
        gameoverLabel.fontColor = won ? SKColor(red: 0.7, green: 0, blue: 0, alpha: 1) : SKColor(red: 0, green: 0, blue: 0.7, alpha: 1)
        gameoverLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(gameoverLabel)
        
        // 一定時間後にゲームオーバー画面に遷移する
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.5), repeats: false, handler: { (timer) -> Void in
            let scene = GameoverScene(size: self.size, gameViewController: self.gameViewController, scores: scores)
            let transition = SKTransition.fadeWithDuration(0.2)
            
            (self.gameViewController.view as! SKView).presentScene(scene, transition: transition)
        })
    }
    
    /* Called before each frame is rendered */
    override func update(currentTime: CFTimeInterval) {
        // do something if necessary
    }
}
