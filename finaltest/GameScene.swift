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

class GameScene: SKScene {
    var webSocket: WebSocketRailsDispatcher
    
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
    
    init(size:CGSize, webSocket:WebSocketRailsDispatcher){
        self.webSocket = webSocket

        super.init(size: size)
        
        // websocket 設定
        initWebSocket();
        
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Error")
    }
    
    func initWebSocket() {
        // TODO: WebSocket のイベントハンドラを登録する
        
        // ------------------
        // テスト用サンプルコード
        // ------------------
        
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
            self.webSocket.trigger("websocket_game", data: data, success: nil, failure: nil)
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
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        initMakeTile()
        
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
                        let elapsedTime = (now - self.tileDisplayedTime) * 1000
                        println("elapsed_Time=\(elapsedTime)")
                        
                        var data: Dictionary = [
                            "id": "*randomId*",
                            "data": [
                                "elapsed_time": elapsedTime
                            ]
                        ]
                        
                        // TODO webSocket.trigger でメッセージを送る
                        webSocket.trigger("tile_pushed", data: data, success: { (data) -> Void in
                            println("tile_pushed: success")
                        }, failure: { (data) -> Void in
                            println("tile_pushed: failure")
                        })
                        
                        self.removeChildrenInArray([touchedNode])
                        board.removeChildrenInArray([touchedNode])
                        scorePoint += 100
                        initMakeTile()
                        
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
        /* Called before each frame is rendered */
        score.text = "Score : \(scorePoint)"
        
        if(gameoverFlag == false){
            if(scorePoint >= 800){
                self.gameover()
            }
        }
    }
}
