//
//  GameScene.swift
//  TapGame
//
//  Created by QDS on 2019-02-25.
//  Copyright © 2019 QDS. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    var backgroundSong: AVAudioPlayer?;
    var frenzySong: AVAudioPlayer?;
    var startButton = SKSpriteNode(imageNamed: "play_button");
    var moveIcon = SKSpriteNode(imageNamed: "move_Icon");
    var frenzyIcon = SKSpriteNode(imageNamed: "frenzy_Icon");
    var swipeIcon = SKSpriteNode(imageNamed: "swipe_Icon");
    var moveSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    var frenzySwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    var swipeSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    var difficultyControl = UISegmentedControl(items: ["Easy", "Medium", "Hard"]);
    var scoreLabel = SKLabelNode(text: "Score: 0");
    var endScoreLabel = SKLabelNode(text: "");
    var frenzyLabel = SKLabelNode(text: "FRENZY MODE");
    var highScoreLabel = SKLabelNode(text: "High Score: " + String(UserDefaults.standard.integer(forKey: "high_score")));
    var shape = SKShapeNode();
    var score:Int = 0;
    var counter:Int = 0;
    var targets: Array<Target> = [];
    var timer = Timer();
    var frenzyTimer = Timer();
    var gameOver: Bool = false;
    var screenSize: CGPoint = CGPoint(x: 0, y: 0);
    var targetDelay: Int = 5;
    var targetDelayCounter: Int = 0;
    var inMenu: Bool = true;
    var inEndScreen: Bool = false;
    var endScreenDelay: Int = 0;
    var endScreenBool: Bool = true;
    var doTargetsMove: Bool = false;
    var isFrenzyMode: Bool = false;
    var moveSpeed: Double = 0.04;
    var frenzyActive: Bool = false;
    var frenzyCounter: Int = 0;
    var frenzyNormalSpeed: Double = 1.5;
    var frenzyNormalMoveSpeed: Double = 0.04;
    var frenzyNormalDelay: Int = 5;
    let FRENZY_MAX: Int = 15;
    var isSwipeMode: Bool = false;
    var isCollisionOn: Bool = true;
    let NUM_SONGS: Int = 5;
    var difficulty: String = "normal";

    @objc override func didMove(to view: SKView){
        backgroundColor = SKColor.white;
        screenSize.x = view.frame.width;
        screenSize.y = view.frame.height;
        
        let path = Bundle.main.path(forResource: "frenzy.mp3", ofType:nil)!;
        let url = URL(fileURLWithPath: path);
        do {
            frenzySong = try AVAudioPlayer(contentsOf: url);
            frenzySong?.setVolume(0, fadeDuration: 0);
            frenzySong?.numberOfLoops = -1;
        } catch {
            
        }
        
        shape = SKShapeNode(circleOfRadius: screenSize.y/10/2);

        startButton.position = CGPoint(x: view.frame.width/2, y: view.frame.height/2);
        startButton.scale(to: CGSize(width: view.frame.width/13*3, height: view.frame.height/15*3));
        
        moveIcon.position = CGPoint(x: 52, y: 80);
        moveIcon.scale(to: CGSize(width: 50, height: 50));
        
        frenzyIcon.position = CGPoint(x: 125, y: 80);
        frenzyIcon.scale(to: CGSize(width: 50, height: 50));
        
        swipeIcon.position = CGPoint(x: 200, y: 80);
        swipeIcon.scale(to: CGSize(width: 50, height: 50));
        
        moveSwitch = UISwitch(frame: CGRect(x: 25, y: screenSize.y-50, width: 0, height: 0));
        moveSwitch.setOn(false, animated: false);
        moveSwitch.addTarget(self, action: #selector(switchStateChanged), for: .valueChanged);
        moveSwitch.tintColor = SKColor.lightGray;
        moveSwitch.onTintColor = SKColor.green;
        moveSwitch.thumbTintColor = SKColor.black;
        
        frenzySwitch = UISwitch(frame: CGRect(x: 100, y: screenSize.y-50, width: 0, height: 0));
        frenzySwitch.setOn(false, animated: false);
        frenzySwitch.addTarget(self, action: #selector(switchStateChanged), for: .valueChanged);
        frenzySwitch.tintColor = SKColor.lightGray;
        frenzySwitch.onTintColor = SKColor.green;
        frenzySwitch.thumbTintColor = SKColor.black;
        
        swipeSwitch = UISwitch(frame: CGRect(x: 175, y: screenSize.y-50, width: 0, height: 0));
        swipeSwitch.setOn(false, animated: false);
        swipeSwitch.addTarget(self, action: #selector(switchStateChanged), for: .valueChanged);
        swipeSwitch.tintColor = SKColor.lightGray;
        swipeSwitch.onTintColor = SKColor.green;
        swipeSwitch.thumbTintColor = SKColor.black;
        
        difficultyControl.selectedSegmentIndex = 1;
        difficultyControl.frame = CGRect(x: 20, y: 425, width: view.frame.width-40, height: 30);
        difficultyControl.backgroundColor = SKColor.white;
        difficultyControl.tintColor = SKColor.black;
        difficultyControl.addTarget(self, action: #selector(setDifficulty), for: .valueChanged);
        
        endScoreLabel.fontColor = SKColor.black;
        endScoreLabel.fontSize = 60;
        endScoreLabel.horizontalAlignmentMode = .center;
        endScoreLabel.position = CGPoint(x: view.frame.width/2, y: view.frame.height/2);
        
        scoreLabel.fontColor = SKColor.black;
        scoreLabel.fontSize = 25;
        scoreLabel.horizontalAlignmentMode = .left;
        scoreLabel.position = CGPoint(x: 30, y: view.frame.height - 50);
        
        frenzyLabel.fontColor = SKColor.init(red: 191/255, green: 11/255, blue: 11/255, alpha: 1.0);
        frenzyLabel.fontSize = 40;
        frenzyLabel.fontName = "AvenirNext-Bold";
        frenzyLabel.position = CGPoint(x: -150, y: view.frame.height / 2);
        
        highScoreLabel.fontColor = SKColor.black;
        highScoreLabel.fontSize = 25;
        highScoreLabel.horizontalAlignmentMode = .left;
        highScoreLabel.position = CGPoint(x: 175, y: view.frame.height - 50);
        
        addChild(scoreLabel);
        addChild(highScoreLabel);
        addChild(startButton);
        addChild(endScoreLabel);
        addChild(frenzyLabel);
        addChild(moveIcon);
        addChild(frenzyIcon);
        addChild(swipeIcon);
        
        view.addSubview(moveSwitch);
        view.addSubview(frenzySwitch);
        view.addSubview(swipeSwitch);
        //view.addSubview(difficultyControl);
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap));
        view.addGestureRecognizer(recognizer);
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipe));
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipe));
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipe));
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipe));
        swipeUp.direction = .up;
        swipeDown.direction = .down;
        swipeLeft.direction = .left;
        swipeRight.direction = .right;
        swipeUp.numberOfTouchesRequired = 1;
        swipeDown.numberOfTouchesRequired = 1;
        swipeLeft.numberOfTouchesRequired = 1;
        swipeRight.numberOfTouchesRequired = 1;
        view.addGestureRecognizer(swipeUp);
        view.addGestureRecognizer(swipeDown);
        view.addGestureRecognizer(swipeLeft);
        view.addGestureRecognizer(swipeRight);
    }
    
    override func update(_ currentTime: TimeInterval) {
        if inMenu{
            scoreLabel.alpha = 0.0;
            highScoreLabel.alpha = 0.0;
            startButton.alpha = 1.0;
            endScoreLabel.alpha = 0.0;
            frenzyLabel.alpha = 0.0;
            moveIcon.alpha = 1.0;
            frenzyIcon.alpha = 1.0;
            swipeIcon.alpha = 1.0;
            difficultyControl.alpha = 1.0;
        }else if inEndScreen{
            if endScreenBool{
                endScreenDelay = Int(currentTime);
                endScreenBool = false;
            }
            if endScreenDelay + 4 <= Int(currentTime){
                endScreenBool = true;
                inMenu = true;
                inEndScreen = false;
                resetGame();
            }
            scoreLabel.alpha = 0.0;
            highScoreLabel.alpha = 0.0;
            endScoreLabel.alpha = 1.0;
            frenzyLabel.alpha = 0.0;
        }else{//in game
            scoreLabel.alpha = 1.0;
            highScoreLabel.alpha = 1.0;
            startButton.alpha = 0.0;
            endScoreLabel.alpha = 0.0;
            frenzyLabel.alpha = 1.0;
            moveIcon.alpha = 0.0;
            frenzyIcon.alpha = 0.0;
            swipeIcon.alpha = 0.0;
            difficultyControl.alpha = 0.0;
            
            for s in targets{
                s.updatePulse();
            }
        }
        
        //restart music
        if backgroundSong?.isPlaying == false && !inMenu && !inEndScreen{
            setBackgroundMusic(file: "background" + String(Int.random(in: 1...NUM_SONGS)) + ".mp3");
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        contact.bodyA.applyForce(contact.bodyB.velocity, at: contact.contactPoint);
        contact.bodyB.applyForce(contact.bodyA.velocity, at: contact.contactPoint);
    }
    
    @objc func fireTargetTimer(){
        while true{
            let offset: Int = isSwipeMode == true ? 30 : 0;
            shape.position = CGPoint(x: CGFloat(Int.random(in: Int(screenSize.y/10/2) + offset...Int(screenSize.x-screenSize.y/10/2) - offset)),
                                     y: CGFloat(Int.random(in: Int(screenSize.y/10/2) + offset...Int(screenSize.y - 100) - offset)));
            var valid: Bool = true;
            for s: Target in targets{
                if shape.intersects(s.shape){
                    valid = false;
                }
            }
            if valid{
                break;
            }
        }
        
        targets.append(Target(s: shape.copy() as! SKShapeNode, d: targetDelay, v: moveSpeed, size: screenSize, dang: Int.random(in: 1...8) == 1, dir: randomDirection()));
        if doTargetsMove{
            targets.last!.beginMovement();
        }
        addChild(targets.last!.shape);
        
        for s: Target in targets{
            s.update();
            if s.hasMissed {
                if s.isDangerous{
                    s.shape.removeFromParent();
                    targets.remove(at: targets.firstIndex(where: {$0.shape == s.shape})!);
                }else{
                    endGame();
                }
            }
        }

        if frenzyActive{
            if frenzyCounter == FRENZY_MAX{
                frenzyCounter = 0;
                frenzyActive = false;
                
                timer.invalidate();
                timer = Timer.scheduledTimer(timeInterval: frenzyNormalSpeed, target: self, selector: #selector(fireTargetTimer), userInfo: nil, repeats: true);
                targetDelay = frenzyNormalDelay;
                moveSpeed = frenzyNormalMoveSpeed;
                
                self.run(SKAction.colorize(with: SKColor.white, colorBlendFactor: 0.0, duration: 2.0));
                frenzySong?.pause();
                backgroundSong?.setVolume(0.4, fadeDuration: 1);
            }else if frenzyCounter == FRENZY_MAX-2{
                frenzySong?.setVolume(0, fadeDuration: 1.5);
                frenzyCounter += 1;
            }else{
                frenzyCounter += 1;
            }
        }else{//no frenzy
            if counter == 4 && timer.timeInterval > 0.25{
                timer.invalidate();
                timer = Timer.scheduledTimer(timeInterval: timer.timeInterval - 0.05, target: self, selector: #selector(fireTargetTimer), userInfo: nil, repeats: true);
                counter = 0;
                
                if targetDelayCounter == 5{
                    if(moveSpeed > 0.01){
                        moveSpeed -= 0.01;
                    }
                    targetDelay += 1;
                    targetDelayCounter = 0;
                }else{
                    targetDelayCounter += 1;
                }
            }else{
                counter += 1;
            }
        }
    }
    
    @objc func fireFrenzyTimer(){
        frenzyLabel.run(SKAction.sequence([
            SKAction.move(to: CGPoint(x: -150, y: screenSize.y / 2), duration: 0),
            SKAction.moveTo(x: 150, duration: 0.5),
            SKAction.moveTo(x: 240, duration: 2),
            SKAction.moveTo(x: 530, duration: 0.4)]));
        frenzyActive = true;
        frenzyNormalSpeed = timer.timeInterval;
        frenzyNormalDelay = targetDelay;
        
        self.run(SKAction.colorize(with: SKColor.red, colorBlendFactor: 0.0, duration: 2.0));
        frenzySong?.setVolume(0.6, fadeDuration: 1.25);
        backgroundSong?.setVolume(0.2, fadeDuration: 0.75);
        frenzySong?.play();
        
        if doTargetsMove{
            frenzyNormalMoveSpeed = moveSpeed;
            moveSpeed = 0.02;
        }
        
        targetDelay = 7;
        timer.invalidate();
        timer = Timer.scheduledTimer(timeInterval: (isSwipeMode == true ? 0.3 : 0.2), target: self, selector: #selector(fireTargetTimer), userInfo: nil, repeats: true);
        frenzyTimer.invalidate();
        frenzyTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Int.random(in: 15...25)), target: self, selector: #selector(fireFrenzyTimer), userInfo: nil, repeats: true);
    }
    
    @objc func setDifficulty(sender: UISegmentedControl){
        difficulty = (sender.titleForSegment(at: sender.selectedSegmentIndex)?.lowercased())!;
    }
    
    @objc func switchStateChanged(_ sender:UISwitch){
        switch(sender){
        case moveSwitch:
            if sender.isOn{
                moveIcon.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: CGSize(width: 53, height: 53), duration: 0.4),
                                                                       SKAction.scale(to: CGSize(width: 48, height: 48), duration: 0.2)])));
                doTargetsMove = true;
                swipeSwitch.setOn(false, animated: true);
                isSwipeMode = false;
                swipeIcon.removeAllActions();
                swipeIcon.run(SKAction.scale(to: CGSize(width: 50, height: 50), duration: 0.5));
            }else{
                moveIcon.removeAllActions();
                moveIcon.run(SKAction.scale(to: CGSize(width: 50, height: 50), duration: 0.5));
                doTargetsMove = false;
            }
            break;
        case frenzySwitch:
            if sender.isOn{
                frenzyIcon.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: CGSize(width: 53, height: 53), duration: 0.4),
                                                                       SKAction.scale(to: CGSize(width: 48, height: 48), duration: 0.2)])));
                isFrenzyMode = true;
            }else{
                frenzyIcon.removeAllActions();
                frenzyIcon.run(SKAction.scale(to: CGSize(width: 50, height: 50), duration: 0.5));
                isFrenzyMode = false;
            }
            break;
        case swipeSwitch:
            if sender.isOn{
                isSwipeMode = true;
                swipeIcon.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: CGSize(width: 53, height: 53), duration: 0.4),
                                                                       SKAction.scale(to: CGSize(width: 48, height: 48), duration: 0.2)])));
                moveSwitch.setOn(false, animated: true);
                doTargetsMove = false;
                moveIcon.removeAllActions();
                moveIcon.run(SKAction.scale(to: CGSize(width: 50, height: 50), duration: 0.5));
            }else{
                swipeIcon.removeAllActions();
                swipeIcon.run(SKAction.scale(to: CGSize(width: 50, height: 50), duration: 0.5));
                isSwipeMode = false;
            }
            break;
        default:
            break;
        }
    }
    
    @objc func swipe(gesture: UISwipeGestureRecognizer){
        let pos = convertPoint(fromView: gesture.location(in: view));
        if isSwipeMode{
            var clickedNothing: Bool = true;
            for s in targets{
                if s.shape.contains(pos){
                    if s.direction == gesture.direction{
                        score += 1;
                        scoreLabel.text = "Score: " + String(score);
                        let x: CGFloat = gesture.direction == .left ? -500 : gesture.direction == .right ? 500 : 0;
                        let y: CGFloat = gesture.direction == .down ? -500 : gesture.direction == .up ? 500 : 0;
                        s.shape.run(SKAction.sequence([SKAction.moveBy(x: x, y: y, duration: 0.5), s.reset()]));
                        targets.remove(at: targets.firstIndex(where: {$0.shape == s.shape})!);
                    }else{
                        endGame();
                    }
                    clickedNothing = false;
                }
            }
            
            if clickedNothing{
                endGame();
            }
        }
    }
    
    @objc func tap(recognizer: UIGestureRecognizer){
        let viewLocation = recognizer.location(in: view);
        let sceneLocation = convertPoint(fromView: viewLocation);
        var clickedNothing: Bool = true;
        
        for s: Target in targets{
            if s.shape.contains(sceneLocation){
                if s.isDangerous{
                    endGame();
                }else{
                    if !isSwipeMode{
                        score += 1;
                        scoreLabel.text = "Score: " + String(score);
                        s.shape.removeFromParent();
                        targets.remove(at: targets.firstIndex(where: {$0.shape == s.shape})!);
                    }
                    clickedNothing = false;
                }
            }
        }
        if clickedNothing && !gameOver && !inMenu {
            endGame();
        }
        
        if inMenu && startButton.contains(sceneLocation){
            inMenu = false;
            timer = Timer.scheduledTimer(timeInterval: 1.50, target: self, selector: #selector(fireTargetTimer), userInfo: nil, repeats: true);
            if isFrenzyMode{
                frenzyTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Int.random(in: 15...25)), target: self, selector: #selector(fireFrenzyTimer), userInfo: nil, repeats: true);
            }
            setBackgroundMusic(file: "background" + String(Int.random(in: 1...NUM_SONGS)) + ".mp3");
            
            moveSwitch.isHidden = true;
            moveSwitch.isEnabled = false;
            frenzySwitch.isHidden = true;
            frenzySwitch.isEnabled = false;
            swipeSwitch.isHidden = true;
            swipeSwitch.isEnabled = false;
        }
    }
    
    func endGame(){
        gameOver = true;
        inEndScreen = true;
        endScoreLabel.text = String(score);
        timer.invalidate();
        frenzyTimer.invalidate();
        backgroundSong?.setVolume(0.0, fadeDuration: 3.5);
        frenzySong?.setVolume(0.0, fadeDuration: 3.5);
        self.run(SKAction.colorize(with: SKColor.white, colorBlendFactor: 0.0, duration: 2.0));
        
        for s: Target in targets{
            s.shape.removeFromParent();
            s.shape.removeAllActions();
            s.shape.removeAllChildren();
            for n in s.shapeList{
                n.removeAllActions();
            }
        }
        targets.removeAll();
        
        if(score > UserDefaults.standard.integer(forKey: "high_score")){
            UserDefaults.standard.set(score, forKey: "high_score");
            highScoreLabel.text = "High Score: " + String(UserDefaults.standard.integer(forKey: "high_score"));
        }
    }
    
    func resetGame(){
        backgroundColor = SKColor.white;
        scoreLabel.text = "Score: 0";
        highScoreLabel.text = "High Score: " + String(UserDefaults.standard.integer(forKey: "high_score"));
        score = 0;
        counter = 0;
        gameOver = false;
        targetDelay = 5;
        targetDelayCounter = 0;
        inMenu = true;
        inEndScreen = false;
        endScreenDelay = 0;
        endScreenBool = true;
        moveSpeed = 0.05;
        targetDelayCounter = 0;
        backgroundSong?.stop();
        frenzySong?.stop();
        frenzyActive = false;
        frenzyCounter = 0;
        
        moveSwitch.isHidden = false;
        moveSwitch.isEnabled = true;
        frenzySwitch.isHidden = false;
        frenzySwitch.isEnabled = true;
        swipeSwitch.isHidden = false;
        swipeSwitch.isEnabled = true;
    }
    
    func setBackgroundMusic(file: String){
        let path = Bundle.main.path(forResource: file, ofType:nil)!;
        let url = URL(fileURLWithPath: path);
        do {
            backgroundSong = try AVAudioPlayer(contentsOf: url);
            backgroundSong?.setVolume(0.4, fadeDuration: 0);
            backgroundSong?.play();
        } catch {
            // couldn't load file
        }
    }
    
    func randomDirection() -> UISwipeGestureRecognizer.Direction {
        if isSwipeMode{
            switch Int.random(in: 1...4){
            case 1:
                return UISwipeGestureRecognizer.Direction.up;
            case 2:
                return UISwipeGestureRecognizer.Direction.down;
            case 3:
                return UISwipeGestureRecognizer.Direction.left;
            case 4:
                return UISwipeGestureRecognizer.Direction.right;
            default:
                break;
            }
        }
        return UISwipeGestureRecognizer.Direction(rawValue: 0);
    }
}
