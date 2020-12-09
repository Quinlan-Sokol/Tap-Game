//
//  GameViewController.swift
//  TapGame
//
//  Created by QDS on 2019-02-25.
//  Copyright © 2019 QDS. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad(){
        let scene = GameScene(size: view.frame.size);
        let skView = view as! SKView;
        skView.presentScene(scene);
    }
}
