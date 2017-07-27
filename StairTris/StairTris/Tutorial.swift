//
//  Tutorial.swift
//  StairTris
//
//  Created by George Hong on 7/24/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import Foundation
import GameplayKit

class Tutorial: SKScene, SKPhysicsContactDelegate {
    
    enum GameState {
        case death, blockPlacement, arrayNode, rotateArea, paused, freePlay
    }
    
    var nextLessonLabel:SKLabelNode!
    var heroLabel: SKLabelNode!
    var blockLabel: SKLabelNode!
    var currentGameState: GameState = .death {
        didSet {
            switch currentGameState {
            case .blockPlacement:
                darkScreen1.isHidden = true
                darkScreen4.isHidden = true
                darkScreen2.isHidden = false
                darkScreen3.isHidden = false
                heroLabel.isHidden = true
                blockLabel.isHidden = false
                holdGesture.isHidden = false
                break
            case .arrayNode:
                darkScreen3.isHidden = true
                darkScreen1.isHidden = false
                darkScreen2.isHidden = false
                darkScreen4.isHidden = false
                rotateLabel.isHidden = true
                nextBlockLabel.isHidden = false
                pointer.isHidden = false
                rotateLabel.isHidden = true
                break
            case .rotateArea:
                darkScreen2.isHidden = false
                darkScreen3.isHidden = false
                darkScreen1.isHidden = false
                darkScreen4.isHidden = false
                blockLabel.isHidden = true
                rotateLabel.isHidden = false
                holdGesture.isHidden = false
                tapGesture.isHidden = false
                break
            case .freePlay:
                darkScreen1.isHidden = true
                darkScreen2.isHidden = true
                darkScreen3.isHidden = true
                darkScreen4.isHidden = true
                rotateLabel.isHidden = true
            default:
                break
            }
        }
    }
    
    var finishedLabel: SKLabelNode!
    var holdGesture: SKSpriteNode!
    var tapGesture: SKSpriteNode!
    var pointer: SKSpriteNode!
    var pointer2: SKSpriteNode!
    var nextBlockLabel: SKLabelNode!
    var timeLimit: CFTimeInterval = 2
    var gridNode: Grid!
    var scoreLabel: SKLabelNode!
    var piece: Piece!
    var pieceArray: ArrayNode!
    var scrollTimer: CFTimeInterval = 2
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var secondFinger = false //newBlock = true
    var score: Int = 0
    var touching = false
    var hero: SKSpriteNode!
    var scrollLayer: SKNode!
    var offset: CGFloat = 0
    var canShake = false
    var jumpPower: CGFloat = 10
    var jumping = false
    var sidePower: CGFloat = 3
    var darkScreen1, darkScreen2, darkScreen3, darkScreen4: SKSpriteNode!
    var nextButton: MSButtonNode!
    var youDied: SKLabelNode!
    var skipper: MSButtonNode!
    var rotateLabel: SKLabelNode!
    var scaleLocation: CGPoint!
    
    override func didMove(to view: SKView) {
        finishedLabel = childNode(withName: "finishedLabel") as! SKLabelNode
        finishedLabel.isHidden = true
        nextLessonLabel = childNode(withName: "nextLessonLabel") as! SKLabelNode
        nextLessonLabel.isHidden = true
        holdGesture = childNode(withName: "holdGesture") as! SKSpriteNode
        holdGesture.isHidden = true
        tapGesture = childNode(withName: "tapGesture") as! SKSpriteNode
        tapGesture.isHidden = true
        pointer = childNode(withName: "pointer") as! SKSpriteNode
        pointer.isHidden = true
        pointer2 = childNode(withName: "pointer2") as! SKSpriteNode
        pointer2.isHidden = true
        nextBlockLabel = childNode(withName: "nextBlockLabel") as! SKLabelNode
        nextBlockLabel.isHidden = true
        gridNode = childNode(withName: "//gridNode") as! Grid
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        rotateLabel = childNode(withName: "rotateLabel") as! SKLabelNode
        rotateLabel.isHidden = true
        hero = childNode(withName: "//hero") as! SKSpriteNode
        pieceArray = childNode(withName: "arrayNode") as! ArrayNode
        scrollLayer = childNode(withName: "//scrollLayer")!
        darkScreen1 = childNode(withName: "darkScreen1") as! SKSpriteNode
        darkScreen2 = childNode(withName: "darkScreen2") as! SKSpriteNode
        darkScreen3 = childNode(withName: "darkScreen3") as! SKSpriteNode
        darkScreen4 = childNode(withName: "darkScreen4") as! SKSpriteNode
        heroLabel = childNode(withName: "heroLabel") as! SKLabelNode
        blockLabel = childNode(withName: "blockLabel") as! SKLabelNode
        blockLabel.isHidden = true
        darkScreen2.isHidden = true
        nextButton = childNode(withName: "//nextButton") as! MSButtonNode
        nextButton.selectedHandler = {
            let scene = Tutorial(fileNamed: "Tutorial")!
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
            scene.currentGameState = .blockPlacement
        }
        skipper = childNode(withName: "skipper") as! MSButtonNode
        skipper.selectedHandler = {
            if self.currentGameState == .death {
                let scene = Tutorial(fileNamed: "Tutorial")!
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
                scene.currentGameState = .blockPlacement
            }
            else if self.currentGameState == .blockPlacement {
                let scene = Tutorial(fileNamed: "Tutorial")!
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
                scene.currentGameState = .blockPlacement
                scene.currentGameState = .rotateArea
            }
            else if self.currentGameState == .rotateArea {
                let scene = Tutorial(fileNamed: "Tutorial")!
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
                scene.currentGameState = .blockPlacement
                scene.currentGameState = .rotateArea
                scene.currentGameState = .arrayNode
                scene.tapGesture.isHidden = true
                scene.holdGesture.isHidden = true
            }
            else {
                let scene = MainMenu(fileNamed: "MainMenu")!
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }
        
        youDied = childNode(withName: "youDied") as! SKLabelNode
        youDied.isHidden = true
        
        
        pieceArray.setUpArray()
        
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        if contactA.node == nil {
            return
        }
        if contactB.node == nil {
            return
        }
        /* Get references to the physics body parent SKSpriteNode */
        // One of them is hero and the other is the death blocks. else if it is a cell.
        if contactA.categoryBitMask == 1 || contactB.categoryBitMask == 1 {
            if contactB.categoryBitMask == 4 || contactA.categoryBitMask == 4 {
                self.isPaused = true
                youDied.isHidden = false
            }
            else if contactB.categoryBitMask == 2 || contactA.categoryBitMask == 2 {
                if contactA.categoryBitMask == 1 {
                    contactA.velocity = CGVector(dx: 0, dy: 0)
                    
                }
                else {
                    contactB.velocity = CGVector(dx: 0, dy: 0)
                }
                jumpPower = 8
                sidePower = 3
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == .death || currentGameState == .paused { }
        else if !holdGesture.isHidden && currentGameState == .blockPlacement {
            holdGesture.isHidden = true
        }
        else if !holdGesture.isHidden && !tapGesture.isHidden {
            holdGesture.isHidden = true
            tapGesture.isHidden = true
            darkScreen1.isHidden = true
            darkScreen2.isHidden = true
            darkScreen4.isHidden = true
            rotateLabel.isHidden = true
        }
        else if currentGameState == .arrayNode {
            nextBlockLabel.isHidden = true
            pointer.isHidden = true
            currentGameState = .blockPlacement
            currentGameState = .rotateArea
            currentGameState = .freePlay
            darkScreen3.isHidden = true
        }
        else {
            let touch = touches.first!
            let location = touch.location(in: self)
            let nodeAtPoint = atPoint(location)
            if nodeAtPoint.name == "gameOver" { return }
            if !touching && piece == nil {
                pieceArray.array[0].removeFromParent()
                piece = pieceArray.array[0]
                //this is is you want the node to scale up...
                if currentGameState == .arrayNode {
                    /*
                     let heading = atan2(location.x - 388, location.y - 20)
                     let xScale = cos(heading)
                     let yScale = sin(heading)
                     piece.x += 1 * xScale
                     piece.y += 1 * yScale*/
                }
                piece.xScale = 1
                piece.yScale = 1
                addChild(piece)
                piece.position = location
                if piece.position.x < 80 - offset {
                    piece.position.x = 80 - offset
                }
                pieceArray.moveArray()
            }
            else if touching {
                secondFinger = true
                if piece.type != .square {
                    piece.rotate()
                }
            }
            touching = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState != .death && currentGameState != .paused {
            if piece != nil && secondFinger != true {
                let touch = touches.first!
                let location = touch.location(in: self)
                piece.position = location
                //x clamp on left side
                if piece.position.x < 80 - offset {
                    piece.position.x = 80 - offset
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if secondFinger {
            secondFinger = false
        }
        else if piece != nil {
            if gridNode.validMove(piece: piece,offset: offset) {
                score += 1
                gridNode.addPiece(piece: piece,offset: offset)
                piece.removeFromParent()
                piece = nil
                let sound = SKAction.playSoundFileNamed("NFF-menu-03-a", waitForCompletion: false)
                self.run(sound)
            }
            touching = false
        }
    }
    
    func scrollTheLayer() {
        scrollLayer.position.y -= CGFloat((40*fixedDelta)/timeLimit)
        scrollLayer.position.x -= CGFloat((fixedDelta*40)/timeLimit)
        offset += CGFloat((fixedDelta*40)/timeLimit)
    }
    
    func resetTimer() {
        hero?.physicsBody?.applyImpulse(CGVector(dx: sidePower, dy: self.jumpPower))
        jumping = false
        scrollTimer = timeLimit
        offset = 0
    }
    
    func shake() {
        if canShake {
            print("I am SHOOK")
            jumpPower = 12
            sidePower = 2
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if score == 5 {
            pointer2.isHidden = false
            if currentGameState == .freePlay {
                finishedLabel.isHidden = false
            }
            else {
                nextLessonLabel.isHidden = false
            }
        }
        if currentGameState == .death {
            // Called before each frame is rendered
            if scrollTimer < 1.5 && !jumping {
                jumping = true
                let moveBack = SKAction(named: "FasterJump")!
                hero.run(moveBack)
            }
            scrollTheLayer()
            scrollTimer -= fixedDelta
            if scrollTimer > 0 {
            }
            else {
                if timeLimit > 5 {
                    timeLimit -= 1
                }
                resetTimer()
                if gridNode.scrollCells() {
                    //do nothing.
                }
            }
        }
        scoreLabel.text = String(score)
    }
    
    
    
    
    
}