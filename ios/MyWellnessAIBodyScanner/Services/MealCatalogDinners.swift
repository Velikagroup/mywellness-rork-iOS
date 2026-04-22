import Foundation

extension MealDatabase {
    static let dinnerMeals: [CatalogMeal] = [
        CatalogMeal(meal: Meal(type: .dinner, name: "Salmone al forno con verdure", calories: 520, protein: 40, carbs: 18, fat: 32, prepTime: 30, difficulty: .medium,
            ingredients: [Ingredient(name: "Filetto di salmone", amount: 200, unit: "g", calories: 290), Ingredient(name: "Zucchine", amount: 100, unit: "g", calories: 17), Ingredient(name: "Pomodorini", amount: 80, unit: "g", calories: 16), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Limone", amount: 30, unit: "ml", calories: 8), Ingredient(name: "Aneto fresco", amount: 5, unit: "g", calories: 2)],
            imageURL: "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400&fit=crop",
            preparationSteps: ["Preriscaldare il forno a 200°C", "Disporre il salmone su carta forno con le verdure intorno", "Condire con olio d'oliva, limone, sale e aneto", "Cuocere per 20 minuti", "Servire con un filo d'olio a crudo"]), dietTags: [.mediterranean, .balanced, .lowCarb, .softLowCarb, .paleo]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Pollo al forno con patate e rosmarino", calories: 560, protein: 38, carbs: 42, fat: 24, prepTime: 45, difficulty: .medium,
            ingredients: [Ingredient(name: "Cosce di pollo", amount: 250, unit: "g", calories: 290), Ingredient(name: "Patate", amount: 200, unit: "g", calories: 154), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Rosmarino", amount: 5, unit: "g", calories: 6), Ingredient(name: "Aglio", amount: 3, unit: "spicchi", calories: 12)],
            imageURL: "https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=400&fit=crop",
            preparationSteps: ["Preriscaldare il forno a 200°C", "Tagliare le patate a spicchi e condire con olio e rosmarino", "Disporre il pollo con le patate nella teglia", "Aggiungere aglio intero e cuocere per 40 minuti", "Servire quando il pollo è dorato e croccante"]), dietTags: [.mediterranean, .balanced, .paleo]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Branzino al cartoccio con olive", calories: 440, protein: 38, carbs: 8, fat: 28, prepTime: 30, difficulty: .medium,
            ingredients: [Ingredient(name: "Branzino", amount: 250, unit: "g", calories: 240), Ingredient(name: "Olive taggiasche", amount: 30, unit: "g", calories: 45), Ingredient(name: "Pomodorini", amount: 80, unit: "g", calories: 16), Ingredient(name: "Capperi", amount: 10, unit: "g", calories: 5), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135)],
            imageURL: "https://images.unsplash.com/photo-1534604973900-c43ab4c2e0ab?w=400&fit=crop",
            preparationSteps: ["Preriscaldare il forno a 180°C", "Adagiare il branzino su un foglio di carta forno", "Aggiungere olive, pomodorini e capperi", "Condire con olio d'oliva e chiudere il cartoccio", "Cuocere per 20-25 minuti"]), dietTags: [.mediterranean, .lowCarb, .softLowCarb, .paleo]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Pasta al pomodoro fresco e basilico", calories: 520, protein: 16, carbs: 78, fat: 16, prepTime: 20, difficulty: .easy,
            ingredients: [Ingredient(name: "Spaghetti", amount: 80, unit: "g", calories: 280), Ingredient(name: "Pomodori San Marzano", amount: 200, unit: "g", calories: 36), Ingredient(name: "Basilico fresco", amount: 10, unit: "g", calories: 2), Ingredient(name: "Aglio", amount: 2, unit: "spicchi", calories: 8), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Parmigiano", amount: 15, unit: "g", calories: 60)],
            imageURL: "https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=400&fit=crop",
            preparationSteps: ["Cuocere la pasta in abbondante acqua salata", "Soffriggere l'aglio nell'olio, poi aggiungere i pomodori", "Cuocere il sugo per 10 minuti schiacciando i pomodori", "Scolare la pasta al dente e saltarla nel sugo", "Servire con basilico fresco e parmigiano"]), dietTags: [.mediterranean, .vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Orata al forno con patate", calories: 480, protein: 36, carbs: 32, fat: 22, prepTime: 40, difficulty: .medium,
            ingredients: [Ingredient(name: "Orata", amount: 300, unit: "g", calories: 240), Ingredient(name: "Patate", amount: 150, unit: "g", calories: 116), Ingredient(name: "Pomodorini", amount: 80, unit: "g", calories: 16), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Prezzemolo", amount: 5, unit: "g", calories: 2)],
            imageURL: "https://images.unsplash.com/photo-1580476262798-bddd9f4b7369?w=400&fit=crop",
            preparationSteps: ["Preriscaldare il forno a 190°C", "Tagliare le patate a rondelle sottili e disporre nella teglia", "Adagiare l'orata sulle patate con pomodorini", "Condire con olio, sale e prezzemolo", "Cuocere per 30-35 minuti"]), dietTags: [.mediterranean, .balanced]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Tagliata di manzo con rucola", calories: 520, protein: 44, carbs: 4, fat: 36, prepTime: 15, difficulty: .medium,
            ingredients: [Ingredient(name: "Controfiletto di manzo", amount: 200, unit: "g", calories: 340), Ingredient(name: "Rucola", amount: 60, unit: "g", calories: 15), Ingredient(name: "Parmigiano a scaglie", amount: 20, unit: "g", calories: 79), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90), Ingredient(name: "Aceto balsamico", amount: 10, unit: "ml", calories: 14)],
            imageURL: "https://images.unsplash.com/photo-1600891964092-4316c288032e?w=400&fit=crop",
            preparationSteps: ["Portare la carne a temperatura ambiente", "Scaldare una padella di ghisa fino a fumante", "Cuocere la carne 3-4 minuti per lato per una cottura media", "Far riposare 5 minuti, poi tagliare a fette", "Servire su letto di rucola con parmigiano e balsamico"]), dietTags: [.lowCarb, .ketogenic, .paleo, .carnivore, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Filetto di maiale con cavolfiore", calories: 480, protein: 40, carbs: 12, fat: 30, prepTime: 30, difficulty: .medium,
            ingredients: [Ingredient(name: "Filetto di maiale", amount: 200, unit: "g", calories: 260), Ingredient(name: "Cavolfiore", amount: 200, unit: "g", calories: 50), Ingredient(name: "Burro", amount: 20, unit: "g", calories: 144), Ingredient(name: "Aglio", amount: 2, unit: "spicchi", calories: 8), Ingredient(name: "Timo", amount: 3, unit: "g", calories: 3)],
            imageURL: "https://images.unsplash.com/photo-1609658938891-32dd655106af?w=400&fit=crop",
            preparationSteps: ["Rosolare il filetto di maiale in padella con burro e timo", "Trasferire in forno a 180°C per 15 minuti", "Cuocere il cavolfiore al vapore e frullare con burro", "Far riposare la carne 5 minuti", "Servire la carne affettata sul purè di cavolfiore"]), dietTags: [.lowCarb, .ketogenic, .paleo]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Gamberi all'aglio con zucchine", calories: 420, protein: 36, carbs: 10, fat: 26, prepTime: 15, difficulty: .easy,
            ingredients: [Ingredient(name: "Gamberi", amount: 250, unit: "g", calories: 250), Ingredient(name: "Zucchine", amount: 150, unit: "g", calories: 26), Ingredient(name: "Aglio", amount: 3, unit: "spicchi", calories: 12), Ingredient(name: "Burro", amount: 15, unit: "g", calories: 108), Ingredient(name: "Prezzemolo", amount: 5, unit: "g", calories: 2), Ingredient(name: "Peperoncino", amount: 1, unit: "pizzico", calories: 2)],
            imageURL: "https://images.unsplash.com/photo-1750680229961-1b0e607eb2c7?w=400&fit=crop",
            preparationSteps: ["Tagliare le zucchine a spaghetti con un pelapatate", "Scaldare il burro in padella con aglio e peperoncino", "Aggiungere i gamberi e cuocere 2-3 minuti per lato", "Aggiungere le zucchine e saltare per 2 minuti", "Servire con prezzemolo fresco"]), dietTags: [.lowCarb, .ketogenic, .mediterranean, .paleo]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Pollo ripieno di spinaci e formaggio", calories: 500, protein: 44, carbs: 4, fat: 34, prepTime: 30, difficulty: .hard,
            ingredients: [Ingredient(name: "Petto di pollo", amount: 200, unit: "g", calories: 240), Ingredient(name: "Spinaci", amount: 80, unit: "g", calories: 18), Ingredient(name: "Formaggio cremoso", amount: 40, unit: "g", calories: 120), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90), Ingredient(name: "Paprika", amount: 3, unit: "g", calories: 8)],
            imageURL: "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400&fit=crop",
            preparationSteps: ["Aprire il petto di pollo a libro con un taglio orizzontale", "Saltare gli spinaci e mescolarli con il formaggio cremoso", "Farcire il pollo con il ripieno e chiudere con stuzzicadenti", "Condire con paprika e olio, cuocere in padella 5 minuti per lato", "Trasferire in forno a 180°C per 15 minuti"]), dietTags: [.lowCarb, .ketogenic, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Brasato di manzo con verdure", calories: 560, protein: 44, carbs: 28, fat: 30, prepTime: 120, difficulty: .hard,
            ingredients: [Ingredient(name: "Manzo per brasato", amount: 250, unit: "g", calories: 380), Ingredient(name: "Carote", amount: 100, unit: "g", calories: 41), Ingredient(name: "Sedano", amount: 60, unit: "g", calories: 10), Ingredient(name: "Cipolla", amount: 80, unit: "g", calories: 32), Ingredient(name: "Brodo di carne", amount: 200, unit: "ml", calories: 20), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&fit=crop",
            preparationSteps: ["Rosolare la carne su tutti i lati in una pentola con olio", "Aggiungere le verdure tagliate a pezzi grossi", "Versare il brodo e portare a ebollizione", "Coprire e cuocere a fuoco bassissimo per 2 ore", "Servire la carne con le verdure e il fondo di cottura"]), dietTags: [.paleo, .balanced, .carnivore]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Spiedini di pollo con verdure grigliate", calories: 460, protein: 38, carbs: 18, fat: 26, prepTime: 25, difficulty: .easy,
            ingredients: [Ingredient(name: "Petto di pollo", amount: 200, unit: "g", calories: 240), Ingredient(name: "Peperoni", amount: 80, unit: "g", calories: 25), Ingredient(name: "Zucchine", amount: 80, unit: "g", calories: 14), Ingredient(name: "Cipolla rossa", amount: 40, unit: "g", calories: 16), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Paprika affumicata", amount: 3, unit: "g", calories: 8)],
            imageURL: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&fit=crop",
            preparationSteps: ["Tagliare pollo e verdure a cubetti da 3 cm", "Marinare il pollo con olio, paprika e sale", "Alternare pollo e verdure sugli spiedini", "Grigliare per 5-6 minuti per lato", "Servire con limone a fette"]), dietTags: [.paleo, .balanced, .mediterranean, .lowCarb, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Costata alla fiorentina", calories: 620, protein: 50, carbs: 0, fat: 46, prepTime: 20, difficulty: .medium,
            ingredients: [Ingredient(name: "Costata di manzo", amount: 300, unit: "g", calories: 540), Ingredient(name: "Sale grosso", amount: 5, unit: "g", calories: 0), Ingredient(name: "Pepe nero", amount: 2, unit: "g", calories: 5), Ingredient(name: "Burro", amount: 10, unit: "g", calories: 72)],
            imageURL: "https://images.unsplash.com/photo-1558030006-450675393462?w=400&fit=crop",
            preparationSteps: ["Portare la costata a temperatura ambiente per 30 minuti", "Scaldare la griglia o padella di ghisa al massimo", "Cuocere 4-5 minuti per lato per cottura al sangue", "Aggiungere una noce di burro e far riposare 5 minuti", "Condire con sale grosso e pepe"]), dietTags: [.carnivore, .ketogenic, .paleo]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Pollo arrosto intero con pelle croccante", calories: 540, protein: 48, carbs: 0, fat: 38, prepTime: 60, difficulty: .medium,
            ingredients: [Ingredient(name: "Pollo intero (porzione)", amount: 300, unit: "g", calories: 480), Ingredient(name: "Burro", amount: 10, unit: "g", calories: 72), Ingredient(name: "Sale", amount: 3, unit: "g", calories: 0)],
            imageURL: "https://images.unsplash.com/photo-1501200291289-c5a76c232e5f?w=400&fit=crop",
            preparationSteps: ["Preriscaldare il forno a 220°C", "Massaggiare il pollo con burro e sale", "Cuocere per 20 minuti a 220°C, poi abbassare a 180°C", "Continuare per 40 minuti bagnando con il fondo", "La pelle deve essere dorata e croccante"]), dietTags: [.carnivore, .ketogenic, .paleo]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Curry di verdure con riso basmati", calories: 500, protein: 14, carbs: 72, fat: 18, prepTime: 30, difficulty: .medium,
            ingredients: [Ingredient(name: "Riso basmati", amount: 80, unit: "g", calories: 280), Ingredient(name: "Ceci", amount: 80, unit: "g", calories: 120), Ingredient(name: "Latte di cocco", amount: 80, unit: "ml", calories: 76), Ingredient(name: "Peperoni", amount: 80, unit: "g", calories: 25), Ingredient(name: "Cipolla", amount: 40, unit: "g", calories: 16), Ingredient(name: "Pasta di curry", amount: 15, unit: "g", calories: 25)],
            imageURL: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400&fit=crop",
            preparationSteps: ["Cuocere il riso basmati in acqua salata", "Soffriggere cipolla e pasta di curry", "Aggiungere verdure a pezzi e cuocere 5 minuti", "Versare il latte di cocco e i ceci, cuocere 15 minuti", "Servire il curry sul riso"]), dietTags: [.vegan, .vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Pasta di lenticchie con sugo di verdure", calories: 480, protein: 28, carbs: 64, fat: 12, prepTime: 25, difficulty: .easy,
            ingredients: [Ingredient(name: "Pasta di lenticchie rosse", amount: 80, unit: "g", calories: 280), Ingredient(name: "Pomodori pelati", amount: 200, unit: "g", calories: 40), Ingredient(name: "Zucchine", amount: 80, unit: "g", calories: 14), Ingredient(name: "Cipolla", amount: 40, unit: "g", calories: 16), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90), Ingredient(name: "Basilico", amount: 5, unit: "g", calories: 2)],
            imageURL: "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400&fit=crop",
            preparationSteps: ["Cuocere la pasta di lenticchie al dente", "Soffriggere cipolla e zucchine nell'olio", "Aggiungere i pomodori pelati e cuocere 10 minuti", "Scolare la pasta e saltarla nel sugo", "Servire con basilico fresco"]), dietTags: [.vegan, .vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Stir-fry di tofu con verdure e sesamo", calories: 440, protein: 24, carbs: 32, fat: 24, prepTime: 20, difficulty: .medium,
            ingredients: [Ingredient(name: "Tofu", amount: 200, unit: "g", calories: 160), Ingredient(name: "Broccoli", amount: 100, unit: "g", calories: 34), Ingredient(name: "Carote", amount: 60, unit: "g", calories: 25), Ingredient(name: "Salsa di soia", amount: 20, unit: "ml", calories: 12), Ingredient(name: "Olio di sesamo", amount: 15, unit: "ml", calories: 120), Ingredient(name: "Semi di sesamo", amount: 10, unit: "g", calories: 58), Ingredient(name: "Zenzero", amount: 5, unit: "g", calories: 4)],
            imageURL: "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&fit=crop",
            preparationSteps: ["Tagliare il tofu a cubetti e asciugarlo bene", "Scaldare l'olio di sesamo nel wok ad alta temperatura", "Rosolare il tofu per 5 minuti fino a doratura", "Aggiungere verdure e zenzero, saltare 3-4 minuti", "Condire con salsa di soia e semi di sesamo"]), dietTags: [.vegan, .vegetarian]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Chili sin carne con fagioli", calories: 460, protein: 22, carbs: 58, fat: 16, prepTime: 35, difficulty: .medium,
            ingredients: [Ingredient(name: "Fagioli rossi", amount: 150, unit: "g", calories: 200), Ingredient(name: "Pomodori pelati", amount: 200, unit: "g", calories: 40), Ingredient(name: "Mais", amount: 60, unit: "g", calories: 52), Ingredient(name: "Cipolla", amount: 60, unit: "g", calories: 24), Ingredient(name: "Peperone", amount: 80, unit: "g", calories: 25), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90), Ingredient(name: "Cumino", amount: 3, unit: "g", calories: 8)],
            imageURL: "https://images.unsplash.com/photo-1515516969-d4008cc6241a?w=400&fit=crop",
            preparationSteps: ["Soffriggere cipolla e peperone nell'olio con cumino", "Aggiungere pomodori pelati e cuocere 10 minuti", "Unire fagioli e mais, cuocere per 20 minuti", "Regolare di sale e peperoncino", "Servire con coriandolo fresco"]), dietTags: [.vegan, .vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Lasagna di verdure", calories: 540, protein: 24, carbs: 52, fat: 26, prepTime: 60, difficulty: .hard,
            ingredients: [Ingredient(name: "Lasagne fresche", amount: 80, unit: "g", calories: 200), Ingredient(name: "Ricotta", amount: 100, unit: "g", calories: 140), Ingredient(name: "Spinaci", amount: 150, unit: "g", calories: 35), Ingredient(name: "Mozzarella", amount: 60, unit: "g", calories: 168), Ingredient(name: "Pomodori pelati", amount: 150, unit: "g", calories: 30), Ingredient(name: "Parmigiano", amount: 15, unit: "g", calories: 60)],
            imageURL: "https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=400&fit=crop",
            preparationSteps: ["Preparare la besciamella o usare ricotta diluita", "Alternare strati di pasta, spinaci, ricotta e sugo", "Ripetere per 3-4 strati", "Coprire con mozzarella e parmigiano", "Cuocere in forno a 180°C per 35 minuti"]), dietTags: [.vegetarian, .balanced, .mediterranean]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Melanzane alla parmigiana", calories: 480, protein: 22, carbs: 28, fat: 32, prepTime: 50, difficulty: .hard,
            ingredients: [Ingredient(name: "Melanzane", amount: 250, unit: "g", calories: 62), Ingredient(name: "Mozzarella", amount: 80, unit: "g", calories: 224), Ingredient(name: "Pomodori pelati", amount: 200, unit: "g", calories: 40), Ingredient(name: "Parmigiano", amount: 20, unit: "g", calories: 79), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Basilico", amount: 5, unit: "g", calories: 2)],
            imageURL: "https://images.unsplash.com/photo-1572453800999-e8d2d1589b7c?w=400&fit=crop",
            preparationSteps: ["Tagliare le melanzane a fette e grigliarle", "Preparare il sugo con pomodori pelati e basilico", "Alternare strati di melanzane, sugo e mozzarella", "Spolverare con parmigiano", "Cuocere in forno a 180°C per 30 minuti"]), dietTags: [.vegetarian, .mediterranean]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Frittata al forno con verdure", calories: 440, protein: 28, carbs: 14, fat: 30, prepTime: 30, difficulty: .easy,
            ingredients: [Ingredient(name: "Uova", amount: 4, unit: "grandi", calories: 280), Ingredient(name: "Zucchine", amount: 100, unit: "g", calories: 17), Ingredient(name: "Peperoni", amount: 80, unit: "g", calories: 25), Ingredient(name: "Cipolla", amount: 40, unit: "g", calories: 16), Ingredient(name: "Parmigiano", amount: 20, unit: "g", calories: 79), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1617611413968-d56f5cba4ea4?w=400&fit=crop",
            preparationSteps: ["Sbattere le uova con parmigiano, sale e pepe", "Tagliare tutte le verdure a dadini e saltarle in padella", "Versare le uova sulle verdure nella padella", "Trasferire in forno a 180°C per 15 minuti", "Servire a fette tiepida o fredda"]), dietTags: [.vegetarian, .lowCarb, .softLowCarb, .mediterranean]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Tonno alla griglia con insalata mista", calories: 480, protein: 42, carbs: 12, fat: 30, prepTime: 15, difficulty: .easy,
            ingredients: [Ingredient(name: "Trancio di tonno", amount: 200, unit: "g", calories: 260), Ingredient(name: "Insalata mista", amount: 100, unit: "g", calories: 20), Ingredient(name: "Pomodorini", amount: 80, unit: "g", calories: 16), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 135), Ingredient(name: "Aceto balsamico", amount: 10, unit: "ml", calories: 14)],
            imageURL: "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400&fit=crop",
            preparationSteps: ["Scaldare la griglia al massimo", "Condire il tonno con olio e sale", "Grigliare 2-3 minuti per lato (lasciare rosato al centro)", "Preparare l'insalata con pomodorini e condimento", "Servire il tonno a fette sull'insalata"]), dietTags: [.balanced, .mediterranean, .lowCarb, .paleo]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Risotto alla zucca", calories: 520, protein: 14, carbs: 78, fat: 16, prepTime: 35, difficulty: .medium,
            ingredients: [Ingredient(name: "Riso Carnaroli", amount: 80, unit: "g", calories: 280), Ingredient(name: "Zucca", amount: 200, unit: "g", calories: 52), Ingredient(name: "Cipolla", amount: 40, unit: "g", calories: 16), Ingredient(name: "Parmigiano", amount: 20, unit: "g", calories: 79), Ingredient(name: "Burro", amount: 10, unit: "g", calories: 72), Ingredient(name: "Brodo vegetale", amount: 300, unit: "ml", calories: 15)],
            imageURL: "https://images.unsplash.com/photo-1508615039623-a25605d2b022?w=400&fit=crop",
            preparationSteps: ["Cuocere la zucca al forno e frullarne metà", "Soffriggere cipolla nel burro e tostare il riso", "Aggiungere brodo caldo un mestolo alla volta per 18 minuti", "A metà cottura unire la zucca frullata e quella a cubetti", "Mantecare con parmigiano e un fiocco di burro"]), dietTags: [.balanced, .vegetarian, .mediterranean]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Polpette di tacchino al sugo", calories: 500, protein: 36, carbs: 38, fat: 22, prepTime: 35, difficulty: .medium,
            ingredients: [Ingredient(name: "Carne di tacchino macinata", amount: 200, unit: "g", calories: 220), Ingredient(name: "Pane grattugiato", amount: 30, unit: "g", calories: 105), Ingredient(name: "Pomodori pelati", amount: 200, unit: "g", calories: 40), Ingredient(name: "Uovo", amount: 1, unit: "grande", calories: 70), Ingredient(name: "Parmigiano", amount: 15, unit: "g", calories: 60), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1529042410759-befb1204b468?w=400&fit=crop",
            preparationSteps: ["Mescolare tacchino, pane grattugiato, uovo e parmigiano", "Formare polpette della dimensione di una noce", "Rosolarle in padella con olio per 3 minuti", "Aggiungere i pomodori pelati e cuocere per 20 minuti", "Servire con basilico fresco"]), dietTags: [.balanced, .mediterranean]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Spaghetti alle vongole", calories: 520, protein: 28, carbs: 68, fat: 14, prepTime: 25, difficulty: .medium,
            ingredients: [Ingredient(name: "Spaghetti", amount: 80, unit: "g", calories: 280), Ingredient(name: "Vongole", amount: 300, unit: "g", calories: 120), Ingredient(name: "Aglio", amount: 3, unit: "spicchi", calories: 12), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90), Ingredient(name: "Prezzemolo", amount: 5, unit: "g", calories: 2), Ingredient(name: "Peperoncino", amount: 1, unit: "piccolo", calories: 4)],
            imageURL: "https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=400&fit=crop",
            preparationSteps: ["Cuocere gli spaghetti in acqua salata", "In padella soffriggere aglio e peperoncino nell'olio", "Aggiungere le vongole, coprire e cuocere fino ad apertura", "Scolare la pasta e saltarla con le vongole", "Servire con prezzemolo tritato"]), dietTags: [.mediterranean, .balanced]),

        CatalogMeal(meal: Meal(type: .dinner, name: "Petto di tacchino con verdure al vapore", calories: 420, protein: 42, carbs: 22, fat: 18, prepTime: 25, difficulty: .easy,
            ingredients: [Ingredient(name: "Petto di tacchino", amount: 200, unit: "g", calories: 220), Ingredient(name: "Broccoli", amount: 120, unit: "g", calories: 41), Ingredient(name: "Carote", amount: 80, unit: "g", calories: 33), Ingredient(name: "Patata dolce", amount: 80, unit: "g", calories: 69), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90)],
            imageURL: "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&fit=crop",
            preparationSteps: ["Grigliare il petto di tacchino per 6 minuti per lato", "Cuocere broccoli e carote al vapore per 8 minuti", "Cuocere la patata dolce al vapore per 12 minuti", "Lasciare riposare il tacchino e affettarlo", "Condire tutto con olio d'oliva e sale"]), dietTags: [.balanced, .softLowCarb]),
    ]
}
