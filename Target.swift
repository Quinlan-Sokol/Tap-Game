//
//  Target.swift
//  TapGame
//
//  Created by QDS on 2019-03-05.
//  Copyright © 2019 QDS. All rights reserved.
//

import Foundation
import SpriteKit

class Target {
    var shape: SKShapeNode;
    var delay: Int;
    var hasMissed: Bool = false;
    var velocity: CGVector;
    var speed: Double;
    var screenSize: CGPoint;
    var isDangerous: Bool;
    var shapeList: [SKShapeNode] = [];
    var direction: UISwipeGestureRecognizer.Direction;
    var divider: Double = 1;
    var arrow = SKSpriteNode(imageNamed: "arrow");
    //var nathan = SKSpriteNode(imageNamed: "nathan");
    
    init(s: SKShapeNode, d: Int, v: Double, size: CGPoint, dang: Bool, dir: UISwipeGestureRecognizer.Direction){
        shape = s.copy() as! SKShapeNode;
        delay = d;
        velocity = CGVector(dx: CGFloat(Int.random(in: -3...3)), dy: CGFloat(Int.random(in: -3...3)));
        speed = v;
        screenSize = size;
        isDangerous = dang;
        direction = dir;
        var numCircles: Int = 7;
        
        if direction != UISwipeGestureRecognizer.Direction(rawValue: 0) && !isDangerous{
            numCircles = 4;
            arrow.scale(to: CGSize(width: 25, height: 25));
            arrow.zPosition = 10;
            arrow.run(SKAction.sequence([SKAction.scale(by: 0.8, duration: 0.8/divider), SKAction.scale(by: 1.25, duration: 0.2/divider)]));
            
            if(direction == UISwipeGestureRecognizer.Direction.up){
                arrow.zRotation = (.pi/2)*3;
            }else if(direction == UISwipeGestureRecognizer.Direction.down){
                arrow.zRotation = .pi/2;
            }else if(direction == UISwipeGestureRecognizer.Direction.right){
                arrow.zRotation = .pi;
            }
            
            shape.addChild(arrow);
        }
        
        var radius: Int = Int(screenSize.y/10/2);
        for _ in 0 ..< numCircles {
            shapeList.append(SKShapeNode(circleOfRadius: CGFloat(radius)));
            radius -= 4;
        }
        
        for n in shapeList {
            if isDangerous{
                n.strokeColor = SKColor.yellow;
                n.fillColor = SKColor.black;
            }else{
                n.strokeColor = SKColor.black;
                n.fillColor = SKColor.clear;
            }
            
            n.run(SKAction.sequence([SKAction.scale(by: 0.8, duration: 0.8/divider), SKAction.scale(by: 1.25, duration: 0.2/divider)]));
            shape.addChild(n);
        }
        
        //nathan.scale(to: CGSize(width: screenSize.y/10-5, height: screenSize.y/10-5));
        //shape.addChild(nathan);
    }
    
    public func updatePulse(){
        var update: Bool = true;
        for n in shapeList{
            if n.hasActions(){
                update = false;
            }
        }
        
        if update{
            divider += 0.25;
            for n in shapeList {
                n.run(SKAction.sequence([SKAction.scale(by: 0.8, duration: 0.8/divider), SKAction.scale(by: 1.25, duration: 0.2/divider)]));
            }
            if direction != UISwipeGestureRecognizer.Direction(rawValue: 0){
                arrow.run(SKAction.sequence([SKAction.scale(by: 0.8, duration: 0.8/divider), SKAction.scale(by: 1.25, duration: 0.2/divider)]));
            }
        }
    }
    
    public func update(){
        if !isDangerous{
            if delay == 1{
                for n in shapeList{
                    n.fillColor = SKColor.yellow;
                }
            }
        }
        
        if delay == 0{
            hasMissed = true;
        }
        
        delay -= 1;
    }
    
    public func reset() -> SKAction{
        return SKAction.run{
            self.shape.removeFromParent();
        }
    }
    
    public func updateMovement() -> SKAction{
        return SKAction.run {
            let newPosX: CGFloat = self.shape.position.x+self.velocity.dx;
            let newPosY: CGFloat = self.shape.position.y+self.velocity.dy;
            
            if newPosX <= self.screenSize.y/10/2 || newPosX >= self.screenSize.x-self.screenSize.y/10/2{
                self.velocity.dx *= -1;
                self.shape.removeAllActions();
                self.shape.run(SKAction.repeatForever(SKAction.group([SKAction.move(by: self.velocity, duration: self.speed), self.updateMovement()])));
            }
            if newPosY <= self.screenSize.y/10/2 || newPosY >= self.screenSize.y-100{
                self.velocity.dy *= -1;
                self.shape.removeAllActions();
                self.shape.run(SKAction.repeatForever(SKAction.group([SKAction.move(by: self.velocity, duration: self.speed), self.updateMovement()])));
            }
        }
    }
    
    public func beginMovement(){
        shape.run(SKAction.repeatForever(SKAction.group([SKAction.move(by: velocity, duration: speed), updateMovement()])));
    }
}
