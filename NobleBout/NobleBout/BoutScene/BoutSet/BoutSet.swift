//
//  BoutSet.swift
//  NobleBout
//
//  Created by Lee Davis on 1/2/21.
//  Copyright © 2021 EightFoldGames. All rights reserved.
//

import SpriteKit


final class BoutSet {
    var playerInfo: PlayerInfoHUD?
    var playerInterface: PlayerInterface?
    var playerInteraction: PlayerInteraction?
    let scoreKeeper = ScoreKeeper()
    
    init(_ dict: [String: Any]) {
        guard let labelOne = dict["hp1"] as? SKLabelNode,
              let labelTwo = dict["hp2"] as? SKLabelNode,
              let avaterOne = dict["p1"] as? SKSpriteNode,
              let avaterTwo = dict["p2"] as? SKSpriteNode
        else {
            print("No good, could not find some assets in scene.")
            return
        }
                
        playerInfo = PlayerInfoHUD(labelOne, labelTwo)
        playerInterface = PlayerInterface(avaterOne, avaterTwo)
        
        let buttons = dict.filter { key, value -> Bool in
            return buttonStrs.contains(key)
        }.compactMap { _, value -> Button? in
            return value as? Button
        }
        
        playerInteraction = .init(buttons: buttons)
        
        configure()
    }
    
    func configure() {
        scoreKeeper.delegateUI = playerInfo
    }
}