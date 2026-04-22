import Foundation

extension MealDatabase {
    static let lunchMeals: [CatalogMeal] = [
        CatalogMeal(meal: Meal(type: .lunch, name: "Insalata greca con feta e olive", calories: 520, protein: 18, carbs: 22, fat: 40, prepTime: 10, difficulty: .easy,
            ingredients: [Ingredient(name: "Pomodori", amount: 150, unit: "g", calories: 27), Ingredient(name: "Cetriolo", amount: 100, unit: "g", calories: 15), Ingredient(name: "Feta", amount: 80, unit: "g", calories: 200), Ingredient(name: "Olive Kalamata", amount: 40, unit: "g", calories: 60), Ingredient(name: "Olio d'oliva", amount: 25, unit: "ml", calories: 220)],
            imageURL: "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400&fit=crop",
            preparationSteps: ["Tagliare pomodori, cetriolo e cipolla rossa a pezzi", "Disporre le verdure in un piatto largo", "Aggiungere le olive Kalamata e la feta a cubetti", "Condire con olio d'oliva, origano e sale"]), dietTags: [.mediterranean, .vegetarian, .lowCarb, .softLowCarb, .ketogenic]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Pasta integrale al pesto genovese", calories: 580, protein: 20, carbs: 72, fat: 24, prepTime: 20, difficulty: .easy,
            ingredients: [Ingredient(name: "Pasta integrale", amount: 80, unit: "g", calories: 280), Ingredient(name: "Pesto genovese", amount: 30, unit: "g", calories: 140), Ingredient(name: "Pomodorini", amount: 80, unit: "g", calories: 16), Ingredient(name: "Pinoli", amount: 10, unit: "g", calories: 67), Ingredient(name: "Parmigiano", amount: 15, unit: "g", calories: 60)],
            imageURL: "https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=400&fit=crop",
            preparationSteps: ["Cuocere la pasta in abbondante acqua salata", "Scolare la pasta al dente conservando un po' di acqua di cottura", "Condire con il pesto e un cucchiaio di acqua di cottura", "Aggiungere pomodorini tagliati a metà", "Completare con pinoli e parmigiano grattugiato"]), dietTags: [.mediterranean, .vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Bowl di quinoa mediterranea", calories: 560, protein: 22, carbs: 62, fat: 24, prepTime: 25, difficulty: .easy,
            ingredients: [Ingredient(name: "Quinoa", amount: 80, unit: "g", calories: 280), Ingredient(name: "Ceci cotti", amount: 80, unit: "g", calories: 120), Ingredient(name: "Pomodorini", amount: 80, unit: "g", calories: 16), Ingredient(name: "Cetriolo", amount: 60, unit: "g", calories: 10), Ingredient(name: "Hummus", amount: 40, unit: "g", calories: 80), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&fit=crop",
            preparationSteps: ["Cuocere la quinoa in acqua salata per 15 minuti", "Scolare e raffreddare la quinoa", "Disporre nella ciotola con ceci, pomodorini e cetriolo", "Aggiungere una generosa porzione di hummus", "Condire con olio d'oliva e limone"]), dietTags: [.mediterranean, .vegan, .vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Insalata Niçoise con tonno", calories: 580, protein: 38, carbs: 28, fat: 36, prepTime: 15, difficulty: .easy,
            ingredients: [Ingredient(name: "Tonno in scatola", amount: 150, unit: "g", calories: 165), Ingredient(name: "Uova sode", amount: 2, unit: "grandi", calories: 140), Ingredient(name: "Fagiolini", amount: 80, unit: "g", calories: 25), Ingredient(name: "Olive nere", amount: 30, unit: "g", calories: 45), Ingredient(name: "Patate lesse", amount: 80, unit: "g", calories: 62), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135)],
            imageURL: "https://images.unsplash.com/photo-1594834749740-74b3f6764be4?w=400&fit=crop",
            preparationSteps: ["Lessare uova e fagiolini separatamente", "Tagliare le patate lesse a fette", "Comporre l'insalata con tutti gli ingredienti", "Condire con olio d'oliva, sale e pepe"]), dietTags: [.mediterranean, .balanced]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Zuppa di lenticchie e verdure", calories: 480, protein: 26, carbs: 68, fat: 10, prepTime: 35, difficulty: .medium,
            ingredients: [Ingredient(name: "Lenticchie rosse", amount: 100, unit: "g", calories: 280), Ingredient(name: "Carote", amount: 80, unit: "g", calories: 33), Ingredient(name: "Sedano", amount: 60, unit: "g", calories: 10), Ingredient(name: "Cipolla", amount: 60, unit: "g", calories: 24), Ingredient(name: "Pomodori pelati", amount: 150, unit: "g", calories: 30), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&fit=crop",
            preparationSteps: ["Soffriggere cipolla, carota e sedano nell'olio", "Aggiungere le lenticchie e i pomodori pelati", "Coprire con brodo vegetale e cuocere per 25 minuti", "Frullare parzialmente per una consistenza cremosa", "Servire con un filo d'olio a crudo"]), dietTags: [.mediterranean, .vegan, .vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Insalata di pollo grigliato e avocado", calories: 540, protein: 40, carbs: 12, fat: 38, prepTime: 20, difficulty: .easy,
            ingredients: [Ingredient(name: "Petto di pollo", amount: 180, unit: "g", calories: 216), Ingredient(name: "Avocado", amount: 80, unit: "g", calories: 128), Ingredient(name: "Lattuga mista", amount: 80, unit: "g", calories: 12), Ingredient(name: "Pomodorini", amount: 60, unit: "g", calories: 12), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Limone", amount: 15, unit: "ml", calories: 4)],
            imageURL: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&fit=crop",
            preparationSteps: ["Grigliare il petto di pollo per 6 minuti per lato", "Lasciare riposare 5 minuti e tagliare a fette", "Preparare il letto di lattuga con pomodorini", "Aggiungere il pollo e l'avocado a fette", "Condire con olio, limone, sale e pepe"]), dietTags: [.lowCarb, .softLowCarb, .ketogenic, .paleo, .balanced]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Salmone in crosta di erbe con insalata", calories: 560, protein: 38, carbs: 8, fat: 42, prepTime: 25, difficulty: .medium,
            ingredients: [Ingredient(name: "Filetto di salmone", amount: 200, unit: "g", calories: 290), Ingredient(name: "Erbe miste fresche", amount: 15, unit: "g", calories: 5), Ingredient(name: "Rucola", amount: 60, unit: "g", calories: 15), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Limone", amount: 30, unit: "ml", calories: 8), Ingredient(name: "Semi di sesamo", amount: 10, unit: "g", calories: 58)],
            imageURL: "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&fit=crop",
            preparationSteps: ["Mescolare erbe tritate e semi di sesamo", "Spalmare un velo di olio sul salmone e ricoprire con il mix", "Cuocere in forno a 200°C per 15 minuti", "Preparare l'insalata di rucola con limone e olio", "Servire il salmone sull'insalata"]), dietTags: [.lowCarb, .ketogenic, .paleo, .mediterranean]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Involtini di lattuga con tacchino", calories: 420, protein: 36, carbs: 8, fat: 28, prepTime: 15, difficulty: .easy,
            ingredients: [Ingredient(name: "Petto di tacchino a fette", amount: 150, unit: "g", calories: 165), Ingredient(name: "Lattuga iceberg", amount: 4, unit: "foglie", calories: 8), Ingredient(name: "Avocado", amount: 60, unit: "g", calories: 96), Ingredient(name: "Formaggio spalmabile", amount: 30, unit: "g", calories: 90), Ingredient(name: "Pomodoro", amount: 60, unit: "g", calories: 12), Ingredient(name: "Senape", amount: 10, unit: "g", calories: 10)],
            imageURL: "https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=400&fit=crop",
            preparationSteps: ["Stendere le foglie di lattuga come base", "Spalmare il formaggio spalmabile e la senape", "Aggiungere tacchino, avocado e pomodoro a fette", "Arrotolare strettamente le foglie", "Tagliare a metà e servire"]), dietTags: [.lowCarb, .ketogenic, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Zuppa di broccoli e formaggio", calories: 440, protein: 22, carbs: 14, fat: 34, prepTime: 25, difficulty: .medium,
            ingredients: [Ingredient(name: "Broccoli", amount: 250, unit: "g", calories: 85), Ingredient(name: "Formaggio cheddar", amount: 60, unit: "g", calories: 240), Ingredient(name: "Panna", amount: 50, unit: "ml", calories: 100), Ingredient(name: "Cipolla", amount: 40, unit: "g", calories: 16), Ingredient(name: "Brodo vegetale", amount: 200, unit: "ml", calories: 10)],
            imageURL: "https://images.unsplash.com/photo-1706334345140-f2e5e4d5806d?w=400&fit=crop",
            preparationSteps: ["Soffriggere la cipolla in un po' di burro", "Aggiungere i broccoli e il brodo vegetale", "Cuocere per 15 minuti fino a che i broccoli sono morbidi", "Frullare aggiungendo panna e metà del formaggio", "Servire con il formaggio rimanente grattugiato sopra"]), dietTags: [.ketogenic, .lowCarb, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Bowl di pollo con patate dolci", calories: 550, protein: 38, carbs: 48, fat: 22, prepTime: 30, difficulty: .medium,
            ingredients: [Ingredient(name: "Petto di pollo", amount: 180, unit: "g", calories: 216), Ingredient(name: "Patata dolce", amount: 200, unit: "g", calories: 172), Ingredient(name: "Broccoli", amount: 100, unit: "g", calories: 34), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Paprika", amount: 3, unit: "g", calories: 8)],
            imageURL: "https://images.unsplash.com/photo-1604909052743-94e838986d24?w=400&fit=crop",
            preparationSteps: ["Tagliare la patata dolce a cubetti e condire con olio e paprika", "Cuocere in forno a 200°C per 20 minuti", "Grigliare il petto di pollo per 6 minuti per lato", "Cuocere i broccoli al vapore per 5 minuti", "Comporre la bowl con tutti gli ingredienti"]), dietTags: [.paleo, .balanced]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Hamburger senza pane con insalata", calories: 480, protein: 36, carbs: 12, fat: 32, prepTime: 20, difficulty: .medium,
            ingredients: [Ingredient(name: "Carne macinata magra", amount: 180, unit: "g", calories: 280), Ingredient(name: "Lattuga", amount: 60, unit: "g", calories: 10), Ingredient(name: "Pomodoro", amount: 80, unit: "g", calories: 16), Ingredient(name: "Cipolla rossa", amount: 30, unit: "g", calories: 12), Ingredient(name: "Avocado", amount: 60, unit: "g", calories: 96), Ingredient(name: "Senape", amount: 10, unit: "g", calories: 10)],
            imageURL: "https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400&fit=crop",
            preparationSteps: ["Formare un hamburger con la carne macinata e sale", "Cuocere in padella di ghisa per 4 minuti per lato", "Usare foglie di lattuga come 'pane'", "Aggiungere pomodoro, cipolla rossa e avocado", "Completare con senape"]), dietTags: [.paleo, .lowCarb, .ketogenic, .carnivore]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Costolette di agnello alla griglia", calories: 580, protein: 42, carbs: 0, fat: 44, prepTime: 20, difficulty: .medium,
            ingredients: [Ingredient(name: "Costolette di agnello", amount: 250, unit: "g", calories: 520), Ingredient(name: "Sale grosso", amount: 3, unit: "g", calories: 0), Ingredient(name: "Rosmarino", amount: 3, unit: "g", calories: 4), Ingredient(name: "Burro", amount: 10, unit: "g", calories: 72)],
            imageURL: "https://images.unsplash.com/photo-1514516345957-556ca7d90a29?w=400&fit=crop",
            preparationSteps: ["Portare le costolette a temperatura ambiente", "Condire con sale grosso e rosmarino", "Grigliare a fuoco alto per 3-4 minuti per lato", "Aggiungere una noce di burro alla fine", "Riposare 5 minuti prima di servire"]), dietTags: [.carnivore, .ketogenic, .paleo]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Petto di pollo arrosto con burro alle erbe", calories: 480, protein: 48, carbs: 1, fat: 30, prepTime: 25, difficulty: .easy,
            ingredients: [Ingredient(name: "Petto di pollo", amount: 250, unit: "g", calories: 300), Ingredient(name: "Burro", amount: 25, unit: "g", calories: 180), Ingredient(name: "Timo", amount: 3, unit: "g", calories: 3), Ingredient(name: "Aglio", amount: 2, unit: "spicchi", calories: 8)],
            imageURL: "https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=400&fit=crop",
            preparationSteps: ["Mescolare burro morbido con timo e aglio tritato", "Condire il pollo con sale e pepe", "Cuocere in padella per 6 minuti per lato", "Aggiungere il burro alle erbe nell'ultimo minuto", "Affettare e servire con il burro fuso"]), dietTags: [.carnivore, .ketogenic, .lowCarb, .paleo]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Buddha bowl con tofu e quinoa", calories: 520, protein: 24, carbs: 58, fat: 22, prepTime: 25, difficulty: .medium,
            ingredients: [Ingredient(name: "Tofu", amount: 150, unit: "g", calories: 120), Ingredient(name: "Quinoa", amount: 70, unit: "g", calories: 245), Ingredient(name: "Edamame", amount: 60, unit: "g", calories: 65), Ingredient(name: "Carote grattugiate", amount: 60, unit: "g", calories: 25), Ingredient(name: "Avocado", amount: 40, unit: "g", calories: 64), Ingredient(name: "Salsa di soia", amount: 15, unit: "ml", calories: 10)],
            imageURL: "https://images.unsplash.com/photo-1540914124281-342587941389?w=400&fit=crop",
            preparationSteps: ["Cuocere la quinoa in acqua salata per 15 minuti", "Tagliare il tofu a cubetti e saltarlo in padella con salsa di soia", "Preparare le verdure: grattugiare carote, sgusciare edamame", "Comporre la bowl con quinoa, tofu e verdure", "Completare con avocado a fette"]), dietTags: [.vegan, .vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Curry di ceci e spinaci", calories: 480, protein: 20, carbs: 56, fat: 20, prepTime: 30, difficulty: .medium,
            ingredients: [Ingredient(name: "Ceci cotti", amount: 200, unit: "g", calories: 300), Ingredient(name: "Spinaci", amount: 100, unit: "g", calories: 23), Ingredient(name: "Latte di cocco", amount: 100, unit: "ml", calories: 95), Ingredient(name: "Cipolla", amount: 60, unit: "g", calories: 24), Ingredient(name: "Curry in polvere", amount: 5, unit: "g", calories: 15), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&fit=crop",
            preparationSteps: ["Soffriggere la cipolla nell'olio con il curry", "Aggiungere i ceci e mescolare per 2 minuti", "Versare il latte di cocco e cuocere per 15 minuti", "Aggiungere gli spinaci e cuocere fino a che appassiscono", "Servire con riso basmati o da solo"]), dietTags: [.vegan, .vegetarian, .balanced, .mediterranean]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Wrap di hummus e verdure grigliate", calories: 460, protein: 16, carbs: 52, fat: 22, prepTime: 20, difficulty: .easy,
            ingredients: [Ingredient(name: "Tortilla integrale", amount: 1, unit: "grande", calories: 180), Ingredient(name: "Hummus", amount: 60, unit: "g", calories: 120), Ingredient(name: "Zucchine grigliate", amount: 80, unit: "g", calories: 24), Ingredient(name: "Peperoni grigliati", amount: 80, unit: "g", calories: 35), Ingredient(name: "Rucola", amount: 30, unit: "g", calories: 8), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=400&fit=crop",
            preparationSteps: ["Grigliare zucchine e peperoni tagliati a fette", "Scaldare la tortilla in padella per 30 secondi", "Spalmare l'hummus sulla tortilla", "Aggiungere le verdure grigliate e la rucola", "Arrotolare strettamente e tagliare a metà"]), dietTags: [.vegan, .vegetarian, .balanced, .mediterranean]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Pad thai di verdure con noodles di riso", calories: 480, protein: 14, carbs: 66, fat: 18, prepTime: 20, difficulty: .medium,
            ingredients: [Ingredient(name: "Noodles di riso", amount: 80, unit: "g", calories: 260), Ingredient(name: "Tofu", amount: 80, unit: "g", calories: 64), Ingredient(name: "Germogli di soia", amount: 60, unit: "g", calories: 18), Ingredient(name: "Carote", amount: 50, unit: "g", calories: 20), Ingredient(name: "Arachidi", amount: 15, unit: "g", calories: 85), Ingredient(name: "Salsa di soia", amount: 15, unit: "ml", calories: 10), Ingredient(name: "Lime", amount: 15, unit: "ml", calories: 4)],
            imageURL: "https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400&fit=crop",
            preparationSteps: ["Ammollare i noodles di riso in acqua calda per 5 minuti", "Saltare il tofu a cubetti in padella con olio", "Aggiungere carote e germogli di soia", "Unire i noodles scolati e condire con salsa di soia e lime", "Servire con arachidi tritate sopra"]), dietTags: [.vegan, .vegetarian]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Risotto ai funghi porcini", calories: 540, protein: 16, carbs: 72, fat: 20, prepTime: 35, difficulty: .hard,
            ingredients: [Ingredient(name: "Riso Carnaroli", amount: 80, unit: "g", calories: 280), Ingredient(name: "Funghi porcini", amount: 100, unit: "g", calories: 30), Ingredient(name: "Cipolla", amount: 40, unit: "g", calories: 16), Ingredient(name: "Parmigiano", amount: 30, unit: "g", calories: 118), Ingredient(name: "Burro", amount: 15, unit: "g", calories: 108), Ingredient(name: "Brodo vegetale", amount: 300, unit: "ml", calories: 15)],
            imageURL: "https://images.unsplash.com/photo-1633964913295-ceb43826e7c1?w=400&fit=crop",
            preparationSteps: ["Soffriggere la cipolla nel burro fino a trasparenza", "Tostare il riso per 2 minuti mescolando", "Aggiungere i funghi e un mestolo di brodo caldo", "Continuare ad aggiungere brodo mestolo per mestolo per 18 minuti", "Mantecare con parmigiano e un fiocco di burro"]), dietTags: [.vegetarian, .mediterranean, .balanced]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Caprese con burrata e pomodori", calories: 480, protein: 22, carbs: 16, fat: 36, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Burrata", amount: 125, unit: "g", calories: 280), Ingredient(name: "Pomodori cuore di bue", amount: 200, unit: "g", calories: 36), Ingredient(name: "Basilico fresco", amount: 5, unit: "g", calories: 2), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Pane integrale", amount: 1, unit: "fetta", calories: 70)],
            imageURL: "https://images.unsplash.com/photo-1592417817098-8fd3d9eb14a5?w=400&fit=crop",
            preparationSteps: ["Tagliare i pomodori a fette spesse", "Disporre le fette nel piatto alternando con la burrata", "Aggiungere foglie di basilico fresco", "Condire con olio d'oliva, sale e pepe", "Accompagnare con pane integrale"]), dietTags: [.vegetarian, .mediterranean, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Pasta e fagioli", calories: 520, protein: 22, carbs: 76, fat: 14, prepTime: 35, difficulty: .medium,
            ingredients: [Ingredient(name: "Pasta mista", amount: 60, unit: "g", calories: 210), Ingredient(name: "Fagioli borlotti", amount: 150, unit: "g", calories: 195), Ingredient(name: "Pomodori pelati", amount: 100, unit: "g", calories: 20), Ingredient(name: "Cipolla", amount: 40, unit: "g", calories: 16), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400&fit=crop",
            preparationSteps: ["Soffriggere cipolla e sedano nell'olio d'oliva", "Aggiungere i pomodori pelati e cuocere 10 minuti", "Unire i fagioli e il brodo vegetale", "Portare a ebollizione e aggiungere la pasta", "Cuocere fino a che la pasta è al dente"]), dietTags: [.vegetarian, .vegan, .balanced, .mediterranean]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Pollo alla griglia con riso e verdure", calories: 560, protein: 40, carbs: 56, fat: 18, prepTime: 25, difficulty: .easy,
            ingredients: [Ingredient(name: "Petto di pollo", amount: 180, unit: "g", calories: 216), Ingredient(name: "Riso basmati", amount: 80, unit: "g", calories: 280), Ingredient(name: "Zucchine", amount: 80, unit: "g", calories: 14), Ingredient(name: "Peperoni", amount: 60, unit: "g", calories: 18), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=400&fit=crop",
            preparationSteps: ["Cuocere il riso basmati in acqua salata", "Grigliare il petto di pollo per 6 minuti per lato", "Saltare zucchine e peperoni in padella", "Comporre il piatto con riso, pollo e verdure", "Condire con un filo d'olio e limone"]), dietTags: [.balanced, .mediterranean]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Poke bowl al salmone", calories: 580, protein: 32, carbs: 62, fat: 22, prepTime: 15, difficulty: .easy,
            ingredients: [Ingredient(name: "Salmone fresco", amount: 120, unit: "g", calories: 175), Ingredient(name: "Riso sushi", amount: 80, unit: "g", calories: 280), Ingredient(name: "Avocado", amount: 40, unit: "g", calories: 64), Ingredient(name: "Edamame", amount: 40, unit: "g", calories: 44), Ingredient(name: "Salsa di soia", amount: 15, unit: "ml", calories: 10), Ingredient(name: "Semi di sesamo", amount: 5, unit: "g", calories: 30)],
            imageURL: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&fit=crop",
            preparationSteps: ["Cuocere il riso sushi e lasciare raffreddare", "Tagliare il salmone a cubetti", "Marinare il salmone con salsa di soia per 5 minuti", "Comporre la bowl con riso, salmone, avocado e edamame", "Decorare con semi di sesamo"]), dietTags: [.balanced]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Panino integrale con tacchino e verdure", calories: 480, protein: 32, carbs: 48, fat: 18, prepTime: 10, difficulty: .easy,
            ingredients: [Ingredient(name: "Pane integrale", amount: 2, unit: "fette", calories: 160), Ingredient(name: "Petto di tacchino", amount: 120, unit: "g", calories: 132), Ingredient(name: "Lattuga", amount: 30, unit: "g", calories: 5), Ingredient(name: "Pomodoro", amount: 60, unit: "g", calories: 12), Ingredient(name: "Avocado", amount: 40, unit: "g", calories: 64), Ingredient(name: "Senape", amount: 10, unit: "g", calories: 10)],
            imageURL: "https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400&fit=crop",
            preparationSteps: ["Tostare leggermente il pane integrale", "Spalmare senape e avocado schiacciato", "Aggiungere le fette di tacchino, lattuga e pomodoro", "Chiudere il panino e tagliare in diagonale"]), dietTags: [.balanced, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Couscous con verdure e pollo", calories: 540, protein: 34, carbs: 60, fat: 16, prepTime: 20, difficulty: .easy,
            ingredients: [Ingredient(name: "Couscous integrale", amount: 80, unit: "g", calories: 240), Ingredient(name: "Petto di pollo", amount: 150, unit: "g", calories: 180), Ingredient(name: "Zucchine", amount: 80, unit: "g", calories: 14), Ingredient(name: "Peperoni", amount: 60, unit: "g", calories: 18), Ingredient(name: "Cipolla", amount: 40, unit: "g", calories: 16), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=400&fit=crop",
            preparationSteps: ["Preparare il couscous con brodo bollente e coprire 5 minuti", "Grigliare il pollo e tagliare a pezzi", "Saltare le verdure in padella con olio", "Sgranare il couscous con una forchetta", "Unire tutto e condire con olio e limone"]), dietTags: [.balanced, .mediterranean]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Minestrone di verdure con crostini", calories: 420, protein: 14, carbs: 58, fat: 14, prepTime: 40, difficulty: .medium,
            ingredients: [Ingredient(name: "Verdure miste", amount: 300, unit: "g", calories: 90), Ingredient(name: "Fagioli cannellini", amount: 80, unit: "g", calories: 100), Ingredient(name: "Pasta ditalini", amount: 40, unit: "g", calories: 140), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90), Ingredient(name: "Parmigiano", amount: 10, unit: "g", calories: 40)],
            imageURL: "https://images.unsplash.com/photo-1603105037880-880cd4edfb0d?w=400&fit=crop",
            preparationSteps: ["Tagliare tutte le verdure a dadini piccoli", "Soffriggere nell'olio e aggiungere brodo", "Cuocere per 20 minuti, poi aggiungere pasta e fagioli", "Cuocere altri 10 minuti fino a pasta al dente", "Servire con parmigiano grattugiato"]), dietTags: [.balanced, .vegetarian, .mediterranean]),

        CatalogMeal(meal: Meal(type: .lunch, name: "Fajitas di manzo con peperoni", calories: 540, protein: 36, carbs: 42, fat: 24, prepTime: 20, difficulty: .medium,
            ingredients: [Ingredient(name: "Manzo a strisce", amount: 180, unit: "g", calories: 270), Ingredient(name: "Tortilla integrale", amount: 2, unit: "piccole", calories: 160), Ingredient(name: "Peperoni misti", amount: 120, unit: "g", calories: 36), Ingredient(name: "Cipolla", amount: 60, unit: "g", calories: 24), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90), Ingredient(name: "Lime", amount: 15, unit: "ml", calories: 4)],
            imageURL: "https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=400&fit=crop",
            preparationSteps: ["Tagliare il manzo a strisce sottili e marinare con lime", "Scaldare la padella ad alta temperatura", "Saltare il manzo per 3-4 minuti, poi rimuovere", "Nella stessa padella saltare peperoni e cipolla", "Servire nelle tortilla calde con il manzo"]), dietTags: [.balanced]),
    ]
}
