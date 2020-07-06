import Foundation

struct Theme {
    var name: String
    var content: [String]
    var numberOfPairsOfCards: Int?
    var color: String
    
    init(name: String, content: [String], numberOfPairsOfCards: Int? = nil, color: String) {
        self.name = name
        self.content = content
        self.numberOfPairsOfCards = (numberOfPairsOfCards != nil) ? numberOfPairsOfCards: Int.random(in: 2...content.count/2)
        self.color = color
    }
}

struct MemoryGame<CardContent> where CardContent: Equatable, CardContent: Hashable {
    private(set) var cards: Array<Card> = []
    var theme: Theme
    var score = 0
    var isSeen: [CardContent: Bool] = [:]
    
    
    struct Card: Identifiable {
        var isFaceUp = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false {
            didSet {
                if isMatched {
                    stopUsingBonusTime()
                }
            }
        }
        var isSeen = false
        var content: CardContent
        var id: Int
        var bonusTimeLimit: TimeInterval = 10
        var bonusTimeRemaining: TimeInterval {
            bonusTimeLimit - totalFaceUpTime
        }
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        var lastFaceUpDate: Date?
        var totalFaceUpTime: TimeInterval = 0
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusRemaining > 0
        }
        
        mutating private func startUsingBonusTime() {
            self.lastFaceUpDate = Date()
        }
        
        mutating private func stopUsingBonusTime() {
            if self.lastFaceUpDate  != nil {
                self.totalFaceUpTime = self.totalFaceUpTime +
                Date().timeIntervalSince(self.lastFaceUpDate!)
            }
            self.lastFaceUpDate = nil
        }
    }
    
    private var indexOfOneAndOnlyOneFaceUpCard: Int? {
        get { cards.indices.filter { cards[$0].isFaceUp }.only }
        
        set {
            for index in cards.indices {
                if cards[index].isFaceUp {
                    isSeen[cards[index].content] = true
                    
                    // todo: replace with func

                    print(cards[index].totalFaceUpTime)
                }
                cards[index].isFaceUp = index == newValue
            }
        }
    }
    
    mutating func choose(card: Card) {
        if let chosenIndex = cards.firstIndex(matching: card), !cards[chosenIndex].isFaceUp, !cards[chosenIndex].isMatched {
            if let potentialMatchIndex = indexOfOneAndOnlyOneFaceUpCard {
                //todo: refactor in extension
                // todo: replace with func
                
                var scoreMultiplier = 1
                
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    print("matched!")
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    
                    scoreMultiplier = max(Int(min(cards[chosenIndex].bonusTimeRemaining, cards[potentialMatchIndex].bonusTimeRemaining)), 1)
                    
                    print("score mult: \(scoreMultiplier)")
                    
                    score += 2 * scoreMultiplier
                } else {
                    var scoreMultiplier = max(Int(max(cards[chosenIndex].bonusTimeRemaining, cards[potentialMatchIndex].bonusTimeRemaining)), 1)
                    
                    if isSeen[cards[chosenIndex].content]! {
                        score -= 1 * scoreMultiplier
                    }
                    
                    if isSeen[cards[potentialMatchIndex].content]! {
                        score -= 1 * scoreMultiplier
                    }
                }
                self.cards[chosenIndex].isFaceUp = true
                // todo: replace with func
                print("card chosen: \(cards[chosenIndex])")
                
            } else {

                indexOfOneAndOnlyOneFaceUpCard = chosenIndex
            }
        }
        
    }
    
    init(theme: Theme, cardContentFactory: (Int) -> CardContent) {
        self.theme = theme
        createCards(theme: theme, cardContentFactory: cardContentFactory)
    }
    
    mutating func createCards (theme: Theme, cardContentFactory: (Int) -> CardContent) {
        let numberOfPairsOfCards = theme.numberOfPairsOfCards ?? Int.random(in: 2...theme.content.count/2)
        
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id: pairIndex*2+1))
            isSeen[content] = false
            print(isSeen)
        }
        cards.shuffle()
    }
    

}
