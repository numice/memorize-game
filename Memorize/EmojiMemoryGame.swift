import Foundation

let animalTheme = Theme(
    name: "Animal",
    content: emojiBank["animal"]!,
    numberOfPairsOfCards: 4,
    color: "red"
)

let smileyTheme = Theme(
    name: "Smiley",
    content: emojiBank["smiley"]!,
    numberOfPairsOfCards: 5,
    color: "yellow"
)

let foodTheme = Theme(
    name: "Food",
    content: emojiBank["food"]!,
    color: "red"
)

let randomTheme = Theme(
    name: "Random",
    content: emojiBank.values.randomElement()!,
    color: "red"
)


let emojiBank = [
    "animal": ["🐷", "🐶", "🐧", "🦑", "🐳"],
    "smiley": ["🤪", "😇", "😂", "🥶", "😡"],
    "fruit": ["🍏", "🍍", "🍉", "🍓", "🍇"],
    "food": ["🥩", "🍙", "🌭", "🍕", "🍨"],
]

let themes = [smileyTheme, animalTheme, foodTheme, randomTheme]

class EmojiMemoryGame: ObservableObject {
    var theme: Theme
    @Published private var model: MemoryGame<String>
    
    init () {
        theme = themes.randomElement()!
        self.model = EmojiMemoryGame.createMemoryGame(theme: theme)
    }

    private static func createMemoryGame(theme: Theme) -> MemoryGame<String> {
        let numberOfPairsOfCards: Int = theme.numberOfPairsOfCards ?? Int.random(in: 2...theme.content.count/2)
        
        return MemoryGame<String>(theme: theme
        ) { pairIndex in
                return theme.content[pairIndex]
        }
    }
    
    // MARK: Access to the Model
    var cards: Array<MemoryGame<String>.Card> {
        model.cards
    }
    
    
    var score: Int {
        model.score
    }
    
    // MARK: Intents
    func choose(card: MemoryGame<String>.Card) {
        objectWillChange.send()
        model.choose(card: card)
    }
    
    func newGame() {
        theme = themes.randomElement()!
        let numberOfPairsOfCards: Int = self.theme.numberOfPairsOfCards ?? Int.random(in: 2...self.theme.content.count/2)
        
        model = EmojiMemoryGame.createMemoryGame(theme: theme)
    }
    
//    func selectTheme(of theme: String) {
//        createMemoryGame(theme: theme)
//    }
}
