import Foundation

nonisolated struct ShoppingListItem: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var name: String
    var amount: String
    var category: String
    var isChecked: Bool = false

    static func category(for ingredientName: String) -> String {
        let n = ingredientName.lowercased()

        let meatFish: [String] = [
            "chicken", "beef", "salmon", "tuna", "turkey", "pork", "shrimp", "fish", "lamb", "cod",
            "tilapia", "sardine", "anchovy", "crab", "lobster", "scallop", "duck", "veal", "bacon",
            "ham", "sausage", "prosciutto", "salami", "steak", "mince", "ground beef", "venison",
            "rabbit", "quail", "trout", "mackerel", "herring", "squid", "calamari", "octopus", "clam",
            "mussel", "oyster", "prawn",
            "pollo", "petto di pollo", "coscia di pollo", "ali di pollo", "manzo", "vitello", "maiale",
            "agnello", "tacchino", "anatra", "coniglio", "quaglia", "salmone", "tonno", "merluzzo",
            "branzino", "orata", "pesce", "pesce spada", "gambero", "gamberi", "gamberetti", "calamaro",
            "calamari", "polpo", "cozze", "vongole", "aragosta", "granchio", "sardina", "sardine",
            "acciuga", "acciughe", "alice", "alici", "trota", "sgombro", "aringa", "sogliola",
            "cernia", "seppia", "seppie", "capesante", "prosciutto", "salame", "pancetta",
            "bresaola", "mortadella", "speck", "guanciale", "salsiccia", "salsicce", "wurstel",
            "cotechino", "coppa", "lardo", "bistecca", "filetto", "costata", "arrosto", "lonza",
            "carpaccio", "tartare", "hamburger", "polpette", "carne", "carne macinata", "fesa",
            "petto di tacchino", "coscia", "sovracoscia", "fettine"
        ]

        let fruitVeg: [String] = [
            "apple", "banana", "tomato", "avocado", "spinach", "lettuce", "cucumber", "carrot",
            "broccoli", "pepper", "onion", "garlic", "cherry", "lime", "lemon", "orange", "berry",
            "kale", "arugula", "zucchini", "mushroom", "celery", "asparagus", "beet", "cauliflower",
            "potato", "sweet potato", "pea", "corn", "mango", "pineapple", "grape", "watermelon",
            "melon", "peach", "plum", "pear", "fig", "kiwi", "papaya", "coconut", "grapefruit",
            "raspberry", "blueberry", "strawberry", "blackberry", "cranberry", "radish", "turnip",
            "cabbage", "eggplant", "artichoke", "fennel", "leek", "ginger", "jalapeno", "chili",
            "squash", "pumpkin", "parsnip", "endive", "radicchio", "chard", "collard",
            "mela", "mele", "banana", "banane", "pomodoro", "pomodori", "pomodorino", "pomodorini",
            "pomodori secchi", "avocado", "spinaci", "spinacino", "lattuga", "cetriolo", "cetrioli",
            "carota", "carote", "broccolo", "broccoli", "peperone", "peperoni", "cipolla", "cipolle",
            "cipollotto", "cipollotti", "aglio", "ciliegia", "ciliegie", "lime", "limone", "limoni",
            "arancia", "arance", "frutti di bosco", "cavolo", "cavolo nero", "rucola", "zucchina",
            "zucchine", "fungo", "funghi", "funghi porcini", "champignon", "sedano", "asparago",
            "asparagi", "barbabietola", "barbabietole", "cavolfiore", "patata", "patate",
            "patata dolce", "patate dolci", "piselli", "mais", "mango", "ananas", "uva",
            "anguria", "melone", "pesca", "pesche", "prugna", "prugne", "pera", "pere", "fico",
            "fichi", "kiwi", "papaya", "cocco", "pompelmo", "lampone", "lamponi", "mirtillo",
            "mirtilli", "fragola", "fragole", "mora", "more", "ravanello", "ravanelli", "rapa",
            "rape", "cavolo cappuccio", "melanzana", "melanzane", "carciofo", "carciofi",
            "finocchio", "finocchi", "porro", "porri", "zenzero", "peperoncino", "peperoncini",
            "zucca", "pastinaca", "indivia", "radicchio", "bietola", "bietole", "scarola",
            "verza", "cavolini di bruxelles", "olive", "olive verdi", "olive nere", "insalata",
            "insalata mista", "misticanza", "valeriana", "songino", "erbe miste", "erbe miste fresche",
            "prezzemolo", "basilico", "rosmarino", "salvia", "timo", "origano", "menta",
            "erba cipollina", "coriandolo", "aneto", "aneto fresco", "alloro", "maggiorana",
            "dragoncello", "capperi", "friarielli", "cime di rapa", "cicoria", "catalogna",
            "peperonata", "verdure", "verdura", "frutta", "agrumi"
        ]

        let dairy: [String] = [
            "milk", "cheese", "yogurt", "egg", "butter", "cream", "whey", "feta", "mozzarella",
            "parmesan", "ricotta", "cheddar", "gouda", "brie", "camembert", "mascarpone",
            "cottage cheese", "sour cream", "ghee", "kefir",
            "latte", "formaggio", "formaggio stagionato", "formaggio fresco", "formaggio grattugiato",
            "yogurt", "uovo", "uova", "burro", "panna", "panna fresca", "panna da cucina",
            "panna montata", "siero di latte", "feta", "mozzarella", "parmigiano", "parmigiano reggiano",
            "grana padano", "grana", "pecorino", "pecorino romano", "ricotta", "mascarpone",
            "stracchino", "crescenza", "gorgonzola", "taleggio", "fontina", "asiago", "provolone",
            "scamorza", "burrata", "caciotta", "caciocavallo", "emmental", "gruyere", "brie",
            "camembert", "fiocchi di latte", "philadelphia", "formaggio spalmabile", "robiola",
            "primo sale", "squacquerone", "latte intero", "latte scremato", "latte parzialmente scremato",
            "latte di vacca", "latticini", "yogurt greco", "yogurt magro", "skyr", "kefir",
            "albume", "albumi", "tuorlo", "tuorli"
        ]

        let grains: [String] = [
            "bread", "pasta", "rice", "quinoa", "oat", "flour", "wheat", "cereal", "grain",
            "barley", "noodle", "cracker", "tortilla", "couscous", "bulgur", "polenta", "cornmeal",
            "rye", "spelt", "millet", "amaranth", "buckwheat", "farro",
            "pane", "pane integrale", "pane di segale", "pancarrè", "panino", "panini",
            "pasta", "pasta integrale", "spaghetti", "penne", "fusilli", "rigatoni", "farfalle",
            "linguine", "tagliatelle", "fettuccine", "lasagna", "lasagne", "gnocchi", "ravioli",
            "tortellini", "orecchiette", "paccheri", "bucatini", "maccheroni", "conchiglie",
            "mezze maniche", "pappardelle", "caserecce", "trofie", "riso", "riso basmati",
            "riso integrale", "riso arborio", "riso carnaroli", "riso venere", "riso jasmine",
            "quinoa", "avena", "fiocchi d'avena", "farina", "farina integrale", "farina 00",
            "farina di riso", "farina di mandorle", "farina di cocco", "grano", "orzo",
            "couscous", "bulgur", "polenta", "farina di mais", "segale", "farro", "miglio",
            "amaranto", "grano saraceno", "crackers", "grissini", "fette biscottate",
            "corn flakes", "cereali", "muesli", "granola", "gallette", "gallette di riso",
            "piadina", "focaccia", "bruschetta", "crostini", "pangrattato", "amido", "amido di mais",
            "maizena", "semola", "semolino", "pasta sfoglia", "pasta brisée", "pasta frolla"
        ]

        let legumesNuts: [String] = [
            "bean", "lentil", "almond", "walnut", "peanut", "cashew", "nut", "chickpea", "seed",
            "hemp", "flaxseed", "sunflower", "pumpkin seed", "pistachio", "pecan", "hazelnut",
            "macadamia", "brazil nut", "pine nut", "sesame", "chia", "tofu", "tempeh", "edamame",
            "fagiolo", "fagioli", "fagioli neri", "fagioli borlotti", "fagioli cannellini",
            "lenticchia", "lenticchie", "mandorla", "mandorle", "noce", "noci", "arachide",
            "arachidi", "anacardo", "anacardi", "cece", "ceci", "semi", "semi di lino",
            "semi di girasole", "semi di zucca", "semi di sesamo", "semi di chia", "semi di canapa",
            "pistacchio", "pistacchi", "nocciola", "nocciole", "noce di macadamia", "noce del brasile",
            "pinolo", "pinoli", "sesamo", "chia", "tofu", "tempeh", "edamame", "soia",
            "latte di soia", "fave", "lupini", "burro di arachidi", "burro di mandorle",
            "crema di nocciole", "tahini", "hummus"
        ]

        let oilsFats: [String] = [
            "oil", "olive oil", "coconut oil", "vegetable oil", "sunflower oil", "canola oil",
            "sesame oil", "avocado oil", "truffle oil", "peanut oil", "lard", "margarine",
            "olio", "olio d'oliva", "olio di oliva", "olio extravergine", "olio evo",
            "olio di cocco", "olio di semi", "olio di girasole", "olio di sesamo", "olio di lino",
            "olio di avocado", "olio di arachidi", "olio al tartufo", "margarina", "strutto",
            "olio vegetale"
        ]

        let beverages: [String] = [
            "water", "juice", "tea", "coffee", "smoothie", "wine", "beer", "soda", "milk",
            "acqua", "succo", "succo di frutta", "succo d'arancia", "tè", "caffè", "tisana",
            "vino", "birra", "bibita", "bevanda", "spremuta", "centrifuga", "estratto",
            "latte di mandorla", "latte di cocco", "latte di avena", "latte di riso",
            "latte vegetale", "cioccolata calda", "cappuccino", "espresso"
        ]

        let condimentsSpices: [String] = [
            "salt", "pepper", "sugar", "honey", "vinegar", "mustard", "ketchup", "mayo",
            "mayonnaise", "soy sauce", "hot sauce", "sriracha", "curry", "cumin", "paprika",
            "cinnamon", "nutmeg", "turmeric", "oregano", "basil", "thyme", "rosemary", "parsley",
            "dill", "vanilla", "baking powder", "baking soda", "yeast", "cocoa", "chocolate",
            "maple syrup", "jam",
            "sale", "pepe", "pepe nero", "zucchero", "zucchero di canna", "miele",
            "aceto", "aceto balsamico", "aceto di mele", "aceto di vino", "senape", "ketchup",
            "maionese", "salsa di soia", "salsa", "curry", "cumino", "paprika", "paprica",
            "cannella", "noce moscata", "curcuma", "vaniglia", "lievito", "lievito di birra",
            "lievito per dolci", "bicarbonato", "cacao", "cioccolato", "cioccolato fondente",
            "cioccolato al latte", "sciroppo d'acero", "marmellata", "confettura",
            "zucchero a velo", "eritritolo", "stevia", "dolcificante",
            "salsa worcestershire", "tabasco", "pesto", "sugo", "passata di pomodoro",
            "concentrato di pomodoro", "pelati", "polpa di pomodoro", "dado", "brodo",
            "brodo vegetale", "brodo di pollo", "estratto di vaniglia", "aroma",
            "spezie", "mix di spezie", "erbe aromatiche", "chiodi di garofano", "anice",
            "finocchietto", "zafferano", "pepe rosa", "pepe bianco", "peperoncino in polvere",
            "aglio in polvere", "cipolla in polvere"
        ]

        let sortedOils = oilsFats.sorted { $0.count > $1.count }
        let sortedBev = beverages.sorted { $0.count > $1.count }
        let sortedMeat = meatFish.sorted { $0.count > $1.count }
        let sortedDairy = dairy.sorted { $0.count > $1.count }
        let sortedFV = fruitVeg.sorted { $0.count > $1.count }
        let sortedGrains = grains.sorted { $0.count > $1.count }
        let sortedLN = legumesNuts.sorted { $0.count > $1.count }
        let sortedCS = condimentsSpices.sorted { $0.count > $1.count }

        for kw in sortedOils { if n.contains(kw) { return "Oils and Fats" } }
        for kw in sortedBev { if n.contains(kw) { return "Beverages" } }
        for kw in sortedMeat { if n.contains(kw) { return "Meat and Fish" } }
        for kw in sortedDairy { if n.contains(kw) { return "Dairy and Eggs" } }
        for kw in sortedFV { if n.contains(kw) { return "Fruits and Vegetables" } }
        for kw in sortedGrains { if n.contains(kw) { return "Grains and Pasta" } }
        for kw in sortedLN { if n.contains(kw) { return "Legumes and Nuts" } }
        for kw in sortedCS { if n.contains(kw) { return "Condiments and Spices" } }
        return "Other"
    }

    static func categoryEmoji(_ category: String) -> String {
        switch category {
        case "Meat and Fish": return "🥩"
        case "Fruits and Vegetables": return "🥬"
        case "Dairy and Eggs": return "🥛"
        case "Grains and Pasta": return "🌾"
        case "Legumes and Nuts": return "🥜"
        case "Oils and Fats": return "🫒"
        case "Beverages": return "🥤"
        case "Condiments and Spices": return "🧂"
        case "Other": return "🛒"
        default: return "🛒"
        }
    }

    static func categoryColor(_ category: String) -> (bg: Double, tint: Double) {
        switch category {
        case "Meat and Fish": return (bg: 0.0, tint: 0.0)
        case "Fruits and Vegetables": return (bg: 0.0, tint: 0.0)
        case "Dairy and Eggs": return (bg: 0.0, tint: 0.0)
        case "Grains and Pasta": return (bg: 0.0, tint: 0.0)
        case "Legumes and Nuts": return (bg: 0.0, tint: 0.0)
        case "Oils and Fats": return (bg: 0.0, tint: 0.0)
        case "Beverages": return (bg: 0.0, tint: 0.0)
        case "Condiments and Spices": return (bg: 0.0, tint: 0.0)
        default: return (bg: 0.0, tint: 0.0)
        }
    }

    static let allCategories = [
        "Meat and Fish",
        "Fruits and Vegetables",
        "Dairy and Eggs",
        "Grains and Pasta",
        "Legumes and Nuts",
        "Oils and Fats",
        "Beverages",
        "Condiments and Spices",
        "Other"
    ]
}
