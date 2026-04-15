import Foundation

extension MealDatabase {
    static let breakfastMeals: [CatalogMeal] = [
        CatalogMeal(meal: Meal(type: .breakfast, name: "Toast con salmone e avocado", calories: 480, protein: 24, carbs: 35, fat: 28, prepTime: 10, difficulty: .easy,
            ingredients: [Ingredient(name: "Pane integrale", amount: 2, unit: "fette", calories: 140), Ingredient(name: "Avocado", amount: 80, unit: "g", calories: 128), Ingredient(name: "Salmone affumicato", amount: 80, unit: "g", calories: 132), Ingredient(name: "Limone", amount: 10, unit: "ml", calories: 4), Ingredient(name: "Semi di sesamo", amount: 5, unit: "g", calories: 30)],
            imageURL: "https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400&fit=crop",
            preparationSteps: ["Tostare il pane integrale fino a doratura", "Schiacciare l'avocado con una forchetta e aggiungere succo di limone", "Spalmare l'avocado sul pane tostato", "Adagiare le fette di salmone affumicato sopra", "Decorare con semi di sesamo"]), dietTags: [.mediterranean, .balanced, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Shakshuka mediterranea", calories: 420, protein: 26, carbs: 30, fat: 22, prepTime: 20, difficulty: .medium,
            ingredients: [Ingredient(name: "Uova", amount: 3, unit: "grandi", calories: 210), Ingredient(name: "Pomodori pelati", amount: 200, unit: "g", calories: 40), Ingredient(name: "Peperone", amount: 80, unit: "g", calories: 25), Ingredient(name: "Cipolla", amount: 60, unit: "g", calories: 25), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 120)],
            imageURL: "https://images.unsplash.com/photo-1590412200988-a436970781fa?w=400&fit=crop",
            preparationSteps: ["Soffriggere cipolla e peperone nell'olio d'oliva per 5 minuti", "Aggiungere i pomodori pelati e cuocere per 10 minuti", "Creare 3 incavi nel sugo e rompere le uova dentro", "Coprire e cuocere a fuoco basso per 5-7 minuti", "Servire con un filo d'olio d'oliva"]), dietTags: [.mediterranean, .balanced, .paleo, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Yogurt greco con miele e noci", calories: 380, protein: 22, carbs: 42, fat: 14, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Yogurt greco", amount: 200, unit: "g", calories: 130), Ingredient(name: "Miele", amount: 20, unit: "g", calories: 60), Ingredient(name: "Noci", amount: 20, unit: "g", calories: 130), Ingredient(name: "Mirtilli", amount: 80, unit: "g", calories: 40), Ingredient(name: "Semi di chia", amount: 5, unit: "g", calories: 25)],
            imageURL: "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&fit=crop",
            preparationSteps: ["Versare lo yogurt greco in una ciotola", "Aggiungere i mirtilli freschi", "Sbricolare le noci sopra", "Completare con miele e semi di chia"]), dietTags: [.mediterranean, .balanced, .vegetarian]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Frittata di spinaci e feta", calories: 390, protein: 28, carbs: 8, fat: 28, prepTime: 15, difficulty: .easy,
            ingredients: [Ingredient(name: "Uova", amount: 3, unit: "grandi", calories: 210), Ingredient(name: "Spinaci freschi", amount: 100, unit: "g", calories: 23), Ingredient(name: "Feta", amount: 40, unit: "g", calories: 100), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90), Ingredient(name: "Origano", amount: 2, unit: "g", calories: 5)],
            imageURL: "https://images.unsplash.com/photo-1510693206972-df098062cb71?w=400&fit=crop",
            preparationSteps: ["Sbattere le uova con origano e sale", "Scaldare l'olio in padella e saltare gli spinaci", "Versare le uova sbattute sugli spinaci", "Sbricolare la feta sopra e coprire", "Cuocere a fuoco medio per 5-7 minuti"]), dietTags: [.mediterranean, .lowCarb, .softLowCarb, .ketogenic, .vegetarian]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Porridge con banana e cannella", calories: 420, protein: 14, carbs: 68, fat: 10, prepTime: 10, difficulty: .easy,
            ingredients: [Ingredient(name: "Fiocchi d'avena", amount: 80, unit: "g", calories: 280), Ingredient(name: "Latte di mandorla", amount: 200, unit: "ml", calories: 30), Ingredient(name: "Banana", amount: 1, unit: "media", calories: 95), Ingredient(name: "Cannella", amount: 3, unit: "g", calories: 5), Ingredient(name: "Miele", amount: 5, unit: "g", calories: 15)],
            imageURL: "https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=400&fit=crop",
            preparationSteps: ["Portare a ebollizione il latte di mandorla", "Aggiungere i fiocchi d'avena e cuocere per 5 minuti mescolando", "Tagliare la banana a rondelle", "Versare il porridge nella ciotola e decorare con banana", "Spolverare con cannella e un filo di miele"]), dietTags: [.balanced, .vegetarian, .vegan]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Pancake proteici ai mirtilli", calories: 450, protein: 32, carbs: 48, fat: 14, prepTime: 15, difficulty: .medium,
            ingredients: [Ingredient(name: "Farina d'avena", amount: 60, unit: "g", calories: 210), Ingredient(name: "Albumi", amount: 4, unit: "grandi", calories: 68), Ingredient(name: "Banana", amount: 1, unit: "piccola", calories: 72), Ingredient(name: "Mirtilli", amount: 60, unit: "g", calories: 30), Ingredient(name: "Proteine in polvere", amount: 20, unit: "g", calories: 80)],
            imageURL: "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&fit=crop",
            preparationSteps: ["Frullare farina d'avena, albumi, banana e proteine in polvere", "Scaldare una padella antiaderente a fuoco medio", "Versare piccoli cerchi di impasto e aggiungere mirtilli", "Cuocere 2-3 minuti per lato fino a doratura", "Servire impilati con mirtilli freschi sopra"]), dietTags: [.balanced, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Uova strapazzate con avocado", calories: 440, protein: 26, carbs: 10, fat: 34, prepTime: 10, difficulty: .easy,
            ingredients: [Ingredient(name: "Uova", amount: 3, unit: "grandi", calories: 210), Ingredient(name: "Avocado", amount: 80, unit: "g", calories: 128), Ingredient(name: "Burro", amount: 10, unit: "g", calories: 72), Ingredient(name: "Erba cipollina", amount: 5, unit: "g", calories: 2), Ingredient(name: "Pepe nero", amount: 1, unit: "pizzico", calories: 0)],
            imageURL: "https://images.unsplash.com/photo-1586511925558-a4c6376fe65f?w=400&fit=crop",
            preparationSteps: ["Sbattere le uova con un pizzico di sale", "Sciogliere il burro in padella a fuoco basso", "Versare le uova e mescolare lentamente con spatola", "Togliere dal fuoco quando ancora cremose", "Servire con avocado a fette e erba cipollina"]), dietTags: [.lowCarb, .softLowCarb, .ketogenic, .paleo, .balanced]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Smoothie bowl tropicale", calories: 380, protein: 16, carbs: 58, fat: 10, prepTime: 10, difficulty: .easy,
            ingredients: [Ingredient(name: "Banana congelata", amount: 1, unit: "grande", calories: 105), Ingredient(name: "Mango", amount: 100, unit: "g", calories: 60), Ingredient(name: "Yogurt greco", amount: 100, unit: "g", calories: 65), Ingredient(name: "Granola", amount: 30, unit: "g", calories: 120), Ingredient(name: "Cocco grattugiato", amount: 10, unit: "g", calories: 35)],
            imageURL: "https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400&fit=crop",
            preparationSteps: ["Frullare banana congelata, mango e yogurt greco", "Versare nella ciotola con consistenza densa", "Aggiungere granola, cocco grattugiato e frutta fresca", "Decorare con semi di chia a piacere"]), dietTags: [.balanced, .vegetarian]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Bacon croccante con uova al tegamino", calories: 480, protein: 30, carbs: 2, fat: 38, prepTime: 12, difficulty: .easy,
            ingredients: [Ingredient(name: "Uova", amount: 3, unit: "grandi", calories: 210), Ingredient(name: "Bacon", amount: 60, unit: "g", calories: 200), Ingredient(name: "Burro", amount: 8, unit: "g", calories: 58), Ingredient(name: "Spinaci", amount: 30, unit: "g", calories: 7), Ingredient(name: "Sale e pepe", amount: 1, unit: "pizzico", calories: 0)],
            imageURL: "https://images.unsplash.com/photo-1606851094655-b3b484abd645?w=400&fit=crop",
            preparationSteps: ["Cuocere il bacon in padella fino a renderlo croccante", "Rimuovere il bacon e nella stessa padella aggiungere il burro", "Cuocere le uova al tegamino per 3 minuti", "Saltare velocemente gli spinaci nel grasso del bacon", "Servire tutto insieme nel piatto"]), dietTags: [.lowCarb, .ketogenic, .carnivore, .paleo]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Omelette al prosciutto e formaggio", calories: 460, protein: 34, carbs: 3, fat: 35, prepTime: 10, difficulty: .easy,
            ingredients: [Ingredient(name: "Uova", amount: 3, unit: "grandi", calories: 210), Ingredient(name: "Prosciutto cotto", amount: 60, unit: "g", calories: 80), Ingredient(name: "Formaggio Emmental", amount: 40, unit: "g", calories: 150), Ingredient(name: "Burro", amount: 8, unit: "g", calories: 58), Ingredient(name: "Prezzemolo", amount: 3, unit: "g", calories: 2)],
            imageURL: "https://images.unsplash.com/photo-1612240498936-65f5101365d2?w=400&fit=crop",
            preparationSteps: ["Sbattere le uova con sale e pepe", "Sciogliere il burro in padella antiaderente", "Versare le uova e cuocere a fuoco medio", "Quando quasi cotte, aggiungere prosciutto e formaggio su metà", "Piegare l'omelette a mezzaluna e servire"]), dietTags: [.lowCarb, .ketogenic, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Avocado ripieno con uovo", calories: 420, protein: 18, carbs: 12, fat: 34, prepTime: 20, difficulty: .medium,
            ingredients: [Ingredient(name: "Avocado", amount: 1, unit: "grande", calories: 240), Ingredient(name: "Uova", amount: 2, unit: "medie", calories: 140), Ingredient(name: "Pancetta", amount: 20, unit: "g", calories: 60), Ingredient(name: "Pepe nero", amount: 1, unit: "pizzico", calories: 0), Ingredient(name: "Erba cipollina", amount: 3, unit: "g", calories: 1)],
            imageURL: "https://images.unsplash.com/photo-1511994714008-b6d68a8b32a2?w=400&fit=crop",
            preparationSteps: ["Tagliare l'avocado a metà e rimuovere il nocciolo", "Allargare leggermente la cavità con un cucchiaio", "Rompere un uovo in ogni metà di avocado", "Aggiungere pancetta a pezzetti e pepe", "Cuocere in forno a 200°C per 15 minuti"]), dietTags: [.lowCarb, .ketogenic, .paleo]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Crepes proteiche con ricotta", calories: 400, protein: 30, carbs: 22, fat: 22, prepTime: 15, difficulty: .medium,
            ingredients: [Ingredient(name: "Albumi", amount: 4, unit: "grandi", calories: 68), Ingredient(name: "Ricotta", amount: 100, unit: "g", calories: 140), Ingredient(name: "Farina di cocco", amount: 20, unit: "g", calories: 80), Ingredient(name: "Burro", amount: 10, unit: "g", calories: 72), Ingredient(name: "Cannella", amount: 2, unit: "g", calories: 5)],
            imageURL: "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400&fit=crop",
            preparationSteps: ["Mescolare albumi e farina di cocco fino a ottenere un impasto liscio", "Scaldare una padella antiaderente con poco burro", "Versare un mestolo di impasto e cuocere 2 minuti per lato", "Farcire con ricotta e cannella", "Arrotolare e servire"]), dietTags: [.softLowCarb, .lowCarb, .balanced]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Hash di patate dolci con uova", calories: 450, protein: 22, carbs: 42, fat: 22, prepTime: 20, difficulty: .medium,
            ingredients: [Ingredient(name: "Patata dolce", amount: 200, unit: "g", calories: 172), Ingredient(name: "Uova", amount: 2, unit: "grandi", calories: 140), Ingredient(name: "Olio di cocco", amount: 15, unit: "ml", calories: 120), Ingredient(name: "Cipolla", amount: 40, unit: "g", calories: 16), Ingredient(name: "Rosmarino", amount: 3, unit: "g", calories: 4)],
            imageURL: "https://images.unsplash.com/photo-1768733992949-5412e330ef03?w=400&fit=crop",
            preparationSteps: ["Tagliare la patata dolce a cubetti piccoli", "Scaldare l'olio di cocco in padella e aggiungere patata dolce e cipolla", "Cuocere per 12-15 minuti mescolando spesso", "Creare 2 spazi e cuocere le uova nel hash", "Servire con rosmarino fresco"]), dietTags: [.paleo, .balanced]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Bowl di frutta con noci e cocco", calories: 380, protein: 8, carbs: 52, fat: 18, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Banana", amount: 1, unit: "media", calories: 95), Ingredient(name: "Mirtilli", amount: 80, unit: "g", calories: 40), Ingredient(name: "Fragole", amount: 80, unit: "g", calories: 26), Ingredient(name: "Noci", amount: 25, unit: "g", calories: 165), Ingredient(name: "Cocco grattugiato", amount: 15, unit: "g", calories: 52)],
            imageURL: "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&fit=crop",
            preparationSteps: ["Tagliare banana e fragole a pezzi", "Disporre tutta la frutta in una ciotola", "Aggiungere noci spezzettate e cocco grattugiato", "Mescolare delicatamente e servire"]), dietTags: [.paleo, .vegan, .vegetarian]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Bistecca e uova della mattina", calories: 520, protein: 42, carbs: 1, fat: 38, prepTime: 15, difficulty: .medium,
            ingredients: [Ingredient(name: "Bistecca di manzo", amount: 150, unit: "g", calories: 270), Ingredient(name: "Uova", amount: 2, unit: "grandi", calories: 140), Ingredient(name: "Burro", amount: 15, unit: "g", calories: 108), Ingredient(name: "Sale grosso", amount: 2, unit: "g", calories: 0)],
            imageURL: "https://images.unsplash.com/photo-1588168333986-5078d3ae3976?w=400&fit=crop",
            preparationSteps: ["Portare la bistecca a temperatura ambiente", "Scaldare la padella di ghisa ad alta temperatura", "Cuocere la bistecca 3 minuti per lato con burro", "Nella stessa padella cuocere le uova al tegamino", "Servire insieme con sale grosso"]), dietTags: [.carnivore, .ketogenic, .paleo]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Salsiccia con uova strapazzate", calories: 500, protein: 32, carbs: 2, fat: 40, prepTime: 12, difficulty: .easy,
            ingredients: [Ingredient(name: "Salsiccia", amount: 120, unit: "g", calories: 300), Ingredient(name: "Uova", amount: 3, unit: "grandi", calories: 210), Ingredient(name: "Burro", amount: 5, unit: "g", calories: 36), Ingredient(name: "Sale", amount: 1, unit: "pizzico", calories: 0)],
            imageURL: "https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=400&fit=crop",
            preparationSteps: ["Cuocere la salsiccia in padella sbriciolandola", "In un'altra padella sciogliere il burro", "Sbattere le uova e versarle in padella", "Mescolare delicatamente fino a cottura cremosa", "Servire salsiccia e uova insieme"]), dietTags: [.carnivore, .ketogenic, .lowCarb]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Toast con avocado e pomodori", calories: 380, protein: 10, carbs: 42, fat: 20, prepTime: 8, difficulty: .easy,
            ingredients: [Ingredient(name: "Pane integrale", amount: 2, unit: "fette", calories: 140), Ingredient(name: "Avocado", amount: 80, unit: "g", calories: 128), Ingredient(name: "Pomodorini", amount: 80, unit: "g", calories: 16), Ingredient(name: "Limone", amount: 10, unit: "ml", calories: 4), Ingredient(name: "Semi di lino", amount: 10, unit: "g", calories: 55)],
            imageURL: "https://images.unsplash.com/photo-1541519227354-08fa5d50c820?w=400&fit=crop",
            preparationSteps: ["Tostare il pane integrale", "Schiacciare l'avocado con limone e sale", "Spalmare l'avocado sul pane", "Tagliare i pomodorini a metà e disporre sopra", "Cospargere con semi di lino"]), dietTags: [.vegan, .vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Smoothie verde energizzante", calories: 350, protein: 12, carbs: 52, fat: 12, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Banana", amount: 1, unit: "grande", calories: 105), Ingredient(name: "Spinaci", amount: 60, unit: "g", calories: 14), Ingredient(name: "Latte di mandorla", amount: 250, unit: "ml", calories: 38), Ingredient(name: "Burro di mandorle", amount: 15, unit: "g", calories: 90), Ingredient(name: "Semi di chia", amount: 10, unit: "g", calories: 49)],
            imageURL: "https://images.unsplash.com/photo-1638176066666-ffb2f013c7dd?w=400&fit=crop",
            preparationSteps: ["Mettere tutti gli ingredienti nel frullatore", "Frullare per 60 secondi fino a ottenere un composto liscio", "Se troppo denso aggiungere altro latte di mandorla", "Versare nel bicchiere e servire subito"]), dietTags: [.vegan, .vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Porridge di avena con burro di arachidi", calories: 440, protein: 16, carbs: 56, fat: 18, prepTime: 10, difficulty: .easy,
            ingredients: [Ingredient(name: "Fiocchi d'avena", amount: 70, unit: "g", calories: 245), Ingredient(name: "Latte di soia", amount: 200, unit: "ml", calories: 54), Ingredient(name: "Burro di arachidi", amount: 20, unit: "g", calories: 118), Ingredient(name: "Banana", amount: 0.5, unit: "media", calories: 48), Ingredient(name: "Cannella", amount: 2, unit: "g", calories: 5)],
            imageURL: "https://images.unsplash.com/photo-1495214783159-3503fd1b572d?w=400&fit=crop",
            preparationSteps: ["Cuocere l'avena nel latte di soia per 5 minuti", "Versare nella ciotola", "Aggiungere un cucchiaio di burro di arachidi", "Decorare con fette di banana e cannella"]), dietTags: [.vegan, .vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Tofu strapazzato con verdure", calories: 360, protein: 22, carbs: 18, fat: 22, prepTime: 15, difficulty: .medium,
            ingredients: [Ingredient(name: "Tofu", amount: 200, unit: "g", calories: 160), Ingredient(name: "Peperone", amount: 80, unit: "g", calories: 25), Ingredient(name: "Pomodorini", amount: 60, unit: "g", calories: 12), Ingredient(name: "Cipolla", amount: 40, unit: "g", calories: 16), Ingredient(name: "Olio d'oliva", amount: 15, unit: "ml", calories: 120), Ingredient(name: "Curcuma", amount: 3, unit: "g", calories: 10)],
            imageURL: "https://images.unsplash.com/photo-1564834744159-ff0ea41ba4b9?w=400&fit=crop",
            preparationSteps: ["Sbricolare il tofu con una forchetta", "Soffriggere cipolla e peperone nell'olio d'oliva", "Aggiungere il tofu sbriciolato e la curcuma", "Aggiungere i pomodorini e cuocere per 5 minuti", "Servire caldo con pepe nero"]), dietTags: [.vegan, .vegetarian]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Frittata di zucchine e parmigiano", calories: 420, protein: 28, carbs: 8, fat: 32, prepTime: 15, difficulty: .easy,
            ingredients: [Ingredient(name: "Uova", amount: 3, unit: "grandi", calories: 210), Ingredient(name: "Zucchine", amount: 120, unit: "g", calories: 20), Ingredient(name: "Parmigiano grattugiato", amount: 30, unit: "g", calories: 118), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90), Ingredient(name: "Basilico", amount: 3, unit: "g", calories: 1)],
            imageURL: "https://images.unsplash.com/photo-1604909052868-10e24ddf8e85?w=400&fit=crop",
            preparationSteps: ["Tagliare le zucchine a rondelle sottili", "Sbattere le uova con parmigiano, sale e basilico", "Saltare le zucchine nell'olio d'oliva per 3 minuti", "Versare le uova e cuocere a fuoco medio-basso", "Girare con un piatto e completare la cottura"]), dietTags: [.vegetarian, .mediterranean, .lowCarb, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Crêpes con ricotta e frutti di bosco", calories: 420, protein: 20, carbs: 50, fat: 16, prepTime: 20, difficulty: .medium,
            ingredients: [Ingredient(name: "Farina", amount: 60, unit: "g", calories: 210), Ingredient(name: "Uova", amount: 2, unit: "medie", calories: 140), Ingredient(name: "Ricotta", amount: 80, unit: "g", calories: 112), Ingredient(name: "Frutti di bosco", amount: 80, unit: "g", calories: 40), Ingredient(name: "Latte", amount: 80, unit: "ml", calories: 40)],
            imageURL: "https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400&fit=crop",
            preparationSteps: ["Mescolare farina, uova e latte fino a ottenere una pastella liscia", "Scaldare una padella antiaderente e cuocere le crêpes sottili", "Farcire ogni crêpe con ricotta e frutti di bosco", "Piegare a triangolo e servire", "Decorare con frutti di bosco extra"]), dietTags: [.vegetarian, .balanced]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Muesli con yogurt e frutta fresca", calories: 400, protein: 18, carbs: 55, fat: 12, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Muesli integrale", amount: 60, unit: "g", calories: 210), Ingredient(name: "Yogurt greco", amount: 150, unit: "g", calories: 98), Ingredient(name: "Fragole", amount: 80, unit: "g", calories: 26), Ingredient(name: "Banana", amount: 0.5, unit: "media", calories: 48), Ingredient(name: "Miele", amount: 5, unit: "g", calories: 15)],
            imageURL: "https://images.unsplash.com/photo-1557637753-dbefc490200b?w=400&fit=crop",
            preparationSteps: ["Versare lo yogurt greco in una ciotola", "Aggiungere il muesli integrale", "Tagliare fragole e banana a pezzi", "Completare con frutta e un filo di miele"]), dietTags: [.balanced, .vegetarian, .mediterranean]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Pane tostato con uova e pomodoro", calories: 400, protein: 24, carbs: 36, fat: 18, prepTime: 10, difficulty: .easy,
            ingredients: [Ingredient(name: "Pane di segale", amount: 2, unit: "fette", calories: 160), Ingredient(name: "Uova", amount: 2, unit: "grandi", calories: 140), Ingredient(name: "Pomodoro fresco", amount: 100, unit: "g", calories: 20), Ingredient(name: "Olio d'oliva", amount: 10, unit: "ml", calories: 90), Ingredient(name: "Origano", amount: 2, unit: "g", calories: 5)],
            imageURL: "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&fit=crop",
            preparationSteps: ["Tostare le fette di pane", "Cuocere le uova in camicia o al tegamino", "Affettare il pomodoro e condirlo con olio e origano", "Comporre il piatto con pane, uova e pomodoro"]), dietTags: [.balanced, .mediterranean, .vegetarian]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Overnight oats al cioccolato", calories: 430, protein: 16, carbs: 58, fat: 16, prepTime: 5, difficulty: .easy,
            ingredients: [Ingredient(name: "Fiocchi d'avena", amount: 70, unit: "g", calories: 245), Ingredient(name: "Latte di mandorla", amount: 150, unit: "ml", calories: 23), Ingredient(name: "Cacao amaro", amount: 10, unit: "g", calories: 25), Ingredient(name: "Banana", amount: 1, unit: "piccola", calories: 72), Ingredient(name: "Nocciole", amount: 15, unit: "g", calories: 95)],
            imageURL: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&fit=crop",
            preparationSteps: ["Mescolare avena, latte di mandorla e cacao in un barattolo", "Aggiungere banana schiacciata e mescolare", "Chiudere e riporre in frigo per la notte", "La mattina aggiungere nocciole tritate", "Mangiare freddo o scaldato nel microonde"]), dietTags: [.balanced, .vegetarian, .vegan]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Uova alla Benedict light", calories: 460, protein: 28, carbs: 30, fat: 26, prepTime: 20, difficulty: .hard,
            ingredients: [Ingredient(name: "Muffin inglese integrale", amount: 1, unit: "pezzo", calories: 130), Ingredient(name: "Uova", amount: 2, unit: "grandi", calories: 140), Ingredient(name: "Prosciutto cotto", amount: 40, unit: "g", calories: 52), Ingredient(name: "Yogurt greco", amount: 40, unit: "g", calories: 26), Ingredient(name: "Senape di Digione", amount: 5, unit: "g", calories: 5), Ingredient(name: "Limone", amount: 10, unit: "ml", calories: 4)],
            imageURL: "https://images.unsplash.com/photo-1608039829572-9b8d0af36c1c?w=400&fit=crop",
            preparationSteps: ["Preparare la salsa mescolando yogurt greco, senape e limone", "Portare l'acqua a leggero bollore e cuocere le uova in camicia", "Tostare il muffin inglese e adagiare il prosciutto", "Posizionare le uova in camicia sopra il prosciutto", "Nappare con la salsa yogurt e servire"]), dietTags: [.balanced, .softLowCarb]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Açai bowl con granola", calories: 420, protein: 10, carbs: 62, fat: 16, prepTime: 10, difficulty: .easy,
            ingredients: [Ingredient(name: "Polpa di açai", amount: 100, unit: "g", calories: 80), Ingredient(name: "Banana congelata", amount: 1, unit: "media", calories: 95), Ingredient(name: "Granola", amount: 40, unit: "g", calories: 160), Ingredient(name: "Mirtilli", amount: 50, unit: "g", calories: 25), Ingredient(name: "Cocco grattugiato", amount: 15, unit: "g", calories: 52)],
            imageURL: "https://images.unsplash.com/photo-1626074353765-517a681e40be?w=400&fit=crop",
            preparationSteps: ["Frullare polpa di açai e banana congelata", "Versare nella ciotola con consistenza molto densa", "Decorare con granola, mirtilli e cocco", "Servire immediatamente"]), dietTags: [.balanced, .vegetarian, .vegan]),

        CatalogMeal(meal: Meal(type: .breakfast, name: "Piadina con prosciutto e rucola", calories: 430, protein: 24, carbs: 38, fat: 20, prepTime: 8, difficulty: .easy,
            ingredients: [Ingredient(name: "Piadina integrale", amount: 1, unit: "pezzo", calories: 220), Ingredient(name: "Prosciutto crudo", amount: 50, unit: "g", calories: 100), Ingredient(name: "Rucola", amount: 30, unit: "g", calories: 8), Ingredient(name: "Pomodoro", amount: 60, unit: "g", calories: 12), Ingredient(name: "Squacquerone", amount: 30, unit: "g", calories: 60)],
            imageURL: "https://images.unsplash.com/photo-1600628421055-4d30de868b8f?w=400&fit=crop",
            preparationSteps: ["Scaldare la piadina in padella per 1 minuto per lato", "Spalmare lo squacquerone su metà piadina", "Aggiungere prosciutto crudo, rucola e pomodoro", "Chiudere a mezzaluna e servire"]), dietTags: [.balanced, .mediterranean]),
    ]
}
