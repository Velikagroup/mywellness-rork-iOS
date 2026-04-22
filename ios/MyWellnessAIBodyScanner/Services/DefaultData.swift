import Foundation

enum DefaultData {
    static func nutritionPlan(for profile: UserProfile) -> NutritionPlan {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let dayPlans = days.enumerated().map { index, day in
            DayPlan(
                dayName: day,
                meals: mealsForDay(index: index, diet: profile.dietType, target: Int(profile.dailyCalorieTarget))
            )
        }
        return NutritionPlan(days: dayPlans)
    }

    static func workoutPlan(for profile: UserProfile) -> WorkoutPlan {
        let days: [WorkoutDay]
        switch profile.goal {
        case .loseWeight:
            days = fatLossWorkout()
        case .gainMuscle:
            days = muscleGainWorkout()
        case .maintain:
            days = maintenanceWorkout()
        }
        return WorkoutPlan(days: days)
    }

    static func defaultWeightHistory(for profile: UserProfile) -> [WeightEntry] {
        let calendar = Calendar.current
        var entries: [WeightEntry] = []
        let weeks = 3
        for i in 0..<(weeks * 3 + 1) {
            let daysAgo = (weeks * 7) - (i * Int(Double(weeks * 7) / Double(weeks * 3)))
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) else { continue }
            let progress = Double(i) / Double(weeks * 3)
            let weightLoss = (profile.currentWeightKg - profile.targetWeightKg) * 0.15 * progress
            let noise = Double.random(in: -0.3...0.3)
            entries.append(WeightEntry(date: date, weightKg: profile.currentWeightKg - weightLoss + noise))
        }
        entries.append(WeightEntry(date: Date(), weightKg: profile.currentWeightKg))
        return entries.sorted { $0.date < $1.date }
    }

    private static func mealsForDay(index: Int, diet: UserProfile.DietType, target: Int) -> [Meal] {
        switch diet {
        case .mediterranean:
            return mediterraneanMeals[index % mediterraneanMeals.count]
        case .ketogenic, .lowCarb, .softLowCarb, .carnivore, .paleo:
            return ketoMeals[index % ketoMeals.count]
        case .vegetarian, .vegan:
            return vegetarianMeals[index % vegetarianMeals.count]
        case .standard, .none:
            return standardMeals[index % standardMeals.count]
        }
    }

    static let mediterraneanMeals: [[Meal]] = [
        // Monday
        [
            Meal(type: .breakfast, name: "Tostada de aguacate con salmón ahumado",
                 calories: 512, protein: 24.4, carbs: 35, fat: 34.1, prepTime: 15, difficulty: .easy,
                 ingredients: [
                    Ingredient(name: "Pan integral", amount: 2, unit: "rebanadas", calories: 140),
                    Ingredient(name: "Aguacate", amount: 1, unit: "mediano", calories: 240),
                    Ingredient(name: "Salmón ahumado", amount: 80, unit: "g", calories: 104),
                    Ingredient(name: "Queso feta", amount: 30, unit: "g", calories: 80),
                    Ingredient(name: "Tomates cherry", amount: 6, unit: "unidades", calories: 18),
                    Ingredient(name: "Zumo de limón", amount: 15, unit: "ml", calories: 4)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?w=400&fit=crop"),
            Meal(type: .lunch, name: "Ensalada Niçoise de atún",
                 calories: 683, protein: 42, carbs: 41, fat: 40, prepTime: 20, difficulty: .easy,
                 ingredients: [
                    Ingredient(name: "Atún en conserva", amount: 160, unit: "g", calories: 160),
                    Ingredient(name: "Mezcla de lechugas", amount: 100, unit: "g", calories: 25),
                    Ingredient(name: "Judías verdes", amount: 80, unit: "g", calories: 20),
                    Ingredient(name: "Aceitunas Kalamata", amount: 30, unit: "g", calories: 45),
                    Ingredient(name: "Huevo cocido", amount: 2, unit: "huevos", calories: 150),
                    Ingredient(name: "Aceite de oliva", amount: 20, unit: "ml", calories: 180),
                    Ingredient(name: "Pan integral", amount: 1, unit: "rebanada", calories: 70)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&fit=crop"),
            Meal(type: .dinner, name: "Pollo al horno con garbanzos",
                 calories: 512, protein: 35, carbs: 46, fat: 23, prepTime: 35, difficulty: .medium,
                 ingredients: [
                    Ingredient(name: "Pechuga de pollo", amount: 200, unit: "g", calories: 240),
                    Ingredient(name: "Garbanzos", amount: 120, unit: "g", calories: 180),
                    Ingredient(name: "Tomates cherry", amount: 100, unit: "g", calories: 30),
                    Ingredient(name: "Espinacas", amount: 80, unit: "g", calories: 20),
                    Ingredient(name: "Ajo", amount: 3, unit: "dientes", calories: 12),
                    Ingredient(name: "Aceite de oliva", amount: 15, unit: "ml", calories: 135),
                    Ingredient(name: "Mezcla de hierbas", amount: 5, unit: "g", calories: 5)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1598103442097-8b74394b95c3?w=400&fit=crop")
        ],
        // Tuesday
        [
            Meal(type: .breakfast, name: "Bowl de yogur griego con frutos rojos y miel",
                 calories: 380, protein: 22, carbs: 45, fat: 12, prepTime: 5, difficulty: .easy,
                 ingredients: [
                    Ingredient(name: "Yogur griego", amount: 200, unit: "g", calories: 120),
                    Ingredient(name: "Frutos rojos", amount: 100, unit: "g", calories: 50),
                    Ingredient(name: "Miel", amount: 20, unit: "g", calories: 60),
                    Ingredient(name: "Granola", amount: 40, unit: "g", calories: 150)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=400&fit=crop"),
            Meal(type: .lunch, name: "Bowl de quinoa mediterráneo",
                 calories: 580, protein: 22, carbs: 68, fat: 22, prepTime: 25, difficulty: .easy,
                 ingredients: [
                    Ingredient(name: "Quinoa", amount: 80, unit: "g", calories: 280),
                    Ingredient(name: "Verduras asadas", amount: 150, unit: "g", calories: 90),
                    Ingredient(name: "Queso feta", amount: 40, unit: "g", calories: 100),
                    Ingredient(name: "Hummus", amount: 60, unit: "g", calories: 120),
                    Ingredient(name: "Aceite de oliva", amount: 10, unit: "ml", calories: 90)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&fit=crop"),
            Meal(type: .dinner, name: "Salmón al horno con verduras asadas",
                 calories: 520, protein: 40, carbs: 28, fat: 28, prepTime: 30, difficulty: .medium,
                 ingredients: [
                    Ingredient(name: "Salmon fillet", amount: 200, unit: "g", calories: 290),
                    Ingredient(name: "Zucchini", amount: 100, unit: "g", calories: 20),
                    Ingredient(name: "Bell pepper", amount: 80, unit: "g", calories: 25),
                    Ingredient(name: "Cherry tomatoes", amount: 80, unit: "g", calories: 25),
                    Ingredient(name: "Olive oil", amount: 15, unit: "ml", calories: 135),
                    Ingredient(name: "Lemon", amount: 0.5, unit: "piece", calories: 10),
                    Ingredient(name: "Fresh dill", amount: 5, unit: "g", calories: 5)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&fit=crop")
        ],
        // Wednesday
        [
            Meal(type: .breakfast, name: "Shakshuka with Whole Grain Toast",
                 calories: 450, protein: 26, carbs: 42, fat: 22, prepTime: 20, difficulty: .medium,
                 ingredients: [
                    Ingredient(name: "Eggs", amount: 3, unit: "large", calories: 210),
                    Ingredient(name: "Crushed tomatoes", amount: 200, unit: "g", calories: 50),
                    Ingredient(name: "Bell pepper", amount: 80, unit: "g", calories: 25),
                    Ingredient(name: "Onion", amount: 60, unit: "g", calories: 25),
                    Ingredient(name: "Whole grain toast", amount: 1, unit: "slice", calories: 80),
                    Ingredient(name: "Olive oil", amount: 10, unit: "ml", calories: 90)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&fit=crop"),
            Meal(type: .lunch, name: "Greek Chicken Wrap",
                 calories: 620, protein: 38, carbs: 52, fat: 26, prepTime: 15, difficulty: .easy,
                 ingredients: [
                    Ingredient(name: "Grilled chicken", amount: 180, unit: "g", calories: 216),
                    Ingredient(name: "Whole wheat wrap", amount: 1, unit: "large", calories: 120),
                    Ingredient(name: "Tzatziki", amount: 60, unit: "g", calories: 55),
                    Ingredient(name: "Romaine lettuce", amount: 50, unit: "g", calories: 10),
                    Ingredient(name: "Tomato", amount: 80, unit: "g", calories: 15),
                    Ingredient(name: "Cucumber", amount: 60, unit: "g", calories: 10),
                    Ingredient(name: "Feta", amount: 30, unit: "g", calories: 75)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400&fit=crop"),
            Meal(type: .dinner, name: "Mediterranean Sea Bass with Herbs",
                 calories: 480, protein: 38, carbs: 22, fat: 28, prepTime: 30, difficulty: .medium,
                 ingredients: [
                    Ingredient(name: "Sea bass", amount: 200, unit: "g", calories: 200),
                    Ingredient(name: "Cherry tomatoes", amount: 100, unit: "g", calories: 20),
                    Ingredient(name: "Kalamata olives", amount: 40, unit: "g", calories: 60),
                    Ingredient(name: "Capers", amount: 20, unit: "g", calories: 5),
                    Ingredient(name: "Olive oil", amount: 20, unit: "ml", calories: 180),
                    Ingredient(name: "Fresh herbs", amount: 10, unit: "g", calories: 5)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400&fit=crop")
        ],
        // Thursday
        [
            Meal(type: .breakfast, name: "Mediterranean Egg White Omelette",
                 calories: 390, protein: 30, carbs: 20, fat: 20, prepTime: 15, difficulty: .easy,
                 ingredients: [
                    Ingredient(name: "Egg whites", amount: 6, unit: "whites", calories: 100),
                    Ingredient(name: "Spinach", amount: 80, unit: "g", calories: 20),
                    Ingredient(name: "Sun-dried tomatoes", amount: 30, unit: "g", calories: 80),
                    Ingredient(name: "Feta cheese", amount: 40, unit: "g", calories: 100),
                    Ingredient(name: "Olive oil", amount: 10, unit: "ml", calories: 90)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400&fit=crop"),
            Meal(type: .lunch, name: "Lentil and Vegetable Mediterranean Soup",
                 calories: 520, protein: 28, carbs: 72, fat: 14, prepTime: 40, difficulty: .medium,
                 ingredients: [
                    Ingredient(name: "Red lentils", amount: 100, unit: "g", calories: 280),
                    Ingredient(name: "Carrots", amount: 100, unit: "g", calories: 40),
                    Ingredient(name: "Celery", amount: 80, unit: "g", calories: 15),
                    Ingredient(name: "Onion", amount: 80, unit: "g", calories: 30),
                    Ingredient(name: "Crushed tomatoes", amount: 150, unit: "g", calories: 40),
                    Ingredient(name: "Olive oil", amount: 15, unit: "ml", calories: 135)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&fit=crop"),
            Meal(type: .dinner, name: "Grilled Lamb with Tabbouleh",
                 calories: 680, protein: 45, carbs: 48, fat: 30, prepTime: 40, difficulty: .hard,
                 ingredients: [
                    Ingredient(name: "Lamb chops", amount: 200, unit: "g", calories: 340),
                    Ingredient(name: "Bulgur wheat", amount: 80, unit: "g", calories: 240),
                    Ingredient(name: "Parsley", amount: 40, unit: "g", calories: 15),
                    Ingredient(name: "Mint", amount: 15, unit: "g", calories: 5),
                    Ingredient(name: "Lemon juice", amount: 30, unit: "ml", calories: 10),
                    Ingredient(name: "Olive oil", amount: 15, unit: "ml", calories: 135)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1544025162-d76694265947?w=400&fit=crop")
        ],
        // Friday
        [
            Meal(type: .breakfast, name: "Overnight Oats with Nuts & Seeds",
                 calories: 425, protein: 18, carbs: 55, fat: 16, prepTime: 5, difficulty: .easy,
                 ingredients: [
                    Ingredient(name: "Rolled oats", amount: 80, unit: "g", calories: 290),
                    Ingredient(name: "Almond milk", amount: 150, unit: "ml", calories: 25),
                    Ingredient(name: "Chia seeds", amount: 15, unit: "g", calories: 70),
                    Ingredient(name: "Walnuts", amount: 20, unit: "g", calories: 130),
                    Ingredient(name: "Banana", amount: 0.5, unit: "medium", calories: 50)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1484723091739-30anf65bccc0?w=400&fit=crop"),
            Meal(type: .lunch, name: "Falafel Bowl with Hummus",
                 calories: 650, protein: 25, carbs: 78, fat: 28, prepTime: 10, difficulty: .easy,
                 ingredients: [
                    Ingredient(name: "Falafel", amount: 150, unit: "g", calories: 330),
                    Ingredient(name: "Hummus", amount: 80, unit: "g", calories: 160),
                    Ingredient(name: "Brown rice", amount: 80, unit: "g", calories: 104),
                    Ingredient(name: "Tabbouleh", amount: 80, unit: "g", calories: 60),
                    Ingredient(name: "Pita bread", amount: 0.5, unit: "piece", calories: 80)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1559847844-5315695dadae?w=400&fit=crop"),
            Meal(type: .dinner, name: "Grilled Shrimp with Orzo",
                 calories: 520, protein: 38, carbs: 52, fat: 16, prepTime: 25, difficulty: .medium,
                 ingredients: [
                    Ingredient(name: "Shrimp", amount: 200, unit: "g", calories: 200),
                    Ingredient(name: "Orzo pasta", amount: 80, unit: "g", calories: 280),
                    Ingredient(name: "Spinach", amount: 80, unit: "g", calories: 20),
                    Ingredient(name: "Cherry tomatoes", amount: 100, unit: "g", calories: 30),
                    Ingredient(name: "Garlic", amount: 4, unit: "cloves", calories: 16),
                    Ingredient(name: "Olive oil", amount: 10, unit: "ml", calories: 90),
                    Ingredient(name: "Lemon", amount: 1, unit: "medium", calories: 20)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400&fit=crop")
        ],
        // Saturday
        [
            Meal(type: .breakfast, name: "Smashed Avocado & Poached Eggs",
                 calories: 480, protein: 22, carbs: 32, fat: 32, prepTime: 20, difficulty: .medium,
                 ingredients: [
                    Ingredient(name: "Avocado", amount: 1, unit: "large", calories: 280),
                    Ingredient(name: "Eggs", amount: 2, unit: "large", calories: 140),
                    Ingredient(name: "Sourdough bread", amount: 2, unit: "slices", calories: 180),
                    Ingredient(name: "Chili flakes", amount: 2, unit: "g", calories: 5),
                    Ingredient(name: "Lemon juice", amount: 15, unit: "ml", calories: 4)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1541519227354-08fa5d50c820?w=400&fit=crop"),
            Meal(type: .lunch, name: "Mediterranean Pita Pizza",
                 calories: 580, protein: 26, carbs: 68, fat: 22, prepTime: 20, difficulty: .easy,
                 ingredients: [
                    Ingredient(name: "Whole wheat pita", amount: 2, unit: "pieces", calories: 280),
                    Ingredient(name: "Tomato sauce", amount: 80, unit: "g", calories: 30),
                    Ingredient(name: "Feta cheese", amount: 60, unit: "g", calories: 150),
                    Ingredient(name: "Kalamata olives", amount: 40, unit: "g", calories: 60),
                    Ingredient(name: "Bell peppers", amount: 80, unit: "g", calories: 25),
                    Ingredient(name: "Fresh basil", amount: 10, unit: "g", calories: 5)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&fit=crop"),
            Meal(type: .dinner, name: "Stuffed Bell Peppers with Rice",
                 calories: 620, protein: 32, carbs: 65, fat: 24, prepTime: 50, difficulty: .hard,
                 ingredients: [
                    Ingredient(name: "Bell peppers", amount: 3, unit: "large", calories: 90),
                    Ingredient(name: "Brown rice", amount: 100, unit: "g", calories: 130),
                    Ingredient(name: "Ground turkey", amount: 150, unit: "g", calories: 210),
                    Ingredient(name: "Crushed tomatoes", amount: 100, unit: "g", calories: 30),
                    Ingredient(name: "Feta cheese", amount: 40, unit: "g", calories: 100),
                    Ingredient(name: "Herbs", amount: 5, unit: "g", calories: 5)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&fit=crop")
        ],
        // Sunday
        [
            Meal(type: .breakfast, name: "Mediterranean Pancakes with Berries",
                 calories: 420, protein: 16, carbs: 58, fat: 14, prepTime: 25, difficulty: .medium,
                 ingredients: [
                    Ingredient(name: "Whole grain flour", amount: 80, unit: "g", calories: 280),
                    Ingredient(name: "Eggs", amount: 2, unit: "large", calories: 140),
                    Ingredient(name: "Greek yogurt", amount: 100, unit: "g", calories: 59),
                    Ingredient(name: "Mixed berries", amount: 100, unit: "g", calories: 55),
                    Ingredient(name: "Honey", amount: 15, unit: "g", calories: 45)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=400&fit=crop"),
            Meal(type: .lunch, name: "Mediterranean Mezze Platter",
                 calories: 650, protein: 22, carbs: 60, fat: 38, prepTime: 15, difficulty: .easy,
                 ingredients: [
                    Ingredient(name: "Hummus", amount: 100, unit: "g", calories: 200),
                    Ingredient(name: "Pita bread", amount: 2, unit: "pieces", calories: 280),
                    Ingredient(name: "Tzatziki", amount: 80, unit: "g", calories: 75),
                    Ingredient(name: "Kalamata olives", amount: 40, unit: "g", calories: 60),
                    Ingredient(name: "Feta cheese", amount: 40, unit: "g", calories: 100),
                    Ingredient(name: "Cucumber & carrots", amount: 100, unit: "g", calories: 20)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400&fit=crop"),
            Meal(type: .dinner, name: "Slow-Roasted Mediterranean Lamb",
                 calories: 720, protein: 50, carbs: 35, fat: 42, prepTime: 120, difficulty: .hard,
                 ingredients: [
                    Ingredient(name: "Lamb shoulder", amount: 250, unit: "g", calories: 480),
                    Ingredient(name: "Potatoes", amount: 150, unit: "g", calories: 130),
                    Ingredient(name: "Garlic", amount: 6, unit: "cloves", calories: 24),
                    Ingredient(name: "Rosemary", amount: 5, unit: "g", calories: 5),
                    Ingredient(name: "Olive oil", amount: 20, unit: "ml", calories: 180),
                    Ingredient(name: "Lemon", amount: 1, unit: "large", calories: 30)
                 ],
                 imageURL: "https://images.unsplash.com/photo-1544025162-d76694265947?w=400&fit=crop")
        ]
    ]

    static let ketoMeals: [[Meal]] = [
        [
            Meal(type: .breakfast, name: "Bacon & Egg Scramble", calories: 450, protein: 30, carbs: 2, fat: 36, prepTime: 10, difficulty: .easy, ingredients: [
                Ingredient(name: "Eggs", amount: 3, unit: "large", calories: 210),
                Ingredient(name: "Bacon", amount: 60, unit: "g", calories: 200),
                Ingredient(name: "Butter", amount: 10, unit: "g", calories: 72),
                Ingredient(name: "Spinach", amount: 30, unit: "g", calories: 7)
            ], imageURL: "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&fit=crop"),
            Meal(type: .lunch, name: "Avocado Tuna Salad", calories: 580, protein: 38, carbs: 8, fat: 42, prepTime: 10, difficulty: .easy, ingredients: [
                Ingredient(name: "Tuna", amount: 160, unit: "g", calories: 160),
                Ingredient(name: "Avocado", amount: 1, unit: "large", calories: 280),
                Ingredient(name: "Mayo", amount: 30, unit: "g", calories: 200),
                Ingredient(name: "Celery", amount: 40, unit: "g", calories: 8)
            ], imageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&fit=crop"),
            Meal(type: .dinner, name: "Pan-Seared Salmon with Asparagus", calories: 580, protein: 44, carbs: 10, fat: 40, prepTime: 25, difficulty: .medium, ingredients: [
                Ingredient(name: "Salmon fillet", amount: 220, unit: "g", calories: 320),
                Ingredient(name: "Asparagus", amount: 150, unit: "g", calories: 40),
                Ingredient(name: "Butter", amount: 20, unit: "g", calories: 144),
                Ingredient(name: "Garlic", amount: 2, unit: "cloves", calories: 8),
                Ingredient(name: "Lemon", amount: 0.5, unit: "piece", calories: 10)
            ], imageURL: "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&fit=crop")
        ]
    ]

    static let vegetarianMeals: [[Meal]] = [
        [
            Meal(type: .breakfast, name: "Chia Pudding with Mango", calories: 380, protein: 14, carbs: 52, fat: 16, prepTime: 5, difficulty: .easy, ingredients: [
                Ingredient(name: "Chia seeds", amount: 40, unit: "g", calories: 185),
                Ingredient(name: "Coconut milk", amount: 200, unit: "ml", calories: 120),
                Ingredient(name: "Mango", amount: 100, unit: "g", calories: 60),
                Ingredient(name: "Maple syrup", amount: 15, unit: "ml", calories: 50)
            ], imageURL: "https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=400&fit=crop"),
            Meal(type: .lunch, name: "Lentil Buddha Bowl", calories: 580, protein: 28, carbs: 72, fat: 18, prepTime: 30, difficulty: .medium, ingredients: [
                Ingredient(name: "Green lentils", amount: 120, unit: "g", calories: 300),
                Ingredient(name: "Brown rice", amount: 80, unit: "g", calories: 105),
                Ingredient(name: "Roasted chickpeas", amount: 60, unit: "g", calories: 120),
                Ingredient(name: "Tahini sauce", amount: 30, unit: "g", calories: 170)
            ], imageURL: "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&fit=crop"),
            Meal(type: .dinner, name: "Vegetable Curry with Quinoa", calories: 540, protein: 20, carbs: 70, fat: 20, prepTime: 35, difficulty: .medium, ingredients: [
                Ingredient(name: "Mixed vegetables", amount: 250, unit: "g", calories: 100),
                Ingredient(name: "Chickpeas", amount: 100, unit: "g", calories: 150),
                Ingredient(name: "Coconut milk", amount: 150, unit: "ml", calories: 90),
                Ingredient(name: "Quinoa", amount: 80, unit: "g", calories: 280)
            ], imageURL: "https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&fit=crop")
        ]
    ]

    static let standardMeals: [[Meal]] = [
        [
            Meal(type: .breakfast, name: "Huevos revueltos con tostada integral", calories: 420, protein: 28, carbs: 38, fat: 18, prepTime: 10, difficulty: .easy, ingredients: [
                Ingredient(name: "Eggs", amount: 3, unit: "large", calories: 210),
                Ingredient(name: "Whole grain toast", amount: 2, unit: "slices", calories: 160),
                Ingredient(name: "Butter", amount: 10, unit: "g", calories: 72),
                Ingredient(name: "Milk", amount: 30, unit: "ml", calories: 18)
            ], imageURL: "https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400&fit=crop"),
            Meal(type: .lunch, name: "Ensalada César de pollo a la plancha", calories: 560, protein: 45, carbs: 28, fat: 30, prepTime: 20, difficulty: .easy, ingredients: [
                Ingredient(name: "Chicken breast", amount: 200, unit: "g", calories: 240),
                Ingredient(name: "Romaine lettuce", amount: 150, unit: "g", calories: 25),
                Ingredient(name: "Caesar dressing", amount: 40, unit: "g", calories: 160),
                Ingredient(name: "Parmesan", amount: 20, unit: "g", calories: 80),
                Ingredient(name: "Croutons", amount: 30, unit: "g", calories: 120)
            ], imageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&fit=crop"),
            Meal(type: .dinner, name: "Bacalao al horno con puré de boniato", calories: 520, protein: 42, carbs: 55, fat: 14, prepTime: 35, difficulty: .medium, ingredients: [
                Ingredient(name: "Cod fillet", amount: 220, unit: "g", calories: 190),
                Ingredient(name: "Sweet potato", amount: 200, unit: "g", calories: 180),
                Ingredient(name: "Butter", amount: 15, unit: "g", calories: 108),
                Ingredient(name: "Steamed broccoli", amount: 120, unit: "g", calories: 40)
            ], imageURL: "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400&fit=crop")
        ]
    ]

    private static func fatLossWorkout() -> [WorkoutDay] {
        [
            WorkoutDay(dayName: "Monday", focus: "Full Body HIIT", durationMinutes: 45, exercises: [
                Exercise(name: "High Knees", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["cardio"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Arm Circles", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["shoulders"], category: .warmup, durationMinutes: 3),
                Exercise(name: "Jumping Jacks", sets: 3, reps: "30 seconds", restSeconds: 15, muscleGroups: ["cardio", "full body"], category: .main, difficulty: "Beginner", exerciseDescription: "A full body cardio exercise. Stand with feet together and arms at your sides, then jump while spreading your legs and raising your arms overhead.", formTips: ["Land softly on the balls of your feet", "Keep your core engaged throughout"], loadTips: ["Start with a moderate pace", "Increase speed as you warm up"]),
                Exercise(name: "Burpees", sets: 3, reps: "10", restSeconds: 30, muscleGroups: ["full body", "core"], category: .main, difficulty: "Advanced", exerciseDescription: "A high-intensity full body exercise combining a squat, push-up, and jump.", formTips: ["Keep your back flat during the push-up", "Explode upward on the jump"], loadTips: ["Slow down if form breaks", "RPE 8-9"]),
                Exercise(name: "Mountain Climbers", sets: 3, reps: "20", restSeconds: 20, muscleGroups: ["core", "shoulders", "cardio"], category: .main, difficulty: "Intermediate", exerciseDescription: "A dynamic plank exercise that targets the core while providing cardio benefits.", formTips: ["Keep hips level, don't pike up", "Drive knees toward chest quickly"], loadTips: ["Maintain steady rhythm", "RPE 7-8"]),
                Exercise(name: "Squat Jumps", sets: 3, reps: "15", restSeconds: 30, muscleGroups: ["quadriceps", "glutes", "cardio"], category: .main, difficulty: "Intermediate", exerciseDescription: "An explosive lower body exercise that builds power and burns calories.", formTips: ["Land softly with knees slightly bent", "Push through your heels"], loadTips: ["Add depth for more intensity", "RPE 7-8"]),
                Exercise(name: "Push-Ups", sets: 3, reps: "12", restSeconds: 30, muscleGroups: ["chest", "triceps", "core"], category: .main, difficulty: "Intermediate", exerciseDescription: "A classic upper body exercise targeting chest, shoulders, and triceps.", formTips: ["Keep body in a straight line", "Lower chest to near the floor"], loadTips: ["Modify on knees if needed", "RPE 7"]),
                Exercise(name: "Stretching", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["full body"], category: .cooldown, durationMinutes: 5),
                Exercise(name: "Deep Breathing", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["recovery"], category: .cooldown, durationMinutes: 3)
            ], caloriesBurned: 380),
            WorkoutDay(dayName: "Tuesday", focus: "Upper Body Strength", durationMinutes: 40, exercises: [
                Exercise(name: "Arm Circles", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["shoulders"], category: .warmup, durationMinutes: 3),
                Exercise(name: "Band Pull-Aparts", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["back", "shoulders"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Push-Ups", sets: 4, reps: "15", restSeconds: 60, muscleGroups: ["chest", "triceps"], category: .main, difficulty: "Intermediate", exerciseDescription: "Classic push-up for chest and tricep development.", formTips: ["Keep elbows at 45 degrees", "Full range of motion"], loadTips: ["Add weight vest for progression", "RPE 7"]),
                Exercise(name: "Dumbbell Rows", sets: 4, reps: "12", restSeconds: 60, muscleGroups: ["back", "biceps"], category: .main, difficulty: "Intermediate", exerciseDescription: "A pulling exercise targeting the lats and upper back.", formTips: ["Pull elbow back, squeeze shoulder blade", "Keep back flat"], loadTips: ["Choose a weight that challenges last 2 reps", "RPE 7-8"]),
                Exercise(name: "Shoulder Press", sets: 3, reps: "12", restSeconds: 60, muscleGroups: ["shoulders", "triceps"], category: .main, difficulty: "Intermediate", exerciseDescription: "Overhead pressing movement for shoulder development.", formTips: ["Don't arch your lower back", "Press straight overhead"], loadTips: ["Start light, increase gradually", "RPE 7"]),
                Exercise(name: "Bicep Curls", sets: 3, reps: "15", restSeconds: 45, muscleGroups: ["biceps"], category: .main, difficulty: "Beginner", exerciseDescription: "Isolation exercise for bicep development.", formTips: ["Keep elbows pinned to sides", "Control the negative"], loadTips: ["Don't swing the weight", "RPE 7"]),
                Exercise(name: "Tricep Dips", sets: 3, reps: "12", restSeconds: 45, muscleGroups: ["triceps", "chest"], category: .main, difficulty: "Intermediate", exerciseDescription: "Bodyweight exercise targeting the triceps.", formTips: ["Don't go too deep to protect shoulders", "Keep chest up"], loadTips: ["Add weight if bodyweight is easy", "RPE 7-8"]),
                Exercise(name: "Child's Pose", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["back", "shoulders"], category: .cooldown, durationMinutes: 3),
                Exercise(name: "Shoulder Stretch", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["shoulders"], category: .cooldown, durationMinutes: 3)
            ], caloriesBurned: 280),
            WorkoutDay(dayName: "Wednesday", focus: "Active Recovery", durationMinutes: 30, exercises: [
                Exercise(name: "Light Walking", sets: 1, reps: "20 min", restSeconds: 0, muscleGroups: ["full body"], category: .main, difficulty: "Beginner", durationMinutes: 20),
                Exercise(name: "Yoga Stretching", sets: 1, reps: "10 min", restSeconds: 0, muscleGroups: ["full body"], category: .main, difficulty: "Beginner", durationMinutes: 10)
            ], isRestDay: true, caloriesBurned: 150),
            WorkoutDay(dayName: "Thursday", focus: "Lower Body Strength", durationMinutes: 45, exercises: [
                Exercise(name: "Leg Swings", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["hip flexors"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Bodyweight Squats", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["legs"], category: .warmup, durationMinutes: 3),
                Exercise(name: "Squats", sets: 4, reps: "15", restSeconds: 60, muscleGroups: ["quadriceps", "glutes"], category: .main, difficulty: "Intermediate", exerciseDescription: "The king of leg exercises. Targets quads, glutes, and core.", formTips: ["Keep knees tracking over toes", "Squat to at least parallel"], loadTips: ["Use a weight that challenges the last 3 reps", "RPE 7-8"]),
                Exercise(name: "Lunges", sets: 3, reps: "12 each", restSeconds: 60, muscleGroups: ["legs", "glutes"], category: .main, difficulty: "Intermediate", exerciseDescription: "Unilateral leg exercise for balance and strength.", formTips: ["Keep front knee behind toes", "Step far enough forward"], loadTips: ["Hold dumbbells for added resistance", "RPE 7"]),
                Exercise(name: "Romanian Deadlift", sets: 4, reps: "12", restSeconds: 60, muscleGroups: ["hamstrings", "glutes"], category: .main, difficulty: "Advanced", exerciseDescription: "Hip hinge movement targeting the posterior chain.", formTips: ["Keep the bar close to your legs", "Hinge at hips, slight knee bend"], loadTips: ["Feel a stretch in hamstrings at bottom", "RPE 7-8"]),
                Exercise(name: "Calf Raises", sets: 3, reps: "20", restSeconds: 45, muscleGroups: ["calves"], category: .main, difficulty: "Beginner", exerciseDescription: "Isolation exercise for calf development.", formTips: ["Full range of motion", "Pause at the top"], loadTips: ["Use bodyweight or hold dumbbells", "RPE 6-7"]),
                Exercise(name: "Glute Bridges", sets: 3, reps: "15", restSeconds: 45, muscleGroups: ["glutes", "hamstrings"], category: .main, difficulty: "Beginner", exerciseDescription: "Targets the glutes with a hip extension movement.", formTips: ["Squeeze glutes at the top", "Keep core tight"], loadTips: ["Add a barbell for progression", "RPE 6-7"]),
                Exercise(name: "Hamstring Stretch", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["hamstrings"], category: .cooldown, durationMinutes: 5),
                Exercise(name: "Hip Flexor Stretch", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["hip flexors"], category: .cooldown, durationMinutes: 5)
            ], caloriesBurned: 320),
            WorkoutDay(dayName: "Friday", focus: "Cardio & Core", durationMinutes: 40, exercises: [
                Exercise(name: "High Knees", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["cardio"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Torso Twists", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["core"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Plank", sets: 3, reps: "45 seconds", restSeconds: 30, muscleGroups: ["core", "shoulders"], category: .main, difficulty: "Intermediate", exerciseDescription: "Isometric core exercise that builds endurance and stability.", formTips: ["Keep body in a straight line", "Don't let hips sag or pike"], loadTips: ["Hold for 30-45 seconds per set", "When you start shaking, intensity is right"]),
                Exercise(name: "Russian Twists", sets: 3, reps: "20", restSeconds: 30, muscleGroups: ["core", "obliques"], category: .main, difficulty: "Intermediate", exerciseDescription: "Rotational core exercise targeting the obliques.", formTips: ["Lean back slightly, keep chest up", "Touch the ground on each side"], loadTips: ["Hold a weight for added challenge", "RPE 7"]),
                Exercise(name: "Leg Raises", sets: 3, reps: "15", restSeconds: 30, muscleGroups: ["lower abs", "hip flexors"], category: .main, difficulty: "Intermediate", exerciseDescription: "Targets the lower abdominals effectively.", formTips: ["Keep lower back pressed to floor", "Control the descent"], loadTips: ["Choose a load that makes last reps hard", "RPE 7-8"]),
                Exercise(name: "Bicycle Crunches", sets: 3, reps: "20", restSeconds: 30, muscleGroups: ["core", "obliques"], category: .main, difficulty: "Beginner", exerciseDescription: "Dynamic crunch variation that targets the entire core.", formTips: ["Bring elbow to opposite knee", "Keep shoulders off the ground"], loadTips: ["Focus on controlled movement", "RPE 6-7"]),
                Exercise(name: "Child's Pose", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["back"], category: .cooldown, durationMinutes: 5),
                Exercise(name: "Hip Flexor Stretch", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["hip flexors"], category: .cooldown, durationMinutes: 5)
            ], caloriesBurned: 350),
            WorkoutDay(dayName: "Saturday", focus: "Full Body Circuit", durationMinutes: 50, exercises: [
                Exercise(name: "Jump Rope", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["cardio"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Dynamic Stretching", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["full body"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Kettlebell Swings", sets: 4, reps: "15", restSeconds: 45, muscleGroups: ["full body", "glutes"], category: .main, difficulty: "Intermediate", exerciseDescription: "Explosive hip hinge movement for power and conditioning.", formTips: ["Drive with your hips, not arms", "Keep back flat throughout"], loadTips: ["Use a challenging but controllable weight", "RPE 7-8"]),
                Exercise(name: "Box Jumps", sets: 3, reps: "10", restSeconds: 45, muscleGroups: ["legs", "glutes", "cardio"], category: .main, difficulty: "Advanced", exerciseDescription: "Plyometric exercise that builds explosive leg power.", formTips: ["Land softly on the box", "Step down, don't jump down"], loadTips: ["Start with a lower box", "RPE 8"]),
                Exercise(name: "Push-Up Variations", sets: 3, reps: "12", restSeconds: 45, muscleGroups: ["chest", "triceps"], category: .main, difficulty: "Intermediate", exerciseDescription: "Mix of push-up styles for chest development.", formTips: ["Vary hand positions each set", "Full range of motion"], loadTips: ["Wide, narrow, and standard grip", "RPE 7"]),
                Exercise(name: "Pull-Ups", sets: 3, reps: "8", restSeconds: 60, muscleGroups: ["back", "biceps"], category: .main, difficulty: "Advanced", exerciseDescription: "Compound pulling exercise for back and arm development.", formTips: ["Full extension at bottom", "Chin over bar at top"], loadTips: ["Use bands for assistance if needed", "RPE 8-9"]),
                Exercise(name: "Foam Rolling", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["full body"], category: .cooldown, durationMinutes: 5),
                Exercise(name: "Static Stretching", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["full body"], category: .cooldown, durationMinutes: 5)
            ], caloriesBurned: 450),
            WorkoutDay(dayName: "Sunday", focus: "Rest & Recovery", durationMinutes: 20, exercises: [
                Exercise(name: "Foam Rolling", sets: 1, reps: "10 min", restSeconds: 0, muscleGroups: ["full body"], category: .main, difficulty: "Beginner", durationMinutes: 10),
                Exercise(name: "Gentle Stretching", sets: 1, reps: "10 min", restSeconds: 0, muscleGroups: ["full body"], category: .main, difficulty: "Beginner", durationMinutes: 10)
            ], isRestDay: true, caloriesBurned: 80)
        ]
    }

    private static func muscleGainWorkout() -> [WorkoutDay] {
        [
            WorkoutDay(dayName: "Monday", focus: "Chest & Triceps", durationMinutes: 60, exercises: [
                Exercise(name: "Arm Circles", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["shoulders"], category: .warmup, durationMinutes: 3),
                Exercise(name: "Light Push-Ups", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["chest"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Bench Press", sets: 4, reps: "8-10", restSeconds: 90, muscleGroups: ["chest", "triceps"], category: .main, difficulty: "Advanced", exerciseDescription: "The primary compound movement for chest development.", formTips: ["Retract shoulder blades", "Bar touches mid-chest"], loadTips: ["Use a spotter for heavy sets", "RPE 8-9"]),
                Exercise(name: "Incline Dumbbell Press", sets: 3, reps: "10-12", restSeconds: 75, muscleGroups: ["upper chest", "shoulders"], category: .main, difficulty: "Intermediate", exerciseDescription: "Targets the upper chest with an inclined angle.", formTips: ["30-degree incline angle", "Control the lowering phase"], loadTips: ["Progressive overload each week", "RPE 7-8"]),
                Exercise(name: "Cable Flyes", sets: 3, reps: "12-15", restSeconds: 60, muscleGroups: ["chest"], category: .main, difficulty: "Intermediate", exerciseDescription: "Isolation exercise for chest with constant tension.", formTips: ["Slight bend in elbows", "Squeeze at the midline"], loadTips: ["Focus on the stretch and squeeze", "RPE 7"]),
                Exercise(name: "Tricep Pushdown", sets: 3, reps: "12-15", restSeconds: 60, muscleGroups: ["triceps"], category: .main, difficulty: "Beginner", exerciseDescription: "Cable exercise isolating the triceps.", formTips: ["Keep elbows pinned to sides", "Full extension at bottom"], loadTips: ["Don't use momentum", "RPE 7"]),
                Exercise(name: "Skull Crushers", sets: 3, reps: "10-12", restSeconds: 60, muscleGroups: ["triceps"], category: .main, difficulty: "Intermediate", exerciseDescription: "Lying tricep extension for mass building.", formTips: ["Lower to forehead level", "Keep upper arms vertical"], loadTips: ["Use EZ bar for wrist comfort", "RPE 7-8"]),
                Exercise(name: "Chest Stretch", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["chest"], category: .cooldown, durationMinutes: 3),
                Exercise(name: "Tricep Stretch", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["triceps"], category: .cooldown, durationMinutes: 3)
            ], caloriesBurned: 320),
            WorkoutDay(dayName: "Tuesday", focus: "Back & Biceps", durationMinutes: 60, exercises: [
                Exercise(name: "Band Pull-Aparts", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["back"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Cat-Cow Stretch", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["spine"], category: .warmup, durationMinutes: 3),
                Exercise(name: "Pull-Ups", sets: 4, reps: "6-10", restSeconds: 90, muscleGroups: ["back", "biceps"], category: .main, difficulty: "Advanced", exerciseDescription: "Compound pulling movement for back width.", formTips: ["Full range of motion", "Lead with elbows"], loadTips: ["Add weight belt when bodyweight is easy", "RPE 8-9"]),
                Exercise(name: "Barbell Rows", sets: 4, reps: "8-10", restSeconds: 90, muscleGroups: ["back", "biceps"], category: .main, difficulty: "Advanced", exerciseDescription: "Heavy compound row for back thickness.", formTips: ["Keep torso at 45 degrees", "Pull to lower chest"], loadTips: ["Don't sacrifice form for weight", "RPE 8"]),
                Exercise(name: "Cable Rows", sets: 3, reps: "12", restSeconds: 60, muscleGroups: ["back", "rear delts"], category: .main, difficulty: "Intermediate", exerciseDescription: "Seated cable row for mid-back development.", formTips: ["Squeeze shoulder blades together", "Don't lean too far back"], loadTips: ["Feel the stretch at extension", "RPE 7"]),
                Exercise(name: "Barbell Curls", sets: 3, reps: "10-12", restSeconds: 60, muscleGroups: ["biceps"], category: .main, difficulty: "Intermediate", exerciseDescription: "Primary bicep mass builder.", formTips: ["Strict form, no swinging", "Full contraction at top"], loadTips: ["Control the eccentric", "RPE 7-8"]),
                Exercise(name: "Hammer Curls", sets: 3, reps: "12-15", restSeconds: 60, muscleGroups: ["biceps", "forearms"], category: .main, difficulty: "Beginner", exerciseDescription: "Neutral grip curl for brachialis and forearm development.", formTips: ["Neutral grip throughout", "Alternate arms or both together"], loadTips: ["Slightly lighter than barbell curls", "RPE 7"]),
                Exercise(name: "Lat Stretch", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["back"], category: .cooldown, durationMinutes: 3),
                Exercise(name: "Bicep Stretch", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["biceps"], category: .cooldown, durationMinutes: 3)
            ], caloriesBurned: 300),
            WorkoutDay(dayName: "Wednesday", focus: "Legs", durationMinutes: 65, exercises: [
                Exercise(name: "Leg Swings", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["hip flexors"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Bodyweight Squats", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["legs"], category: .warmup, durationMinutes: 3),
                Exercise(name: "Barbell Squats", sets: 4, reps: "6-8", restSeconds: 120, muscleGroups: ["quadriceps", "glutes"], category: .main, difficulty: "Advanced", exerciseDescription: "The king of all exercises for overall leg development.", formTips: ["Brace your core before descending", "Keep chest up, eyes forward"], loadTips: ["Use a belt for heavy sets", "RPE 8-9"]),
                Exercise(name: "Leg Press", sets: 4, reps: "10-12", restSeconds: 90, muscleGroups: ["quadriceps", "glutes"], category: .main, difficulty: "Intermediate", exerciseDescription: "Machine-based leg exercise for high volume.", formTips: ["Don't lock out knees", "Feet shoulder-width on platform"], loadTips: ["Go heavy but control the weight", "RPE 7-8"]),
                Exercise(name: "Romanian Deadlift", sets: 4, reps: "8-10", restSeconds: 90, muscleGroups: ["hamstrings", "glutes"], category: .main, difficulty: "Advanced", exerciseDescription: "Hip hinge for posterior chain development.", formTips: ["Slight knee bend throughout", "Feel the hamstring stretch"], loadTips: ["Bar stays close to legs", "RPE 8"]),
                Exercise(name: "Leg Curls", sets: 3, reps: "12", restSeconds: 60, muscleGroups: ["hamstrings"], category: .main, difficulty: "Beginner", exerciseDescription: "Machine isolation for hamstring development.", formTips: ["Control the negative", "Full range of motion"], loadTips: ["Moderate weight, focus on contraction", "RPE 7"]),
                Exercise(name: "Calf Raises", sets: 4, reps: "15-20", restSeconds: 60, muscleGroups: ["calves"], category: .main, difficulty: "Beginner", exerciseDescription: "Standing calf raise for calf development.", formTips: ["Full stretch at bottom", "Squeeze at the top"], loadTips: ["High reps work best for calves", "RPE 7"]),
                Exercise(name: "Hamstring Stretch", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["hamstrings"], category: .cooldown, durationMinutes: 5),
                Exercise(name: "Quad Stretch", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["quadriceps"], category: .cooldown, durationMinutes: 5)
            ], caloriesBurned: 400),
            WorkoutDay(dayName: "Thursday", focus: "Rest", durationMinutes: 0, exercises: [], isRestDay: true, caloriesBurned: 80),
            WorkoutDay(dayName: "Friday", focus: "Shoulders & Core", durationMinutes: 55, exercises: [
                Exercise(name: "Shoulder Rotations", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["shoulders"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Light Lateral Raises", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["shoulders"], category: .warmup, durationMinutes: 3),
                Exercise(name: "Overhead Press", sets: 4, reps: "8-10", restSeconds: 90, muscleGroups: ["shoulders", "triceps"], category: .main, difficulty: "Advanced", exerciseDescription: "Primary compound movement for shoulder development.", formTips: ["Brace core throughout", "Lock out at top"], loadTips: ["Standing or seated variation", "RPE 8-9"]),
                Exercise(name: "Lateral Raises", sets: 4, reps: "12-15", restSeconds: 60, muscleGroups: ["lateral delts"], category: .main, difficulty: "Beginner", exerciseDescription: "Isolation for lateral deltoid development.", formTips: ["Slight bend in elbows", "Raise to shoulder height"], loadTips: ["Light weight, high reps", "RPE 7"]),
                Exercise(name: "Face Pulls", sets: 3, reps: "15", restSeconds: 60, muscleGroups: ["rear delts", "upper back"], category: .main, difficulty: "Beginner", exerciseDescription: "Cable exercise for rear deltoid and posture.", formTips: ["Pull to face level", "External rotate at end"], loadTips: ["Focus on contraction, not weight", "RPE 6-7"]),
                Exercise(name: "Plank", sets: 3, reps: "60 seconds", restSeconds: 45, muscleGroups: ["core"], category: .main, difficulty: "Intermediate", exerciseDescription: "Isometric core exercise for stability.", formTips: ["Keep body straight", "Engage glutes and abs"], loadTips: ["Add weight plate on back for challenge", "RPE 7"]),
                Exercise(name: "Cable Crunches", sets: 3, reps: "15", restSeconds: 45, muscleGroups: ["core", "abs"], category: .main, difficulty: "Intermediate", exerciseDescription: "Weighted ab exercise for six-pack development.", formTips: ["Curl down, don't hip hinge", "Exhale on contraction"], loadTips: ["Progressive overload works here too", "RPE 7-8"]),
                Exercise(name: "Shoulder Stretch", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["shoulders"], category: .cooldown, durationMinutes: 5),
                Exercise(name: "Cat-Cow", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["spine"], category: .cooldown, durationMinutes: 3)
            ], caloriesBurned: 280),
            WorkoutDay(dayName: "Saturday", focus: "Full Body", durationMinutes: 55, exercises: [
                Exercise(name: "Jump Rope", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["cardio"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Dynamic Stretching", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["full body"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Deadlifts", sets: 4, reps: "5-6", restSeconds: 120, muscleGroups: ["full body", "back", "legs"], category: .main, difficulty: "Advanced", exerciseDescription: "The ultimate compound lift for total body strength.", formTips: ["Keep bar close to body", "Neutral spine throughout"], loadTips: ["Prioritize form over weight", "RPE 9"]),
                Exercise(name: "Dips", sets: 3, reps: "10-12", restSeconds: 75, muscleGroups: ["chest", "triceps"], category: .main, difficulty: "Intermediate", exerciseDescription: "Upper body pushing exercise for chest and triceps.", formTips: ["Lean forward for more chest", "Full lockout at top"], loadTips: ["Add weight belt when ready", "RPE 7-8"]),
                Exercise(name: "Chin-Ups", sets: 3, reps: "8-10", restSeconds: 75, muscleGroups: ["back", "biceps"], category: .main, difficulty: "Advanced", exerciseDescription: "Supinated grip pull-up for back and bicep engagement.", formTips: ["Full range of motion", "Chin over bar at top"], loadTips: ["Bands for assistance if needed", "RPE 8"]),
                Exercise(name: "Bulgarian Split Squat", sets: 3, reps: "10 each", restSeconds: 90, muscleGroups: ["legs", "glutes"], category: .main, difficulty: "Intermediate", exerciseDescription: "Single leg exercise for strength and balance.", formTips: ["Keep torso upright", "Front knee tracks over toes"], loadTips: ["Hold dumbbells at sides", "RPE 7-8"]),
                Exercise(name: "Full Body Stretch", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["full body"], category: .cooldown, durationMinutes: 5),
                Exercise(name: "Deep Breathing", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["recovery"], category: .cooldown, durationMinutes: 3)
            ], caloriesBurned: 380),
            WorkoutDay(dayName: "Sunday", focus: "Rest", durationMinutes: 0, exercises: [], isRestDay: true, caloriesBurned: 60)
        ]
    }

    private static func maintenanceWorkout() -> [WorkoutDay] {
        [
            WorkoutDay(dayName: "Monday", focus: "Upper Body", durationMinutes: 45, exercises: [
                Exercise(name: "Arm Circles", sets: 1, reps: "3 minutes", restSeconds: 0, muscleGroups: ["shoulders"], category: .warmup, durationMinutes: 3),
                Exercise(name: "Push-Ups", sets: 3, reps: "15", restSeconds: 60, muscleGroups: ["chest", "triceps"], category: .main, difficulty: "Intermediate", exerciseDescription: "Classic bodyweight chest exercise.", formTips: ["Full range of motion", "Keep core tight"], loadTips: ["Add variations for challenge", "RPE 6-7"]),
                Exercise(name: "Dumbbell Rows", sets: 3, reps: "12", restSeconds: 60, muscleGroups: ["back", "biceps"], category: .main, difficulty: "Intermediate", exerciseDescription: "Single arm row for back development.", formTips: ["Pull to hip", "Squeeze at top"], loadTips: ["Moderate weight", "RPE 6-7"]),
                Exercise(name: "Shoulder Press", sets: 3, reps: "12", restSeconds: 60, muscleGroups: ["shoulders"], category: .main, difficulty: "Intermediate", exerciseDescription: "Overhead pressing for shoulder strength.", formTips: ["Don't arch back", "Controlled movement"], loadTips: ["Maintain current strength", "RPE 6-7"]),
                Exercise(name: "Stretching", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["upper body"], category: .cooldown, durationMinutes: 5)
            ], caloriesBurned: 250),
            WorkoutDay(dayName: "Tuesday", focus: "Cardio", durationMinutes: 35, exercises: [
                Exercise(name: "Light Jog", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["cardio"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Jogging", sets: 1, reps: "25 min", restSeconds: 0, muscleGroups: ["full body", "cardio"], category: .main, difficulty: "Beginner", exerciseDescription: "Steady state cardio for heart health.", formTips: ["Maintain a conversational pace", "Breathe rhythmically"], loadTips: ["Zone 2 heart rate", "RPE 5-6"], durationMinutes: 25),
                Exercise(name: "Walking Cool-Down", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["full body"], category: .cooldown, durationMinutes: 5)
            ], caloriesBurned: 300),
            WorkoutDay(dayName: "Wednesday", focus: "Rest", durationMinutes: 0, exercises: [], isRestDay: true, caloriesBurned: 80),
            WorkoutDay(dayName: "Thursday", focus: "Lower Body", durationMinutes: 45, exercises: [
                Exercise(name: "Leg Swings", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["hip flexors"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Squats", sets: 3, reps: "15", restSeconds: 60, muscleGroups: ["legs", "glutes"], category: .main, difficulty: "Intermediate", exerciseDescription: "Fundamental leg exercise.", formTips: ["Knees track over toes", "Squat to parallel"], loadTips: ["Maintain current load", "RPE 6-7"]),
                Exercise(name: "Lunges", sets: 3, reps: "12 each", restSeconds: 60, muscleGroups: ["legs", "glutes"], category: .main, difficulty: "Intermediate", exerciseDescription: "Unilateral leg exercise.", formTips: ["Step far enough forward", "Keep torso upright"], loadTips: ["Bodyweight or light dumbbells", "RPE 6"]),
                Exercise(name: "Glute Bridges", sets: 3, reps: "15", restSeconds: 45, muscleGroups: ["glutes"], category: .main, difficulty: "Beginner", exerciseDescription: "Glute activation and strengthening.", formTips: ["Squeeze at the top", "Keep core engaged"], loadTips: ["Add weight for progression", "RPE 6"]),
                Exercise(name: "Leg Stretch", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["legs"], category: .cooldown, durationMinutes: 5)
            ], caloriesBurned: 280),
            WorkoutDay(dayName: "Friday", focus: "Full Body", durationMinutes: 40, exercises: [
                Exercise(name: "Dynamic Warm-Up", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["full body"], category: .warmup, durationMinutes: 5),
                Exercise(name: "Circuit Training", sets: 3, reps: "30 sec each", restSeconds: 30, muscleGroups: ["full body"], category: .main, difficulty: "Intermediate", exerciseDescription: "Circuit of bodyweight exercises for overall fitness.", formTips: ["Maintain good form despite fatigue", "Rest between circuits"], loadTips: ["Moderate effort", "RPE 6-7"]),
                Exercise(name: "Cool-Down Stretch", sets: 1, reps: "5 minutes", restSeconds: 0, muscleGroups: ["full body"], category: .cooldown, durationMinutes: 5)
            ], caloriesBurned: 320),
            WorkoutDay(dayName: "Saturday", focus: "Active Recreation", durationMinutes: 60, exercises: [
                Exercise(name: "Sport / Hiking / Cycling", sets: 1, reps: "60 min", restSeconds: 0, muscleGroups: ["full body", "cardio"], category: .main, difficulty: "Beginner", exerciseDescription: "Enjoy outdoor activities for active recovery and fun.", formTips: ["Stay hydrated", "Listen to your body"], loadTips: ["Keep intensity moderate", "RPE 5-6"], durationMinutes: 60)
            ], caloriesBurned: 400),
            WorkoutDay(dayName: "Sunday", focus: "Rest & Yoga", durationMinutes: 30, exercises: [
                Exercise(name: "Yoga / Stretching", sets: 1, reps: "30 min", restSeconds: 0, muscleGroups: ["full body"], category: .main, difficulty: "Beginner", exerciseDescription: "Gentle yoga for flexibility and recovery.", formTips: ["Breathe deeply", "Don't force positions"], loadTips: ["Focus on relaxation", "RPE 3-4"], durationMinutes: 30)
            ], isRestDay: true, caloriesBurned: 120)
        ]
    }
}
