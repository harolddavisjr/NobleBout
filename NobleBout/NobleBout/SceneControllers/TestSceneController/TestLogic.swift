//
//  TestLogic.swift
//  NobleBout
//
//  Created by Lee Davis on 10/4/20.
//  Copyright © 2020 EightFoldGames. All rights reserved.
//


import Foundation
import SpriteKit

// MARK: - Enums
enum Winner: String {
    case pOne, pTwo, draw
}
enum Choice: String {
    case paper, rock, scissor
}

var message: String = ""

// Posible choices
let choices: [Choice] = [.paper, .rock, .scissor]
// Janken
typealias JankenCombo = (Choice, Choice)
func jankenKeyGen(_ combo: JankenCombo) -> String {
    return "\(combo.0)V\(combo.1)"
}

let resultsDict: [String: Winner] = {
    return [
        // - Paper:
        "paperVrock": .pOne,
        "paperVscissor": .pTwo,
        "paperVpaper": .draw,
        // - Scissors:
        "scissorVrock": .pTwo,
        "scissorVpaper": .pOne,
        "scissorVscissor": .draw,
        // - Rock
        "rockVscissor": .pOne,
        "rockVpaper": .pTwo,
        "rockVrock": .draw,
    ]
}()

struct JankenRound {
    let pOChoice: Choice
    let pTChoice: Choice
    
    func winner() -> Winner {
        guard (resultsDict[jankenKeyGen((pOChoice, pTChoice))] != nil) else {
            print("\(jankenKeyGen((pOChoice, pTChoice))) is not in the dictionary.")
            return .draw
        }
        
        return resultsDict[jankenKeyGen((pOChoice, pTChoice))]!
    }
    
    init(_ p1c:Choice, _ p2c: Choice) {
        self.pOChoice = p1c
        self.pTChoice = p2c
    }
}


enum Buff {
    // Buffs
    case hp
    case def
    case special
    case energy
    // Unique
    case fire
    case healing
    case stun
    case poison
    case debuff
    
    case atkL // Low incease in power
    case atkM // Medium incease in power
    case atkH // High incease in power
    
    case defL // small increase in def
    case defM // increase in def
    case defH // big increase in def
}

enum Hero: String {
    case masa
    case tetsu
    case eris
    case abziu
    case griff
    
    var natruralBuffs: [Buff] {
        let buffs: [Buff]
        switch self {
            case .masa:
            buffs = [.stun]
            case .tetsu:
            buffs = [.fire]
            case .eris:
            buffs = [.healing]
            case .abziu:
            buffs = [.poison]
            case .griff:
            buffs = [.debuff]
        }
        return buffs
    }
    
}

class Player {
    var HP: Int = 100
    var TP: Int = 60
    
    private let hero: Hero
    private var passiveAbilities: [Buff] = []
    
    init(_ hero: Hero) {
        self.hero = hero
        self.passiveAbilities = hero.natruralBuffs
    }
    
    func refresh() {
        self.HP = 100
        self.TP = 60
    }
    
    private var spirite: Int = 0
    
    func spiritOrbs() -> Int {
        var total = spirite
        var spiritOrbNum: Int = 0
        
        while total > 0 || !((total - 20) < 0) || spiritOrbNum < 4 {
            total -= total - 20
            spiritOrbNum += 1
        }
        
        return spiritOrbNum
    }
}

class Bout {
    var playerOne: Player!
    var playerTwo: Player!
    
    var boutEnded: Bool = false
    var winner: Winner?
    
    init() { // set player based on choice
        testSetPlayers()
    }
    
    convenience init(_ p1: Player, _ p2: Player) {
        self.init()
        
        self.playerOne = p1
        self.playerTwo = p2
    }
    
    func testGame() {
        while boutEnded != true {
            if (playerOne.HP > 0) && (playerTwo.HP > 0) {
                play(.paper,.rock){_ in }
            }
            else  {
                end()
            }
        }
    }
    
    func play(_ p1c: Choice, _ p2c: Choice, completion: @escaping(_ shouldContinue: Bool?)->()) {
        let j = JankenRound(p1c, p2c)
        switch j.winner() {
            case .pOne:
                playerTwo.HP -= 10
                message = "p2 hp decreased"
            case .pTwo:
                playerOne.HP -= 10
                message = "p2 hp decreased"
            case .draw:
                message = "Draw"
            break
        }
        
        winner = j.winner()
        
        completion((playerOne.HP > 0) && (playerTwo.HP > 0))
    }
    
    private func end() {
        if playerOne.HP <= 0 {
            winner = .pTwo
        }
        else if playerTwo.HP <= 0 {
            winner = .pOne
        }
        else {
            winner = .draw
        }
        
        boutEnded.toggle()
    }
    
    private func testSetPlayers() {
        // set player properties
        playerOne = Player(.masa)
        playerTwo = Player(.tetsu)
    }
}

class Match {
    var p1Win: Int = 0
    var p2Win: Int = 0
    
    var p1Choice: Choice?
    var p2Choice: Choice?
    
    var matchEnded: Bool = false
    private var statusLabel: SKLabelNode = SKLabelNode()
    
    var currentBout: Bout
    
    init(p1: Player, p2: Player) {
        currentBout = Bout(p1, p2)
    }
    
    
    func start() {
        // prompt for choice
        statusLabel.text = "Make a choice!"
        
        NotificationCenter.default.addObserver(self, selector: #selector(playWithChoices), name: NSNotification.Name(rawValue: "choiceMade"), object: nil)

        // pick a random choice for Computer
        
        // use current bout to play a bout
        // if no player HP is 0 or lower than prompt again.
        // if bout should end then
        // - award winner a win
        // - check if a player's score has reach 2 than end the round
        // - set matchEnded Bool to true
    }
    
    private func end() {}
    func pause() {}
    
    func setBout(_ choice: Choice) {
        let randomNum = arc4random_uniform(UInt32(choices.count))
        let p2C = choices[Int(randomNum)]
        
        p1Choice = choice
        p2Choice = p2C
    }
    
    @objc func playWithChoices() {
        guard let c1 = p1Choice,
              let c2 = p2Choice else { return }
        
        if !currentBout.boutEnded {
            currentBout.play(c1, c2) { (shouldContinue) in
                self.statusLabel.text = "\(self.presentWinner())"

                if let shouldContinue = shouldContinue {
                    if !shouldContinue {
                        self.statusLabel.text = "Winner \(self.presentWinner())"
                        self.matchEnded.toggle()
                    }
                }
            }
        }
        else {
            matchEnded.toggle()
        }
    }
    
    private func presentWinner() -> Winner {
        self.statusLabel.text = message
        return currentBout.winner ?? .draw
    }
    
    func setStatusLable(_ lbl: SKLabelNode) {
        statusLabel = lbl
    }
}



//  let b = Bout()
//  b.testGame()
//  b.winner
//  b.playerTwo.HP





