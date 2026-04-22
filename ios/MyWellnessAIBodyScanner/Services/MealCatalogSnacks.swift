import Foundation

extension MealDatabase {
    static let snackMeals: [CatalogMeal] = [
        CatalogMeal(meal: Meal(type: .snack, name: "Yogurt greco con miele", calories: 180, protein: 12, carbs: 22, fat: 5, prepTime: 2, difficulty: .easy,
            ingredients: [Ingredient(name: "Yogurt greco", amount: 150, unit: "g", calories: 98), Ingredient(name: "Miele", amount: 15, unit: "g", calories: 45), Ingredient(name: "Cannella", amount: 2, unit: "g", calories: 5)],
            imageURL: "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&fit=crop",
            preparationSteps: ["Versare lo yogurt in una ciotola", "Aggiungere il miele e la cannella", "Mescolare e servire"]), dietTags: [.mediterranean, .balanced, .vegetarian, .softLowCarb], snackSlot: .morning),

        CatalogMeal(meal: Meal(type: .snack, name: "Frullato di banana e mandorle", calories: 220, protein: 8, carbs: 32, fat: 8, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Banana", amount: 1, unit: "media", calories: 95), Ingredient(name: "Latte di mandorla", amount: 200, unit: "ml", calories: 30), Ingredient(name: "Burro di mandorle", amount: 10, unit: "g", calories: 60), Ingredient(name: "Miele", amount: 5, unit: "g", calories: 15)],
            imageURL: "https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400&fit=crop",
            preparationSteps: ["Mettere tutti gli ingredienti nel frullatore", "Frullare per 30 secondi", "Versare e servire subito"]), dietTags: [.balanced, .vegetarian, .vegan, .paleo], snackSlot: .morning),

        CatalogMeal(meal: Meal(type: .snack, name: "Toast con marmellata", calories: 200, protein: 6, carbs: 36, fat: 4, prepTime: 3, difficulty: .easy,
            ingredients: [Ingredient(name: "Pane integrale", amount: 1, unit: "fetta", calories: 70), Ingredient(name: "Marmellata di frutti di bosco", amount: 25, unit: "g", calories: 50), Ingredient(name: "Ricotta", amount: 30, unit: "g", calories: 42)],
            imageURL: "https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400&fit=crop",
            preparationSteps: ["Tostare la fetta di pane", "Spalmare la ricotta e poi la marmellata", "Servire subito"]), dietTags: [.balanced, .vegetarian, .mediterranean], snackSlot: .morning),

        CatalogMeal(meal: Meal(type: .snack, name: "Frutta fresca mista", calories: 150, protein: 2, carbs: 36, fat: 1, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Mela", amount: 1, unit: "media", calories: 52), Ingredient(name: "Kiwi", amount: 1, unit: "grande", calories: 42), Ingredient(name: "Fragole", amount: 80, unit: "g", calories: 26), Ingredient(name: "Mirtilli", amount: 40, unit: "g", calories: 20)],
            imageURL: "https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=400&fit=crop",
            preparationSteps: ["Lavare tutta la frutta", "Tagliare mela e kiwi a pezzi", "Mescolare in una ciotola e servire"]), dietTags: [.balanced, .vegan, .vegetarian, .paleo, .mediterranean], snackSlot: .morning),

        CatalogMeal(meal: Meal(type: .snack, name: "Uovo sodo con sale rosa", calories: 155, protein: 13, carbs: 1, fat: 11, prepTime: 12, difficulty: .easy,
            ingredients: [Ingredient(name: "Uova", amount: 2, unit: "medie", calories: 140), Ingredient(name: "Sale rosa", amount: 1, unit: "pizzico", calories: 0)],
            imageURL: "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&fit=crop",
            preparationSteps: ["Portare l'acqua a ebollizione", "Cuocere le uova per 10 minuti", "Raffreddare in acqua fredda, sgusciare e condire"]), dietTags: [.lowCarb, .ketogenic, .paleo, .carnivore, .balanced], snackSlot: .morning),

        CatalogMeal(meal: Meal(type: .snack, name: "Smoothie verde mattutino", calories: 180, protein: 6, carbs: 30, fat: 5, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Spinaci", amount: 40, unit: "g", calories: 9), Ingredient(name: "Banana", amount: 0.5, unit: "media", calories: 48), Ingredient(name: "Mela verde", amount: 0.5, unit: "media", calories: 26), Ingredient(name: "Latte di mandorla", amount: 150, unit: "ml", calories: 23), Ingredient(name: "Semi di chia", amount: 5, unit: "g", calories: 25)],
            imageURL: "https://images.unsplash.com/photo-1638176066666-ffb2f013c7dd?w=400&fit=crop",
            preparationSteps: ["Mettere spinaci, banana, mela e latte nel frullatore", "Frullare fino a consistenza liscia", "Aggiungere semi di chia e mescolare"]), dietTags: [.vegan, .vegetarian, .balanced, .paleo], snackSlot: .morning),

        CatalogMeal(meal: Meal(type: .snack, name: "Pancetta croccante", calories: 180, protein: 14, carbs: 0, fat: 14, prepTime: 8, difficulty: .easy,
            ingredients: [Ingredient(name: "Pancetta", amount: 60, unit: "g", calories: 180)],
            imageURL: "https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=400&fit=crop",
            preparationSteps: ["Cuocere la pancetta in padella fino a doratura", "Scolare su carta assorbente", "Servire croccante"]), dietTags: [.carnivore, .ketogenic, .lowCarb], snackSlot: .morning),

        CatalogMeal(meal: Meal(type: .snack, name: "Hummus con bastoncini di verdure", calories: 200, protein: 8, carbs: 22, fat: 10, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Hummus", amount: 60, unit: "g", calories: 120), Ingredient(name: "Carote", amount: 60, unit: "g", calories: 25), Ingredient(name: "Sedano", amount: 60, unit: "g", calories: 10), Ingredient(name: "Cetriolo", amount: 60, unit: "g", calories: 10)],
            imageURL: "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&fit=crop",
            preparationSteps: ["Tagliare le verdure a bastoncini", "Versare l'hummus in una ciotolina", "Disporre le verdure intorno e intingere"]), dietTags: [.vegan, .vegetarian, .mediterranean, .balanced, .softLowCarb], snackSlot: .afternoon),

        CatalogMeal(meal: Meal(type: .snack, name: "Mix di frutta secca ed essiccata", calories: 220, protein: 6, carbs: 18, fat: 16, prepTime: 1, difficulty: .easy,
            ingredients: [Ingredient(name: "Mandorle", amount: 15, unit: "g", calories: 87), Ingredient(name: "Noci", amount: 10, unit: "g", calories: 65), Ingredient(name: "Uvetta", amount: 15, unit: "g", calories: 45), Ingredient(name: "Mirtilli essiccati", amount: 10, unit: "g", calories: 30)],
            imageURL: "https://images.unsplash.com/photo-1559847844-5315695dadae?w=400&fit=crop",
            preparationSteps: ["Mescolare tutti gli ingredienti in una ciotolina", "Porzionare e servire"]), dietTags: [.vegan, .vegetarian, .paleo, .balanced, .mediterranean], snackSlot: .afternoon),

        CatalogMeal(meal: Meal(type: .snack, name: "Edamame salati", calories: 190, protein: 17, carbs: 14, fat: 8, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Edamame surgelati", amount: 150, unit: "g", calories: 165), Ingredient(name: "Sale marino", amount: 2, unit: "g", calories: 0), Ingredient(name: "Peperoncino in fiocchi", amount: 1, unit: "pizzico", calories: 2)],
            imageURL: "https://images.unsplash.com/photo-1564834724105-918b73d1b8e0?w=400&fit=crop",
            preparationSteps: ["Bollire gli edamame per 3-4 minuti", "Scolare e condire con sale e peperoncino", "Servire caldi o tiepidi"]), dietTags: [.vegan, .vegetarian, .balanced, .softLowCarb], snackSlot: .afternoon),

        CatalogMeal(meal: Meal(type: .snack, name: "Formaggio con olive", calories: 200, protein: 12, carbs: 2, fat: 16, prepTime: 2, difficulty: .easy,
            ingredients: [Ingredient(name: "Formaggio stagionato", amount: 30, unit: "g", calories: 120), Ingredient(name: "Olive verdi", amount: 30, unit: "g", calories: 40), Ingredient(name: "Pomodorini secchi", amount: 10, unit: "g", calories: 25)],
            imageURL: "https://images.unsplash.com/photo-1452195100486-9cc805987862?w=400&fit=crop",
            preparationSteps: ["Tagliare il formaggio a cubetti", "Disporre con olive e pomodorini secchi", "Servire come antipasto"]), dietTags: [.ketogenic, .lowCarb, .softLowCarb, .mediterranean, .vegetarian], snackSlot: .afternoon),

        CatalogMeal(meal: Meal(type: .snack, name: "Mela con burro di arachidi", calories: 230, protein: 6, carbs: 28, fat: 12, prepTime: 3, difficulty: .easy,
            ingredients: [Ingredient(name: "Mela", amount: 1, unit: "media", calories: 72), Ingredient(name: "Burro di arachidi", amount: 20, unit: "g", calories: 118), Ingredient(name: "Cannella", amount: 1, unit: "pizzico", calories: 2)],
            imageURL: "https://images.unsplash.com/photo-1568702846914-96b305d2ead1?w=400&fit=crop",
            preparationSteps: ["Tagliare la mela a fette", "Servire con burro di arachidi per intingere", "Spolverare con cannella"]), dietTags: [.balanced, .vegetarian, .vegan], snackSlot: .afternoon),

        CatalogMeal(meal: Meal(type: .snack, name: "Avocado con limone e pepe", calories: 190, protein: 2, carbs: 10, fat: 16, prepTime: 3, difficulty: .easy,
            ingredients: [Ingredient(name: "Avocado", amount: 0.5, unit: "grande", calories: 160), Ingredient(name: "Limone", amount: 10, unit: "ml", calories: 4), Ingredient(name: "Pepe nero", amount: 1, unit: "pizzico", calories: 1), Ingredient(name: "Sale marino", amount: 1, unit: "pizzico", calories: 0)],
            imageURL: "https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=400&fit=crop",
            preparationSteps: ["Tagliare l'avocado a metà", "Condire con limone, sale e pepe", "Mangiare direttamente dal guscio"]), dietTags: [.ketogenic, .lowCarb, .paleo, .vegan, .vegetarian], snackSlot: .afternoon),

        CatalogMeal(meal: Meal(type: .snack, name: "Bresaola e rucola", calories: 160, protein: 22, carbs: 2, fat: 6, prepTime: 3, difficulty: .easy,
            ingredients: [Ingredient(name: "Bresaola", amount: 60, unit: "g", calories: 100), Ingredient(name: "Rucola", amount: 20, unit: "g", calories: 5), Ingredient(name: "Parmigiano a scaglie", amount: 10, unit: "g", calories: 40), Ingredient(name: "Olio d'oliva", amount: 5, unit: "ml", calories: 45)],
            imageURL: "https://images.unsplash.com/photo-1588168333986-5078d3ae3976?w=400&fit=crop",
            preparationSteps: ["Arrotolare le fette di bresaola", "Aggiungere rucola e scaglie di parmigiano", "Condire con un filo d'olio"]), dietTags: [.lowCarb, .ketogenic, .softLowCarb, .mediterranean, .balanced], snackSlot: .afternoon),

        CatalogMeal(meal: Meal(type: .snack, name: "Chips di cavolo riccio", calories: 120, protein: 4, carbs: 12, fat: 6, prepTime: 20, difficulty: .easy,
            ingredients: [Ingredient(name: "Cavolo riccio", amount: 100, unit: "g", calories: 49), Ingredient(name: "Olio d'oliva", amount: 5, unit: "ml", calories: 45), Ingredient(name: "Sale", amount: 1, unit: "pizzico", calories: 0), Ingredient(name: "Lievito alimentare", amount: 5, unit: "g", calories: 20)],
            imageURL: "https://images.unsplash.com/photo-1534942240902-fc71ff3dfaee?w=400&fit=crop",
            preparationSteps: ["Lavare e asciugare il cavolo riccio, staccando le foglie", "Condire con olio e sale", "Cuocere in forno a 150°C per 15 minuti", "Cospargere con lievito alimentare"]), dietTags: [.vegan, .vegetarian, .paleo, .ketogenic, .lowCarb], snackSlot: .afternoon),

        CatalogMeal(meal: Meal(type: .snack, name: "Beef jerky artigianale", calories: 180, protein: 24, carbs: 4, fat: 6, prepTime: 2, difficulty: .easy,
            ingredients: [Ingredient(name: "Carne essiccata", amount: 50, unit: "g", calories: 180)],
            imageURL: "https://images.unsplash.com/photo-1668887465493-c4b0351aea89?w=400&fit=crop",
            preparationSteps: ["Aprire la confezione di carne essiccata", "Porzionare e servire"]), dietTags: [.carnivore, .ketogenic, .lowCarb, .paleo], snackSlot: .afternoon),

        CatalogMeal(meal: Meal(type: .snack, name: "Yogurt greco con semi di chia", calories: 180, protein: 16, carbs: 14, fat: 8, prepTime: 3, difficulty: .easy,
            ingredients: [Ingredient(name: "Yogurt greco", amount: 150, unit: "g", calories: 98), Ingredient(name: "Semi di chia", amount: 10, unit: "g", calories: 49), Ingredient(name: "Mirtilli", amount: 40, unit: "g", calories: 20)],
            imageURL: "https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=400&fit=crop",
            preparationSteps: ["Versare lo yogurt in una ciotola", "Aggiungere semi di chia e mirtilli", "Mescolare e lasciare riposare 2 minuti"]), dietTags: [.balanced, .vegetarian, .mediterranean, .softLowCarb], snackSlot: .preNight),

        CatalogMeal(meal: Meal(type: .snack, name: "Tisana con biscotti d'avena", calories: 160, protein: 4, carbs: 28, fat: 4, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Biscotti d'avena", amount: 2, unit: "pezzi", calories: 120), Ingredient(name: "Tisana camomilla", amount: 250, unit: "ml", calories: 2), Ingredient(name: "Miele", amount: 5, unit: "g", calories: 15)],
            imageURL: "https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=400&fit=crop",
            preparationSteps: ["Preparare la tisana con acqua bollente", "Lasciare in infusione per 5 minuti", "Addolcire con miele e accompagnare con biscotti"]), dietTags: [.balanced, .vegetarian, .vegan], snackSlot: .preNight),

        CatalogMeal(meal: Meal(type: .snack, name: "Ricotta con miele e cannella", calories: 170, protein: 12, carbs: 14, fat: 8, prepTime: 2, difficulty: .easy,
            ingredients: [Ingredient(name: "Ricotta", amount: 100, unit: "g", calories: 140), Ingredient(name: "Miele", amount: 10, unit: "g", calories: 30), Ingredient(name: "Cannella", amount: 2, unit: "g", calories: 5)],
            imageURL: "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400&fit=crop",
            preparationSteps: ["Versare la ricotta in una ciotolina", "Aggiungere miele e cannella", "Mescolare delicatamente"]), dietTags: [.balanced, .vegetarian, .mediterranean, .softLowCarb], snackSlot: .preNight),

        CatalogMeal(meal: Meal(type: .snack, name: "Mandorle tostate", calories: 180, protein: 6, carbs: 6, fat: 16, prepTime: 1, difficulty: .easy,
            ingredients: [Ingredient(name: "Mandorle", amount: 30, unit: "g", calories: 174), Ingredient(name: "Sale", amount: 1, unit: "pizzico", calories: 0)],
            imageURL: "https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400&fit=crop",
            preparationSteps: ["Porzionare le mandorle in una ciotolina", "Servire come snack serale"]), dietTags: [.ketogenic, .lowCarb, .paleo, .vegan, .vegetarian, .balanced], snackSlot: .preNight),

        CatalogMeal(meal: Meal(type: .snack, name: "Banana con cioccolato fondente", calories: 200, protein: 3, carbs: 32, fat: 8, prepTime: 3, difficulty: .easy,
            ingredients: [Ingredient(name: "Banana", amount: 1, unit: "media", calories: 95), Ingredient(name: "Cioccolato fondente 85%", amount: 15, unit: "g", calories: 80)],
            imageURL: "https://images.unsplash.com/photo-1571115177098-24ec42ed204d?w=400&fit=crop",
            preparationSteps: ["Tagliare la banana a rondelle", "Sciogliere il cioccolato fondente a bagnomaria", "Intingere le rondelle nel cioccolato e lasciar raffreddare"]), dietTags: [.balanced, .vegan, .vegetarian], snackSlot: .preNight),

        CatalogMeal(meal: Meal(type: .snack, name: "Frittata di albumi con erbe", calories: 120, protein: 18, carbs: 1, fat: 5, prepTime: 8, difficulty: .easy,
            ingredients: [Ingredient(name: "Albumi", amount: 4, unit: "grandi", calories: 68), Ingredient(name: "Erba cipollina", amount: 3, unit: "g", calories: 1), Ingredient(name: "Olio d'oliva", amount: 5, unit: "ml", calories: 45)],
            imageURL: "https://images.unsplash.com/photo-1525184782196-8e2ded604bf7?w=400&fit=crop",
            preparationSteps: ["Sbattere gli albumi con erba cipollina e sale", "Cuocere in padella antiaderente con poco olio", "Servire tiepida"]), dietTags: [.lowCarb, .ketogenic, .balanced, .carnivore], snackSlot: .preNight),

        CatalogMeal(meal: Meal(type: .snack, name: "Latte dorato alla curcuma", calories: 120, protein: 4, carbs: 14, fat: 5, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Latte di mandorla", amount: 250, unit: "ml", calories: 38), Ingredient(name: "Curcuma", amount: 3, unit: "g", calories: 10), Ingredient(name: "Miele", amount: 10, unit: "g", calories: 30), Ingredient(name: "Cannella", amount: 2, unit: "g", calories: 5), Ingredient(name: "Zenzero", amount: 2, unit: "g", calories: 2)],
            imageURL: "https://images.unsplash.com/photo-1571934811356-5cc061b6211f?w=400&fit=crop",
            preparationSteps: ["Scaldare il latte di mandorla senza bollire", "Aggiungere curcuma, cannella e zenzero", "Mescolare bene e addolcire con miele", "Servire caldo"]), dietTags: [.vegan, .vegetarian, .balanced], snackSlot: .preNight),

        CatalogMeal(meal: Meal(type: .snack, name: "Prosciutto crudo e melone", calories: 160, protein: 14, carbs: 12, fat: 6, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Prosciutto crudo", amount: 40, unit: "g", calories: 80), Ingredient(name: "Melone", amount: 150, unit: "g", calories: 51)],
            imageURL: "https://images.unsplash.com/photo-1587049352851-8d4e89133924?w=400&fit=crop",
            preparationSteps: ["Tagliare il melone a fette", "Avvolgere ogni fetta con una fetta di prosciutto", "Servire fresco"]), dietTags: [.mediterranean, .balanced, .softLowCarb], snackSlot: .preNight),

        CatalogMeal(meal: Meal(type: .snack, name: "Fiocchi di latte con cetriolo", calories: 130, protein: 16, carbs: 4, fat: 5, prepTime: 3, difficulty: .easy,
            ingredients: [Ingredient(name: "Fiocchi di latte", amount: 100, unit: "g", calories: 98), Ingredient(name: "Cetriolo", amount: 80, unit: "g", calories: 12), Ingredient(name: "Erba cipollina", amount: 3, unit: "g", calories: 1), Ingredient(name: "Pepe nero", amount: 1, unit: "pizzico", calories: 1)],
            imageURL: "https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=400&fit=crop",
            preparationSteps: ["Tagliare il cetriolo a dadini", "Mescolare con i fiocchi di latte", "Condire con erba cipollina e pepe"]), dietTags: [.lowCarb, .softLowCarb, .balanced, .vegetarian], snackSlot: .preNight),
    ]
}
