import Foundation

extension MealDatabase {
    static let cheatLunchMeals: [CatalogMeal] = [
        CatalogMeal(meal: Meal(type: .lunch, name: "Burger classico con bacon e cheddar", calories: 750, protein: 42, carbs: 48, fat: 44, prepTime: 25, difficulty: .medium,
            ingredients: [Ingredient(name: "Pane brioche", amount: 1, unit: "pezzo", calories: 180), Ingredient(name: "Manzo macinato", amount: 180, unit: "g", calories: 280), Ingredient(name: "Bacon", amount: 40, unit: "g", calories: 120), Ingredient(name: "Cheddar", amount: 40, unit: "g", calories: 110), Ingredient(name: "Lattuga", amount: 20, unit: "g", calories: 4), Ingredient(name: "Pomodoro", amount: 40, unit: "g", calories: 8), Ingredient(name: "Salsa burger", amount: 20, unit: "g", calories: 48)],
            imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&fit=crop",
            preparationSteps: ["Formare il patty con il manzo macinato e condire con sale e pepe", "Grigliare il burger 4-5 minuti per lato", "Aggiungere il cheddar nell'ultimo minuto di cottura", "Tostare il pane brioche sulla griglia", "Assemblare con bacon croccante, lattuga, pomodoro e salsa"]), dietTags: [.balanced, .mediterranean, .softLowCarb, .paleo]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Pizza Margherita fatta in casa", calories: 720, protein: 28, carbs: 88, fat: 28, prepTime: 30, difficulty: .medium,
            ingredients: [Ingredient(name: "Impasto pizza", amount: 200, unit: "g", calories: 400), Ingredient(name: "Salsa di pomodoro", amount: 80, unit: "g", calories: 32), Ingredient(name: "Mozzarella di bufala", amount: 125, unit: "g", calories: 250), Ingredient(name: "Basilico fresco", amount: 5, unit: "g", calories: 2), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&fit=crop",
            preparationSteps: ["Stendere l'impasto su una teglia infarinata", "Distribuire la salsa di pomodoro uniformemente", "Aggiungere la mozzarella a pezzi", "Infornare a 250°C per 12-15 minuti", "Completare con basilico fresco e un filo d'olio"]), dietTags: [.balanced, .mediterranean, .vegetarian]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Mac & Cheese cremoso al forno", calories: 680, protein: 26, carbs: 62, fat: 38, prepTime: 30, difficulty: .medium,
            ingredients: [Ingredient(name: "Maccheroni", amount: 100, unit: "g", calories: 280), Ingredient(name: "Cheddar", amount: 60, unit: "g", calories: 180), Ingredient(name: "Panna", amount: 60, unit: "ml", calories: 120), Ingredient(name: "Burro", amount: 15, unit: "g", calories: 110), Ingredient(name: "Pangrattato", amount: 15, unit: "g", calories: 50)],
            imageURL: "https://images.unsplash.com/photo-1543339494-b4cd4f7ba686?w=400&fit=crop",
            preparationSteps: ["Cuocere i maccheroni al dente", "Preparare la salsa con burro, panna e cheddar", "Mescolare la pasta con la salsa", "Trasferire in una teglia e cospargere di pangrattato", "Gratinare in forno a 200°C per 10 minuti"]), dietTags: [.balanced, .vegetarian]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Tacos di pollo con guacamole", calories: 650, protein: 36, carbs: 52, fat: 34, prepTime: 20, difficulty: .easy,
            ingredients: [Ingredient(name: "Tortilla di mais", amount: 3, unit: "pezzi", calories: 180), Ingredient(name: "Pollo grigliato", amount: 150, unit: "g", calories: 180), Ingredient(name: "Avocado", amount: 80, unit: "g", calories: 128), Ingredient(name: "Panna acida", amount: 30, unit: "g", calories: 60), Ingredient(name: "Lime", amount: 15, unit: "ml", calories: 4), Ingredient(name: "Cipolla rossa", amount: 30, unit: "g", calories: 12), Ingredient(name: "Coriandolo", amount: 5, unit: "g", calories: 2)],
            imageURL: "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400&fit=crop",
            preparationSteps: ["Grigliare e sfilacciare il pollo", "Preparare il guacamole con avocado, lime e cipolla", "Scaldare le tortilla in padella", "Farcire con pollo, guacamole e panna acida", "Completare con coriandolo fresco"]), dietTags: [.balanced, .mediterranean, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Carbonara classica romana", calories: 700, protein: 30, carbs: 68, fat: 36, prepTime: 20, difficulty: .medium,
            ingredients: [Ingredient(name: "Spaghetti", amount: 100, unit: "g", calories: 280), Ingredient(name: "Guanciale", amount: 50, unit: "g", calories: 180), Ingredient(name: "Tuorli d'uovo", amount: 3, unit: "grandi", calories: 150), Ingredient(name: "Pecorino Romano", amount: 30, unit: "g", calories: 110), Ingredient(name: "Pepe nero", amount: 2, unit: "g", calories: 5)],
            imageURL: "https://images.unsplash.com/photo-1612874742237-6526221588e3?w=400&fit=crop",
            preparationSteps: ["Cuocere gli spaghetti in acqua salata", "Rosolare il guanciale a cubetti fino a renderlo croccante", "Mescolare tuorli, pecorino e pepe in una ciotola", "Scolare la pasta e versare nella padella con il guanciale", "Aggiungere la crema di uova e pecorino mescolando velocemente"]), dietTags: [.balanced, .mediterranean]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Poke bowl con salmone e mango", calories: 620, protein: 32, carbs: 68, fat: 24, prepTime: 15, difficulty: .easy,
            ingredients: [Ingredient(name: "Riso per sushi", amount: 100, unit: "g", calories: 280), Ingredient(name: "Salmone fresco", amount: 120, unit: "g", calories: 180), Ingredient(name: "Mango", amount: 60, unit: "g", calories: 36), Ingredient(name: "Avocado", amount: 40, unit: "g", calories: 64), Ingredient(name: "Edamame", amount: 30, unit: "g", calories: 36), Ingredient(name: "Salsa di soia", amount: 15, unit: "ml", calories: 10)],
            imageURL: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&fit=crop",
            preparationSteps: ["Cuocere e condire il riso per sushi", "Tagliare il salmone a cubetti e marinare con salsa di soia", "Tagliare avocado e mango a fette", "Comporre la bowl con riso, salmone, mango, avocado e edamame", "Condire con salsa di soia e semi di sesamo"]), dietTags: [.balanced, .mediterranean]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Smash burger doppio con patatine", calories: 820, protein: 44, carbs: 56, fat: 48, prepTime: 20, difficulty: .easy,
            ingredients: [Ingredient(name: "Pane brioche", amount: 1, unit: "pezzo", calories: 180), Ingredient(name: "Manzo macinato", amount: 200, unit: "g", calories: 310), Ingredient(name: "Formaggio americano", amount: 40, unit: "g", calories: 120), Ingredient(name: "Cipolla caramellata", amount: 40, unit: "g", calories: 40), Ingredient(name: "Patatine fritte", amount: 80, unit: "g", calories: 220), Ingredient(name: "Ketchup", amount: 15, unit: "g", calories: 20)],
            imageURL: "https://images.unsplash.com/photo-1586816001966-79b736744398?w=400&fit=crop",
            preparationSteps: ["Dividere il manzo in 2 palline e schiacciare sulla piastra bollente", "Cuocere 2 minuti per lato ad alta temperatura", "Aggiungere il formaggio e coprire per fonderlo", "Tostare il pane e aggiungere la cipolla caramellata", "Assemblare e servire con patatine"]), dietTags: [.balanced, .paleo, .carnivore]),
    ]

    static let cheatDinnerMeals: [CatalogMeal] = [
        CatalogMeal(meal: Meal(type: .dinner, name: "Lasagna alla bolognese", calories: 720, protein: 36, carbs: 58, fat: 38, prepTime: 45, difficulty: .hard,
            ingredients: [Ingredient(name: "Sfoglie di lasagna", amount: 120, unit: "g", calories: 240), Ingredient(name: "Ragù alla bolognese", amount: 180, unit: "g", calories: 220), Ingredient(name: "Besciamella", amount: 80, unit: "g", calories: 100), Ingredient(name: "Parmigiano", amount: 40, unit: "g", calories: 160)],
            imageURL: "https://images.unsplash.com/photo-1560684352-8497838b6e3a?w=400&fit=crop",
            preparationSteps: ["Preparare il ragù alla bolognese con carne macinata e pomodoro", "Preparare la besciamella", "Alternare strati di sfoglia, ragù, besciamella e parmigiano", "Terminare con besciamella e parmigiano", "Cuocere in forno a 180°C per 30 minuti"]), dietTags: [.balanced, .mediterranean]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Costolette BBQ con coleslaw", calories: 780, protein: 48, carbs: 32, fat: 52, prepTime: 40, difficulty: .medium,
            ingredients: [Ingredient(name: "Costolette di maiale", amount: 250, unit: "g", calories: 450), Ingredient(name: "Salsa BBQ", amount: 40, unit: "g", calories: 80), Ingredient(name: "Cavolo cappuccio", amount: 80, unit: "g", calories: 20), Ingredient(name: "Carota", amount: 40, unit: "g", calories: 16), Ingredient(name: "Maionese", amount: 30, unit: "g", calories: 210)],
            imageURL: "https://images.unsplash.com/photo-1544025162-d76694265947?w=400&fit=crop",
            preparationSteps: ["Marinare le costolette con salsa BBQ per almeno 30 minuti", "Cuocere in forno a 160°C per 25 minuti", "Spennellare con altra salsa BBQ e gratinare 5 minuti", "Preparare il coleslaw con cavolo, carota e maionese", "Servire le costolette con il coleslaw"]), dietTags: [.balanced, .paleo, .carnivore, .lowCarb]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Ramen giapponese con uovo", calories: 680, protein: 32, carbs: 72, fat: 28, prepTime: 35, difficulty: .medium,
            ingredients: [Ingredient(name: "Noodles ramen", amount: 120, unit: "g", calories: 280), Ingredient(name: "Brodo tonkotsu", amount: 300, unit: "ml", calories: 120), Ingredient(name: "Uovo marinato", amount: 1, unit: "grande", calories: 70), Ingredient(name: "Chashu (maiale)", amount: 60, unit: "g", calories: 140), Ingredient(name: "Cipollotto", amount: 20, unit: "g", calories: 6), Ingredient(name: "Mais dolce", amount: 30, unit: "g", calories: 30), Ingredient(name: "Nori", amount: 2, unit: "fogli", calories: 10)],
            imageURL: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&fit=crop",
            preparationSteps: ["Scaldare il brodo tonkotsu", "Cuocere i noodles seguendo le istruzioni", "Preparare l'uovo marinato in salsa di soia", "Versare il brodo caldo sui noodles scolati", "Guarnire con chashu, uovo, mais, cipollotto e nori"]), dietTags: [.balanced]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Parmigiana di melanzane", calories: 640, protein: 28, carbs: 38, fat: 42, prepTime: 45, difficulty: .hard,
            ingredients: [Ingredient(name: "Melanzane", amount: 250, unit: "g", calories: 62), Ingredient(name: "Salsa di pomodoro", amount: 120, unit: "g", calories: 48), Ingredient(name: "Mozzarella", amount: 100, unit: "g", calories: 220), Ingredient(name: "Parmigiano", amount: 30, unit: "g", calories: 120), Ingredient(name: "Olio d'oliva", amount: 20, unit: "ml", calories: 180), Ingredient(name: "Basilico", amount: 5, unit: "g", calories: 2)],
            imageURL: "https://images.unsplash.com/photo-1625944525533-473f1a3d54e7?w=400&fit=crop",
            preparationSteps: ["Tagliare le melanzane a fette e grigliarle", "Preparare la salsa di pomodoro con basilico", "Alternare strati di melanzane, salsa, mozzarella e parmigiano", "Terminare con mozzarella e parmigiano", "Cuocere in forno a 180°C per 25 minuti"]), dietTags: [.balanced, .mediterranean, .vegetarian]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Steak con burro alle erbe e patate", calories: 800, protein: 52, carbs: 36, fat: 50, prepTime: 25, difficulty: .medium,
            ingredients: [Ingredient(name: "Bistecca di manzo", amount: 220, unit: "g", calories: 380), Ingredient(name: "Burro", amount: 20, unit: "g", calories: 150), Ingredient(name: "Erbe aromatiche", amount: 10, unit: "g", calories: 5), Ingredient(name: "Patate", amount: 150, unit: "g", calories: 115), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Aglio", amount: 5, unit: "g", calories: 8)],
            imageURL: "https://images.unsplash.com/photo-1558030006-450675393462?w=400&fit=crop",
            preparationSteps: ["Portare la bistecca a temperatura ambiente", "Cuocere le patate a spicchi in forno a 200°C per 20 minuti", "Grigliare la bistecca 4 minuti per lato per una cottura media", "Preparare il burro alle erbe mescolando burro morbido ed erbe", "Servire la bistecca con il burro che si scioglie sopra e le patate"]), dietTags: [.balanced, .paleo, .carnivore, .lowCarb, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Sushi misto fatto in casa", calories: 620, protein: 28, carbs: 78, fat: 20, prepTime: 40, difficulty: .hard,
            ingredients: [Ingredient(name: "Riso per sushi", amount: 150, unit: "g", calories: 340), Ingredient(name: "Salmone fresco", amount: 80, unit: "g", calories: 120), Ingredient(name: "Tonno fresco", amount: 60, unit: "g", calories: 60), Ingredient(name: "Avocado", amount: 40, unit: "g", calories: 64), Ingredient(name: "Nori", amount: 4, unit: "fogli", calories: 20), Ingredient(name: "Salsa di soia", amount: 15, unit: "ml", calories: 10)],
            imageURL: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400&fit=crop",
            preparationSteps: ["Cuocere e condire il riso per sushi con aceto di riso", "Tagliare il pesce a fettine sottili", "Stendere il riso sulle foglie di nori", "Farcire con pesce e avocado, arrotolare strettamente", "Tagliare i rotoli e servire con salsa di soia e wasabi"]), dietTags: [.balanced, .mediterranean]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Nachos supreme con carne e formaggio", calories: 740, protein: 34, carbs: 58, fat: 44, prepTime: 20, difficulty: .easy,
            ingredients: [Ingredient(name: "Tortilla chips", amount: 100, unit: "g", calories: 280), Ingredient(name: "Carne macinata", amount: 120, unit: "g", calories: 200), Ingredient(name: "Cheddar fuso", amount: 50, unit: "g", calories: 150), Ingredient(name: "Jalapeños", amount: 20, unit: "g", calories: 6), Ingredient(name: "Panna acida", amount: 30, unit: "g", calories: 60), Ingredient(name: "Guacamole", amount: 40, unit: "g", calories: 50)],
            imageURL: "https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?w=400&fit=crop",
            preparationSteps: ["Cuocere la carne macinata con spezie messicane", "Disporre le tortilla chips su una teglia", "Distribuire la carne e il cheddar sopra", "Gratinare in forno a 200°C per 5 minuti", "Completare con panna acida, guacamole e jalapeños"]), dietTags: [.balanced]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Fish & Chips croccante", calories: 710, protein: 34, carbs: 64, fat: 36, prepTime: 30, difficulty: .medium,
            ingredients: [Ingredient(name: "Merluzzo", amount: 200, unit: "g", calories: 160), Ingredient(name: "Farina", amount: 40, unit: "g", calories: 140), Ingredient(name: "Birra", amount: 80, unit: "ml", calories: 30), Ingredient(name: "Patate", amount: 200, unit: "g", calories: 150), Ingredient(name: "Olio per friggere", amount: 30, unit: "ml", calories: 260), Ingredient(name: "Limone", amount: 15, unit: "ml", calories: 4)],
            imageURL: "https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=400&fit=crop",
            preparationSteps: ["Tagliare le patate a bastoncino e friggere fino a doratura", "Preparare la pastella con farina, birra e un pizzico di sale", "Infarinare il merluzzo e immergerlo nella pastella", "Friggere il pesce in olio caldo fino a doratura", "Servire con patate fritte e limone"]), dietTags: [.balanced]),
    ]
}
