//
//  Grid.swift
//  StairTris
//
//  Created by George Hong on 7/11/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import Foundation
import SpriteKit

class Grid: SKSpriteNode {
    
    /* Grid array dimensions */
    let rows = 7
    let columns = 15
    
    /* Individual cell dimension, calculated in setup*/
    var cellWidth = 0
    var cellHeight = 0
    
    /* Cell Array */
    var gridArray = [[Cell]]()
    //ScrollLayer
    var scrollLayer: SKNode!
    
    func addCellAtGrid(x: Int, y: Int){
        let cell = (SKScene(fileNamed: "Cell")?.childNode(withName: "cell") as! SKSpriteNode).copy() as! Cell
        let gridPosition = CGPoint(x: x*cellWidth+20, y: y*cellHeight+20)
        cell.position = gridPosition
        cell.isHidden = true
        addChild(cell)
        gridArray[x].append(cell)
    }
    
    func populateGrid() {
        /* Populate the grid with cells */
        
        /* Loop through columns */
        for gridX in 0..<columns {
            
            /* Initialize empty column */
            gridArray.append([])
            
            /* Loop through rows */
            for gridY in 0..<rows {
                let nodeAtPoint = atPoint(CGPoint(x: gridX*cellWidth + cellWidth/2,y: gridY*cellHeight+cellHeight/2))
                if nodeAtPoint.name == "startingCell"{
                    gridArray[gridX].append(nodeAtPoint as! Cell)
                }
                    /* Create a new cell at row / column position */
                else {
                    addCellAtGrid(x:gridX, y:gridY)
                }
            }
        }
    }
    
    func scrollCells() {
        /* Loop through columns */
        for gridX in 0..<columns {
            
            /* Loop through rows */
            for gridY in 0..<rows {
                if gridX == 0 || gridY == 0 {
                    gridArray[gridX][gridY].removeFromParent()
                }
                else {
                    gridArray[gridX-1][gridY-1] = gridArray[gridX][gridY]
                    //uncomment to make it slide left then down.
                    /*let moveRight = SKAction(named:"moveRight")!
                    let moveDown = SKAction(named:"moveDown")!
                    let moveSequence = SKAction.sequence([moveRight,moveDown])
                    gridArray[gridX][gridY].run(moveSequence)*/
                }
                if gridX == columns-1 || gridY == rows-1 {
                    let cell = (SKScene(fileNamed: "Cell")?.childNode(withName: "cell") as! SKSpriteNode).copy() as! Cell
                    addChild(cell)
                    cell.isHidden = true
                    cell.position = CGPoint(x: gridX*cellWidth+20, y: gridY*cellHeight+20)
                    gridArray[gridX][gridY] = cell
                }
            }
        }
    }
    
    func validMove(piece: Piece) -> Bool {
        var valid = false
        for cell in piece.children as! [SKSpriteNode] {
            if cell.isHidden { continue }
            else {
                let position = piece.convert(cell.position, to: self.scene!)
                let location = (self.scene?.convert(position, to: self))!
                if location.x < 240 || location.y < 0 {
                    return false
                }
                else if location.x > 600 || location.y > 260 {
                    return false
                }
                else if gridArray[Int(location.x)/cellWidth][Int(location.y)/cellHeight].name != "cell" {
                    return false
                }
                if gridArray[Int(location.x)/cellWidth][Int(location.y-40)/cellHeight].name != "cell" {
                    valid = true
                }
            }
        }
        return valid
    }
    
    func addPiece(piece: Piece, offset: CGFloat) {
        //for loop iterate through children of piece
        //convert each piece's position to position on grid
        //use gridArray[Int(location.x)/cellWidth][Int(location.y)/cellHeight] to determine which cell on the grid it should go to
        //remove cell as child of parent
        //add cell as child of grid, set position to grid position that you determined
        for cell in piece.children as! [SKSpriteNode] {
            if cell.isHidden { continue }
            else {
                let position = piece.convert(cell.position, to: self.scene!)
                let location = (self.scene?.convert(position, to: self))!
                let gridPositionX = CGFloat((Int(location.x)/cellWidth) * cellWidth)
                let gridPositionY = CGFloat((Int(location.y)/cellHeight) * cellHeight)
                gridArray[Int(location.x + offset)/cellWidth][Int(location.y + offset)/cellHeight].removeFromParent()
                gridArray[Int(location.x + offset)/cellWidth][Int(location.y + offset)/cellHeight] = cell as! Cell
                cell.removeFromParent()
                let scrollLayer = self.childNode(withName: "scrollLayer")!
                scrollLayer.addChild(cell)
                cell.position = (self.convert(CGPoint(x: gridPositionX + CGFloat(cellWidth/2) - offset, y: gridPositionY + CGFloat(cellHeight/2) - offset), to: scrollLayer))
                cell.physicsBody?.categoryBitMask = 2
            }
        }
        piece.removeFromParent()
        addChild(piece)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        /* Calculate individual cell dimensions */
        cellWidth = Int(size.width) / columns
        cellHeight = Int(size.height) / rows
        scrollLayer = childNode(withName: "scrollLayer")!
        
        //Populate grid with cells
        populateGrid()
    }
}
