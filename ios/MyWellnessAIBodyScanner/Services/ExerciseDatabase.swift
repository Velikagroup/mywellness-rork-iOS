import Foundation

nonisolated enum MuscleGroup: String, Sendable {
    case chest, back, shoulders, biceps, triceps
    case quads, hamstrings, glutes, calves, core
    case fullBody, cardio
}

nonisolated enum EquipmentType: String, Sendable {
    case bodyweight, dumbbell, barbell, cable, machine, kettlebell, resistanceBand, trx, bench, pullupBar
}

nonisolated struct ExerciseTemplate: Sendable {
    let name: String
    let primaryMuscles: [MuscleGroup]
    let secondaryMuscles: [MuscleGroup]
    let equipment: [EquipmentType]
    let difficulty: String
    let exerciseDescription: String
    let formTips: [String]
    let isCompound: Bool
    let baseCategory: ExerciseCategory
    let estimatedDurationSeconds: Int
    let jointStress: [String]
}

nonisolated enum ExerciseDatabase {

    static let all: [ExerciseTemplate] = chest + back + shoulders + biceps + triceps + quads + hamstrings + glutes + calves + core + fullBody + warmups + cooldowns

    // MARK: - Chest

    static let chest: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Barbell Bench Press",
            primaryMuscles: [.chest], secondaryMuscles: [.triceps, .shoulders],
            equipment: [.barbell, .bench], difficulty: "Intermediate",
            exerciseDescription: "Lie on a flat bench, grip the barbell slightly wider than shoulder-width. Lower the bar to mid-chest, then press up explosively while keeping your shoulder blades retracted and feet firmly planted.",
            formTips: ["Keep shoulder blades retracted and depressed", "Bar path should be slightly diagonal — from mid-chest to over shoulders", "Maintain an arch in your lower back without lifting hips off the bench", "Grip the bar firmly with wrists stacked over elbows"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 180, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Dumbbell Bench Press",
            primaryMuscles: [.chest], secondaryMuscles: [.triceps, .shoulders],
            equipment: [.dumbbell, .bench], difficulty: "Beginner",
            exerciseDescription: "Lie on a flat bench holding a dumbbell in each hand at chest level. Press the dumbbells up until arms are extended, then lower with control. Dumbbells allow a greater range of motion than barbell.",
            formTips: ["Keep a slight arch in your back", "Lower dumbbells to the sides of your chest", "Press up and slightly inward without clanking the dumbbells", "Control the eccentric — 2-3 seconds on the way down"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Incline Barbell Bench Press",
            primaryMuscles: [.chest], secondaryMuscles: [.shoulders, .triceps],
            equipment: [.barbell, .bench], difficulty: "Intermediate",
            exerciseDescription: "Set the bench to 30-45 degrees. Grip the barbell slightly wider than shoulders. Lower to the upper chest, then press up. This variation emphasizes the upper chest fibers.",
            formTips: ["Set bench to 30-45 degrees for optimal upper chest activation", "Lower bar to upper chest/clavicle area", "Keep elbows at roughly 45-degree angle from torso", "Don't let the bar drift too far forward"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 180, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Incline Dumbbell Press",
            primaryMuscles: [.chest], secondaryMuscles: [.shoulders, .triceps],
            equipment: [.dumbbell, .bench], difficulty: "Beginner",
            exerciseDescription: "Set bench to 30-45 degrees. Press dumbbells from shoulder level upward. The incline angle targets the upper chest (clavicular head of the pectoralis major) more than flat pressing.",
            formTips: ["Keep wrists neutral — don't let them bend back", "Press up and slightly inward", "Squeeze the chest at the top of each rep", "Lower slowly for maximum muscle tension"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Decline Dumbbell Press",
            primaryMuscles: [.chest], secondaryMuscles: [.triceps],
            equipment: [.dumbbell, .bench], difficulty: "Intermediate",
            exerciseDescription: "Set bench to a slight decline (-15 degrees). Press dumbbells upward from the lower chest. This angle emphasizes the lower chest fibers and often allows you to press heavier loads.",
            formTips: ["Hook your legs securely on the bench pad", "Press up and slightly inward", "Control the descent — don't bounce off the chest", "Keep shoulder blades tight against the bench"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: []
        ),
        ExerciseTemplate(
            name: "Dumbbell Fly",
            primaryMuscles: [.chest], secondaryMuscles: [],
            equipment: [.dumbbell, .bench], difficulty: "Beginner",
            exerciseDescription: "Lie flat on a bench with dumbbells above your chest, palms facing each other. With a slight bend in your elbows, lower the weights out to the sides in a wide arc until you feel a stretch in the chest, then bring them back together.",
            formTips: ["Keep a slight bend in your elbows throughout", "Lower until you feel a stretch — don't go too deep", "Imagine hugging a large tree on the way up", "Focus on squeezing the chest at the top"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 140, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Cable Crossover",
            primaryMuscles: [.chest], secondaryMuscles: [],
            equipment: [.cable], difficulty: "Intermediate",
            exerciseDescription: "Stand in the center of a cable station with handles set at shoulder height. Step forward slightly and bring the handles together in front of your chest in a hugging motion. Constant cable tension provides superior muscle fiber recruitment.",
            formTips: ["Lean slightly forward with one foot ahead for stability", "Keep a slight bend in your elbows", "Squeeze and hold at the peak contraction for 1-2 seconds", "Control the return — don't let the cables pull your arms back"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 140, jointStress: []
        ),
        ExerciseTemplate(
            name: "Push-Up",
            primaryMuscles: [.chest], secondaryMuscles: [.triceps, .shoulders, .core],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Start in a plank position with hands slightly wider than shoulders. Lower your body until your chest nearly touches the floor, then push back up. Keep your body in a straight line from head to heels throughout the movement.",
            formTips: ["Hands slightly wider than shoulder-width", "Keep your core tight — don't let hips sag or pike", "Lower until chest is 2-3 inches from the floor", "Full lockout at the top of each rep"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Diamond Push-Up",
            primaryMuscles: [.chest, .triceps], secondaryMuscles: [.shoulders],
            equipment: [.bodyweight], difficulty: "Intermediate",
            exerciseDescription: "Place hands close together under your chest forming a diamond shape with thumbs and index fingers. Perform push-ups from this narrow position. This variation significantly increases triceps activation while still working the inner chest.",
            formTips: ["Form a diamond with thumbs and index fingers", "Keep elbows close to your body", "Lower chest to your hands", "Engage core to maintain a straight body line"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["elbows"]
        ),
        ExerciseTemplate(
            name: "Chest Dip",
            primaryMuscles: [.chest], secondaryMuscles: [.triceps, .shoulders],
            equipment: [.bodyweight], difficulty: "Intermediate",
            exerciseDescription: "Using parallel bars, lean your torso forward about 30 degrees. Lower yourself until your upper arms are parallel to the floor, then press back up. The forward lean shifts emphasis from triceps to the lower chest.",
            formTips: ["Lean forward 30 degrees to target chest over triceps", "Lower until upper arms are parallel with the ground", "Keep elbows slightly flared", "Don't lock out aggressively — stop just short of full extension"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: ["shoulders", "elbows"]
        ),
        ExerciseTemplate(
            name: "Machine Chest Press",
            primaryMuscles: [.chest], secondaryMuscles: [.triceps, .shoulders],
            equipment: [.machine], difficulty: "Beginner",
            exerciseDescription: "Sit in the chest press machine with your back flat against the pad. Grip the handles at chest level and press forward until arms are extended, then return with control. Machines provide a fixed path, ideal for beginners or muscle isolation.",
            formTips: ["Adjust the seat so handles are at mid-chest level", "Keep your back flat against the pad", "Don't lock elbows at the top", "Focus on squeezing the chest, not pushing with shoulders"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 140, jointStress: []
        ),
        ExerciseTemplate(
            name: "Pec Deck Fly",
            primaryMuscles: [.chest], secondaryMuscles: [],
            equipment: [.machine], difficulty: "Beginner",
            exerciseDescription: "Sit in the pec deck machine with your back against the pad. Place your forearms against the pads and bring them together in front of your chest. This isolates the chest with minimal shoulder and tricep involvement.",
            formTips: ["Adjust seat height so arms are at chest level", "Squeeze the pads together and hold 1-2 seconds", "Don't let the weight stack touch between reps", "Keep shoulders down and back against the pad"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 130, jointStress: []
        ),
        ExerciseTemplate(
            name: "Landmine Press",
            primaryMuscles: [.chest], secondaryMuscles: [.shoulders, .triceps],
            equipment: [.barbell], difficulty: "Intermediate",
            exerciseDescription: "Place one end of a barbell in a landmine attachment or corner. Hold the other end at shoulder height with one or both hands. Press upward and forward in an arc motion. This unique angle is joint-friendly and great for upper chest development.",
            formTips: ["Stand in a staggered stance for stability", "Press up and forward following the arc of the barbell", "Keep core engaged throughout", "Control the eccentric slowly"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: []
        ),
        ExerciseTemplate(
            name: "Svend Press",
            primaryMuscles: [.chest], secondaryMuscles: [],
            equipment: [.dumbbell], difficulty: "Beginner",
            exerciseDescription: "Hold a weight plate (or light dumbbell) between your palms at chest level. Press the plate forward while squeezing your palms together as hard as possible, then bring it back to your chest. This isometric squeeze maximizes inner chest activation.",
            formTips: ["Squeeze palms together as hard as possible throughout", "Press straight out from the chest", "Keep shoulders down — don't shrug", "Use a light weight — the squeeze is what matters"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 100, jointStress: []
        ),
    ]

    // MARK: - Back

    static let back: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Barbell Deadlift",
            primaryMuscles: [.back], secondaryMuscles: [.hamstrings, .glutes, .core],
            equipment: [.barbell], difficulty: "Advanced",
            exerciseDescription: "Stand with feet hip-width apart, barbell over mid-foot. Hinge at hips and grip the bar. Drive through your heels to stand up, keeping the bar close to your body. The king of compound movements — works the entire posterior chain.",
            formTips: ["Bar should stay in contact with your shins and thighs", "Push the floor away rather than pulling the bar up", "Keep your chest up and spine neutral", "Lock out by squeezing glutes at the top — don't hyperextend"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 200, jointStress: ["back"]
        ),
        ExerciseTemplate(
            name: "Pull-Up",
            primaryMuscles: [.back], secondaryMuscles: [.biceps],
            equipment: [.pullupBar, .bodyweight], difficulty: "Intermediate",
            exerciseDescription: "Hang from a bar with an overhand grip slightly wider than shoulders. Pull yourself up until your chin is over the bar, then lower with control. The fundamental upper back exercise — build width and strength.",
            formTips: ["Initiate the pull by depressing your shoulder blades", "Pull elbows down and back — imagine putting them in your pockets", "Get chin over the bar without craning your neck", "Full dead hang at the bottom for each rep"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Chin-Up",
            primaryMuscles: [.back, .biceps], secondaryMuscles: [],
            equipment: [.pullupBar, .bodyweight], difficulty: "Intermediate",
            exerciseDescription: "Hang from a bar with an underhand (supinated) grip, hands shoulder-width apart. Pull yourself up until chin clears the bar. The supinated grip increases bicep involvement compared to pull-ups.",
            formTips: ["Use a shoulder-width underhand grip", "Pull your chest toward the bar", "Control the negative — 3 seconds down", "Avoid swinging or kipping"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: ["elbows"]
        ),
        ExerciseTemplate(
            name: "Barbell Row",
            primaryMuscles: [.back], secondaryMuscles: [.biceps, .core],
            equipment: [.barbell], difficulty: "Intermediate",
            exerciseDescription: "Hinge forward at the hips holding a barbell with an overhand grip. Pull the bar to your lower chest/upper abdomen, squeezing shoulder blades together. Lower with control. One of the best exercises for overall back thickness.",
            formTips: ["Keep torso at approximately 45 degrees", "Pull the bar to your lower chest or upper abdomen", "Squeeze shoulder blades together at the top", "Don't use momentum — if you have to jerk, reduce the weight"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 170, jointStress: ["back"]
        ),
        ExerciseTemplate(
            name: "Dumbbell Row",
            primaryMuscles: [.back], secondaryMuscles: [.biceps],
            equipment: [.dumbbell, .bench], difficulty: "Beginner",
            exerciseDescription: "Place one hand and knee on a bench for support. With the other hand, pull a dumbbell from arm's length up to your hip, driving the elbow past your torso. This unilateral movement helps correct muscle imbalances.",
            formTips: ["Keep your back flat and parallel to the floor", "Pull the dumbbell toward your hip, not your chest", "Drive your elbow past your torso at the top", "Avoid rotating your torso — keep hips square"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: []
        ),
        ExerciseTemplate(
            name: "Seated Cable Row",
            primaryMuscles: [.back], secondaryMuscles: [.biceps],
            equipment: [.cable], difficulty: "Beginner",
            exerciseDescription: "Sit at a cable row station with feet on the platform. Pull the handle to your abdomen, squeezing your shoulder blades together. Return slowly. Constant cable tension makes this excellent for mind-muscle connection.",
            formTips: ["Sit upright — don't lean back excessively", "Pull to your navel area", "Hold the contraction for 1-2 seconds", "Extend arms fully on the return without rounding your back"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: []
        ),
        ExerciseTemplate(
            name: "Lat Pulldown",
            primaryMuscles: [.back], secondaryMuscles: [.biceps],
            equipment: [.cable, .machine], difficulty: "Beginner",
            exerciseDescription: "Sit at a lat pulldown machine with thighs secured under the pads. Grip the wide bar and pull it down to your upper chest while leaning slightly back. The primary lat builder for those who can't yet do pull-ups.",
            formTips: ["Grip the bar slightly wider than shoulder-width", "Lean back slightly — about 15-20 degrees", "Pull the bar to your upper chest, not behind your neck", "Focus on pulling with your elbows, not your hands"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: []
        ),
        ExerciseTemplate(
            name: "T-Bar Row",
            primaryMuscles: [.back], secondaryMuscles: [.biceps, .core],
            equipment: [.barbell], difficulty: "Intermediate",
            exerciseDescription: "Straddle the T-bar or landmine barbell. Hinge at hips, grip the handle, and row the weight to your chest. This targets the mid-back with a neutral grip that's easier on the wrists.",
            formTips: ["Keep a slight bend in your knees", "Pull toward your sternum", "Squeeze your back at the top", "Don't jerk the weight — smooth controlled reps"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 170, jointStress: ["back"]
        ),
        ExerciseTemplate(
            name: "Face Pull",
            primaryMuscles: [.back, .shoulders], secondaryMuscles: [],
            equipment: [.cable], difficulty: "Beginner",
            exerciseDescription: "Set a cable at face height with a rope attachment. Pull the rope toward your face, spreading the ends apart as you pull. Externally rotate at the end position. Essential for shoulder health and rear delt development.",
            formTips: ["Pull toward your forehead, not your chin", "Spread the rope ends apart at peak contraction", "Externally rotate — thumbs should point behind you", "Use moderate weight — this is about quality, not load"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Inverted Row",
            primaryMuscles: [.back], secondaryMuscles: [.biceps, .core],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Set a bar at waist height (Smith machine or squat rack). Hang underneath with an overhand grip, body straight. Pull your chest to the bar, then lower. The bodyweight equivalent of a cable row.",
            formTips: ["Keep body in a straight line from head to heels", "Pull chest to the bar — not chin", "Squeeze shoulder blades together at the top", "Adjust difficulty by changing foot position"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 130, jointStress: []
        ),
        ExerciseTemplate(
            name: "Dumbbell Pullover",
            primaryMuscles: [.back, .chest], secondaryMuscles: [],
            equipment: [.dumbbell, .bench], difficulty: "Intermediate",
            exerciseDescription: "Lie across a bench with only upper back supported. Hold a dumbbell overhead with both hands. Lower it behind your head in an arc until you feel a deep stretch, then pull it back over your chest.",
            formTips: ["Keep a slight bend in your elbows", "Lower the weight until you feel a deep stretch", "Drive the weight up using your lats", "Keep hips slightly lower than the bench for a better stretch"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 140, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Straight-Arm Pulldown",
            primaryMuscles: [.back], secondaryMuscles: [],
            equipment: [.cable], difficulty: "Beginner",
            exerciseDescription: "Stand facing a cable machine with the attachment at the top. With straight arms, push the bar down in an arc from face height to your thighs. This isolates the lats without bicep involvement.",
            formTips: ["Keep arms nearly straight with a slight bend", "Push the bar in an arc — not straight down", "Squeeze your lats hard at the bottom", "Don't lean forward excessively"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Chest-Supported Dumbbell Row",
            primaryMuscles: [.back], secondaryMuscles: [.biceps],
            equipment: [.dumbbell, .bench], difficulty: "Beginner",
            exerciseDescription: "Set an incline bench to 30-45 degrees. Lie face-down on it and row dumbbells up toward your hips. The bench support eliminates momentum and lower back stress, ensuring pure back work.",
            formTips: ["Lie flat against the bench — no arching", "Row toward your hips, not your chest", "Squeeze shoulder blades together at the top", "Control the negative for maximum tension"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: []
        ),
        ExerciseTemplate(
            name: "Meadows Row",
            primaryMuscles: [.back], secondaryMuscles: [.biceps],
            equipment: [.barbell], difficulty: "Advanced",
            exerciseDescription: "Set up a barbell in a landmine. Stand perpendicular to the barbell, grab the end with one hand. Row explosively toward your hip. This unilateral row allows for a massive stretch and powerful contraction.",
            formTips: ["Stand perpendicular to the barbell", "Stagger your stance with the inside foot forward", "Pull explosively and control the negative", "Allow a full stretch at the bottom"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: []
        ),
    ]

    // MARK: - Shoulders

    static let shoulders: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Overhead Press",
            primaryMuscles: [.shoulders], secondaryMuscles: [.triceps, .core],
            equipment: [.barbell], difficulty: "Intermediate",
            exerciseDescription: "Stand with feet shoulder-width apart, barbell at collarbone height. Press overhead until arms are locked out. The foundational overhead pressing movement for shoulder strength and size.",
            formTips: ["Start with the bar at collarbone level", "Press straight up — move your head out of the way", "Lock out overhead with the bar over mid-foot", "Keep core tight and glutes squeezed"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 170, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Dumbbell Shoulder Press",
            primaryMuscles: [.shoulders], secondaryMuscles: [.triceps],
            equipment: [.dumbbell, .bench], difficulty: "Beginner",
            exerciseDescription: "Sit or stand holding dumbbells at shoulder height, palms facing forward. Press both dumbbells overhead until arms are fully extended. Greater range of motion and independent arm movement compared to barbell.",
            formTips: ["Start with dumbbells at ear level", "Press up and slightly inward", "Don't let elbows flare too far behind your body", "Full lockout at the top"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Arnold Press",
            primaryMuscles: [.shoulders], secondaryMuscles: [.triceps],
            equipment: [.dumbbell, .bench], difficulty: "Intermediate",
            exerciseDescription: "Start with dumbbells at shoulder height, palms facing you. As you press up, rotate your palms to face forward at the top. This rotation engages all three deltoid heads through a full range of motion.",
            formTips: ["Start palms facing you, end palms facing forward", "Rotate smoothly as you press — don't rush it", "Full extension at the top", "Reverse the rotation on the way down"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Lateral Raise",
            primaryMuscles: [.shoulders], secondaryMuscles: [],
            equipment: [.dumbbell], difficulty: "Beginner",
            exerciseDescription: "Stand with dumbbells at your sides. Raise arms out to the sides until parallel with the floor, then lower with control. The primary isolation exercise for the lateral (side) deltoid — responsible for shoulder width.",
            formTips: ["Lead with your elbows, not your hands", "Raise to shoulder height — no higher", "Slight bend in elbows throughout", "Control the descent — don't swing"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Cable Lateral Raise",
            primaryMuscles: [.shoulders], secondaryMuscles: [],
            equipment: [.cable], difficulty: "Beginner",
            exerciseDescription: "Stand beside a low cable pulley. Grab the handle with your outside hand and raise your arm out to the side until parallel with the floor. The cable provides constant tension throughout the range of motion.",
            formTips: ["Stand with the cable crossing in front of your body", "Raise arm to shoulder height", "Pause at the top for 1-2 seconds", "Very slow negative for maximum tension"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Front Raise",
            primaryMuscles: [.shoulders], secondaryMuscles: [],
            equipment: [.dumbbell], difficulty: "Beginner",
            exerciseDescription: "Stand holding dumbbells in front of your thighs. Raise one or both arms forward to shoulder height, then lower. Isolates the anterior (front) deltoid.",
            formTips: ["Raise to shoulder height — not above", "Keep arms slightly bent", "Alternate arms or raise both simultaneously", "Don't lean back to generate momentum"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 110, jointStress: []
        ),
        ExerciseTemplate(
            name: "Reverse Fly",
            primaryMuscles: [.shoulders], secondaryMuscles: [.back],
            equipment: [.dumbbell], difficulty: "Beginner",
            exerciseDescription: "Bend forward at the hips, holding dumbbells below your chest. Raise both arms out to the sides, squeezing shoulder blades together. Targets the rear deltoids — critical for shoulder balance and posture.",
            formTips: ["Hinge forward until torso is nearly parallel to the floor", "Raise arms out to the sides, not back", "Squeeze your shoulder blades at the top", "Use light weight — rear delts respond to volume, not load"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Upright Row",
            primaryMuscles: [.shoulders], secondaryMuscles: [.biceps],
            equipment: [.barbell, .dumbbell], difficulty: "Intermediate",
            exerciseDescription: "Hold a barbell or dumbbells in front of your thighs. Pull straight up along your body to chin height, leading with your elbows. Targets the lateral deltoids and upper traps.",
            formTips: ["Use a wider grip to reduce shoulder impingement risk", "Lead with elbows — keep them above your hands", "Pull to chin height, not higher", "If you feel shoulder discomfort, switch to lateral raises"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 130, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Pike Push-Up",
            primaryMuscles: [.shoulders], secondaryMuscles: [.triceps],
            equipment: [.bodyweight], difficulty: "Intermediate",
            exerciseDescription: "Start in a downward-dog position with hips high. Bend your elbows and lower your head toward the floor, then push back up. The bodyweight alternative to overhead pressing.",
            formTips: ["Keep hips high and legs as straight as possible", "Lower forehead toward the floor between your hands", "Push back up explosively", "Elevate your feet for added difficulty"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Machine Shoulder Press",
            primaryMuscles: [.shoulders], secondaryMuscles: [.triceps],
            equipment: [.machine], difficulty: "Beginner",
            exerciseDescription: "Sit in the shoulder press machine with your back against the pad. Press the handles overhead until arms are extended, then lower with control. The guided path is ideal for beginners or those with balance issues.",
            formTips: ["Adjust seat so handles start at ear level", "Keep your back flat against the pad", "Press overhead without locking elbows completely", "Control the negative — don't let the weight drop"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 140, jointStress: []
        ),
        ExerciseTemplate(
            name: "Lu Raise",
            primaryMuscles: [.shoulders], secondaryMuscles: [],
            equipment: [.dumbbell], difficulty: "Intermediate",
            exerciseDescription: "Hold light dumbbells at your sides. Perform a front raise to shoulder height, then move arms out to a lateral raise position, then lower. This continuous motion targets all three deltoid heads in one fluid movement.",
            formTips: ["Use very light weight — form is everything", "Raise forward first, then sweep to the sides", "Keep arms at shoulder height during the sweep", "Lower slowly from the lateral position"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 130, jointStress: []
        ),
    ]

    // MARK: - Biceps

    static let biceps: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Barbell Curl",
            primaryMuscles: [.biceps], secondaryMuscles: [],
            equipment: [.barbell], difficulty: "Beginner",
            exerciseDescription: "Stand with feet shoulder-width apart, arms extended holding a barbell with an underhand grip. Curl the weight up to shoulder height, then lower with control. The fundamental bicep mass builder.",
            formTips: ["Keep elbows pinned to your sides", "Don't swing your body — use strict form", "Squeeze the biceps at the top", "Lower the bar slowly — 2-3 seconds down"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["elbows"]
        ),
        ExerciseTemplate(
            name: "Dumbbell Curl",
            primaryMuscles: [.biceps], secondaryMuscles: [],
            equipment: [.dumbbell], difficulty: "Beginner",
            exerciseDescription: "Stand holding dumbbells at your sides, palms facing forward. Curl one or both dumbbells up to shoulder height while keeping elbows stationary. Dumbbells allow for supination and independent arm training.",
            formTips: ["Supinate (rotate palms up) as you curl", "Keep elbows stationary at your sides", "Don't swing — strict isolated curls", "Full extension at the bottom of each rep"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Hammer Curl",
            primaryMuscles: [.biceps], secondaryMuscles: [],
            equipment: [.dumbbell], difficulty: "Beginner",
            exerciseDescription: "Stand holding dumbbells at your sides with palms facing each other (neutral grip). Curl up while maintaining the neutral grip. Targets the brachialis and brachioradialis for arm thickness.",
            formTips: ["Keep palms facing each other throughout", "Elbows stay pinned to your sides", "Curl up to shoulder height", "Alternate arms or curl both together"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Incline Dumbbell Curl",
            primaryMuscles: [.biceps], secondaryMuscles: [],
            equipment: [.dumbbell, .bench], difficulty: "Intermediate",
            exerciseDescription: "Sit on an incline bench (45-60 degrees) with arms hanging straight down. Curl dumbbells up while keeping upper arms perpendicular to the floor. The incline stretches the long head of the bicep for maximum peak development.",
            formTips: ["Let arms hang straight down from your shoulders", "Don't let elbows drift forward as you curl", "Full stretch at the bottom of each rep", "Squeeze hard at the top"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 130, jointStress: []
        ),
        ExerciseTemplate(
            name: "Preacher Curl",
            primaryMuscles: [.biceps], secondaryMuscles: [],
            equipment: [.barbell, .dumbbell], difficulty: "Intermediate",
            exerciseDescription: "Sit at a preacher bench with upper arms resting on the pad. Curl the weight up from full extension. The pad prevents cheating and isolates the bicep, especially the short head.",
            formTips: ["Upper arms should be flat on the pad", "Don't lift your elbows off the pad", "Full extension at the bottom — be careful with heavy weights", "Controlled movement — no swinging"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 130, jointStress: ["elbows"]
        ),
        ExerciseTemplate(
            name: "Cable Curl",
            primaryMuscles: [.biceps], secondaryMuscles: [],
            equipment: [.cable], difficulty: "Beginner",
            exerciseDescription: "Stand facing a low cable pulley with a straight or EZ bar attachment. Curl the bar up while keeping elbows at your sides. Cable tension provides constant resistance throughout the entire range of motion.",
            formTips: ["Stand about 1 step back from the pulley", "Keep elbows pinned to your sides", "Full contraction at the top", "Slow, controlled reps — don't jerk the cable"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Concentration Curl",
            primaryMuscles: [.biceps], secondaryMuscles: [],
            equipment: [.dumbbell], difficulty: "Beginner",
            exerciseDescription: "Sit on a bench with legs spread. Rest the back of your upper arm against your inner thigh. Curl the dumbbell up toward your shoulder. Maximum isolation — zero cheating possible.",
            formTips: ["Brace your upper arm firmly against your inner thigh", "Curl up to your shoulder", "Squeeze at the top for 1-2 seconds", "Lower slowly — 3 seconds down"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Spider Curl",
            primaryMuscles: [.biceps], secondaryMuscles: [],
            equipment: [.dumbbell, .bench], difficulty: "Intermediate",
            exerciseDescription: "Lie face-down on an incline bench. Let arms hang straight down and curl dumbbells up. Gravity provides maximum resistance at the peak contraction — the opposite of incline curls.",
            formTips: ["Let arms hang vertically from the bench", "Curl up as high as possible", "Hold the peak contraction for 1 second", "Lower with a 3-second negative"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 130, jointStress: []
        ),
    ]

    // MARK: - Triceps

    static let triceps: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Close-Grip Bench Press",
            primaryMuscles: [.triceps], secondaryMuscles: [.chest, .shoulders],
            equipment: [.barbell, .bench], difficulty: "Intermediate",
            exerciseDescription: "Lie on a flat bench and grip the barbell with hands shoulder-width apart (or slightly narrower). Press the bar off your chest to full lockout. The narrower grip shifts emphasis from chest to triceps.",
            formTips: ["Grip shoulder-width or slightly narrower", "Keep elbows close to your body", "Touch the bar to your lower chest", "Lock out fully at the top"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 170, jointStress: ["elbows"]
        ),
        ExerciseTemplate(
            name: "Tricep Pushdown",
            primaryMuscles: [.triceps], secondaryMuscles: [],
            equipment: [.cable], difficulty: "Beginner",
            exerciseDescription: "Stand at a cable machine with a straight bar or rope at the top pulley. Push the attachment down until arms are fully extended, keeping elbows at your sides. The bread-and-butter tricep isolation exercise.",
            formTips: ["Keep elbows pinned to your sides", "Full extension at the bottom", "Don't lean forward — stand upright", "Control the return — don't let it snap back"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Overhead Tricep Extension",
            primaryMuscles: [.triceps], secondaryMuscles: [],
            equipment: [.dumbbell], difficulty: "Beginner",
            exerciseDescription: "Hold a dumbbell with both hands overhead. Lower it behind your head by bending at the elbows, then extend back up. This stretches the long head of the tricep under load — critical for overall tricep size.",
            formTips: ["Keep upper arms vertical and close to your ears", "Lower the dumbbell behind your head", "Don't flare elbows — keep them narrow", "Squeeze the triceps at the top"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 130, jointStress: ["elbows"]
        ),
        ExerciseTemplate(
            name: "Skull Crusher",
            primaryMuscles: [.triceps], secondaryMuscles: [],
            equipment: [.barbell, .bench], difficulty: "Intermediate",
            exerciseDescription: "Lie on a flat bench holding a barbell or EZ bar with arms extended over your chest. Bend at the elbows to lower the bar toward your forehead, then extend back up. High-tension isolation for all three tricep heads.",
            formTips: ["Keep upper arms vertical — only forearms move", "Lower to your forehead or just above", "Don't flare elbows outward", "Use an EZ bar for wrist comfort"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 140, jointStress: ["elbows"]
        ),
        ExerciseTemplate(
            name: "Tricep Dip",
            primaryMuscles: [.triceps], secondaryMuscles: [.chest, .shoulders],
            equipment: [.bodyweight], difficulty: "Intermediate",
            exerciseDescription: "Using parallel bars or a dip station, keep your torso upright (not leaning forward). Lower yourself until upper arms are parallel with the floor, then press back up. Keep body vertical to maximize tricep involvement.",
            formTips: ["Keep torso upright to target triceps over chest", "Lower until upper arms are parallel with the floor", "Keep elbows close to your body", "Full lockout at the top"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: ["shoulders", "elbows"]
        ),
        ExerciseTemplate(
            name: "Tricep Kickback",
            primaryMuscles: [.triceps], secondaryMuscles: [],
            equipment: [.dumbbell], difficulty: "Beginner",
            exerciseDescription: "Hinge forward at the hips with a dumbbell in one hand. Keep your upper arm parallel to your torso. Extend the forearm back until the arm is fully straight, then lower. Great for the lateral head and peak contraction.",
            formTips: ["Keep upper arm parallel to the floor", "Only the forearm should move", "Full extension — squeeze at the top", "Don't swing the dumbbell — strict reps"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 110, jointStress: []
        ),
        ExerciseTemplate(
            name: "Cable Overhead Extension",
            primaryMuscles: [.triceps], secondaryMuscles: [],
            equipment: [.cable], difficulty: "Beginner",
            exerciseDescription: "Attach a rope to a low cable pulley. Face away, hold the rope behind your head. Extend arms overhead while keeping elbows close to your ears. Cable tension keeps the long head of the tricep under constant load.",
            formTips: ["Face away from the cable machine", "Keep elbows close to your ears", "Full extension overhead", "Stagger your stance for stability"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["elbows"]
        ),
        ExerciseTemplate(
            name: "Bench Dip",
            primaryMuscles: [.triceps], secondaryMuscles: [.shoulders],
            equipment: [.bench, .bodyweight], difficulty: "Beginner",
            exerciseDescription: "Sit on the edge of a bench with hands next to your hips. Slide off the bench and lower yourself by bending your elbows, then push back up. Feet can be on the floor (easier) or elevated (harder).",
            formTips: ["Keep your back close to the bench", "Lower until elbows reach 90 degrees", "Don't drop your shoulders below your elbows", "Push through your palms to return"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["shoulders"]
        ),
    ]

    // MARK: - Quads

    static let quads: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Barbell Back Squat",
            primaryMuscles: [.quads], secondaryMuscles: [.glutes, .hamstrings, .core],
            equipment: [.barbell], difficulty: "Intermediate",
            exerciseDescription: "Place a barbell on your upper traps. Stand with feet shoulder-width apart. Bend at the hips and knees to lower yourself until thighs are parallel (or below), then drive back up. The king of all leg exercises.",
            formTips: ["Keep chest up and core braced throughout", "Push knees out in line with toes", "Descend until hip crease is below knee level", "Drive through your full foot — not just heels or toes"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 200, jointStress: ["knees", "back"]
        ),
        ExerciseTemplate(
            name: "Front Squat",
            primaryMuscles: [.quads], secondaryMuscles: [.glutes, .core],
            equipment: [.barbell], difficulty: "Advanced",
            exerciseDescription: "Rest the barbell on the front of your shoulders in a clean grip or cross-arm position. Squat down keeping an upright torso. The front-loaded position forces more quad involvement and a more upright spine.",
            formTips: ["Keep elbows high — upper arms parallel to the floor", "More upright torso than back squat", "Go as deep as your mobility allows", "If wrist flexibility is an issue, use the cross-arm grip"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 200, jointStress: ["knees", "wrists"]
        ),
        ExerciseTemplate(
            name: "Goblet Squat",
            primaryMuscles: [.quads], secondaryMuscles: [.glutes, .core],
            equipment: [.dumbbell, .kettlebell], difficulty: "Beginner",
            exerciseDescription: "Hold a dumbbell or kettlebell at your chest with both hands. Squat down between your knees until thighs are parallel, then stand back up. Perfect for learning squat mechanics and for those without a barbell.",
            formTips: ["Hold the weight tight against your chest", "Push your knees out over your toes", "Keep your elbows inside your knees at the bottom", "Stay upright — don't fold forward"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Bulgarian Split Squat",
            primaryMuscles: [.quads], secondaryMuscles: [.glutes, .hamstrings],
            equipment: [.dumbbell, .bench], difficulty: "Intermediate",
            exerciseDescription: "Stand in a lunge position with your rear foot elevated on a bench. Lower yourself until your front thigh is parallel to the floor, then drive back up. Unilateral work that crushes each leg independently.",
            formTips: ["Keep most of your weight on the front foot", "Front shin should stay relatively vertical", "Don't let your knee cave inward", "Lean slightly forward for more glute activation"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 170, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Leg Press",
            primaryMuscles: [.quads], secondaryMuscles: [.glutes, .hamstrings],
            equipment: [.machine], difficulty: "Beginner",
            exerciseDescription: "Sit in the leg press machine with feet shoulder-width apart on the platform. Push the platform away until legs are almost fully extended, then lower with control until knees reach 90 degrees.",
            formTips: ["Place feet shoulder-width apart on the platform", "Don't lock your knees at the top", "Lower until knees reach approximately 90 degrees", "Keep your lower back flat against the seat"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Leg Extension",
            primaryMuscles: [.quads], secondaryMuscles: [],
            equipment: [.machine], difficulty: "Beginner",
            exerciseDescription: "Sit in the leg extension machine with shins behind the pad. Extend your legs until fully straight, then lower with control. Pure quad isolation — especially targets the vastus medialis (inner quad/teardrop).",
            formTips: ["Adjust the pad to sit on your lower shin", "Extend fully and squeeze at the top", "Control the negative — 3 seconds down", "Don't use too much weight — this stresses the knee joint"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Walking Lunge",
            primaryMuscles: [.quads], secondaryMuscles: [.glutes, .hamstrings],
            equipment: [.dumbbell, .bodyweight], difficulty: "Beginner",
            exerciseDescription: "Step forward into a lunge, lowering your back knee toward the floor. Push off the front foot and step the back foot forward into the next lunge. Continue walking. Builds functional strength and balance.",
            formTips: ["Take long enough steps that both knees reach 90 degrees", "Keep torso upright", "Don't let front knee extend past your toes", "Push through the heel of the front foot"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Hack Squat",
            primaryMuscles: [.quads], secondaryMuscles: [.glutes],
            equipment: [.machine], difficulty: "Intermediate",
            exerciseDescription: "Stand on the hack squat machine platform with shoulders under the pads. Lower yourself until thighs are parallel, then press back up. The fixed path allows you to focus purely on quad contraction.",
            formTips: ["Place feet lower on the platform for more quad emphasis", "Lower until thighs are at least parallel", "Keep your back flat against the pad", "Push through the full foot"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 170, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Sissy Squat",
            primaryMuscles: [.quads], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Advanced",
            exerciseDescription: "Stand holding onto a support. Lean back while bending your knees, keeping a straight line from knees to shoulders. Lower until knees are deeply bent, then rise back up. Extreme quad isolation.",
            formTips: ["Hold onto something for balance", "Keep a straight line from knees to shoulders", "Rise up on your toes as you descend", "Don't go deeper than your knees can handle"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Step-Up",
            primaryMuscles: [.quads], secondaryMuscles: [.glutes],
            equipment: [.dumbbell, .bench], difficulty: "Beginner",
            exerciseDescription: "Stand facing a bench or box. Step up with one foot, driving through the heel to stand on top of the platform. Step back down with control. A functional unilateral exercise that builds strength and stability.",
            formTips: ["Use a box/bench at about knee height", "Drive through the heel of the working leg", "Don't push off the back foot — let the front leg do the work", "Keep torso upright throughout"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 140, jointStress: ["knees"]
        ),
    ]

    // MARK: - Hamstrings

    static let hamstrings: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Romanian Deadlift",
            primaryMuscles: [.hamstrings], secondaryMuscles: [.glutes, .back],
            equipment: [.barbell, .dumbbell], difficulty: "Intermediate",
            exerciseDescription: "Hold a barbell at hip height. Hinge at the hips pushing your butt back, lowering the bar along your legs until you feel a deep hamstring stretch. Keep legs nearly straight with a slight bend in the knees.",
            formTips: ["Push your hips back — don't bend your knees excessively", "Keep the bar/dumbbells close to your legs", "Lower until you feel a deep stretch in the hamstrings", "Squeeze glutes to return to standing"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 170, jointStress: ["back"]
        ),
        ExerciseTemplate(
            name: "Lying Leg Curl",
            primaryMuscles: [.hamstrings], secondaryMuscles: [],
            equipment: [.machine], difficulty: "Beginner",
            exerciseDescription: "Lie face-down on the leg curl machine with the pad behind your ankles. Curl your heels toward your glutes, then lower with control. The primary isolation exercise for the hamstrings.",
            formTips: ["Adjust pad to sit just above your heels", "Curl all the way up — squeeze at the top", "Don't lift your hips off the pad", "Control the negative — 3 seconds down"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Seated Leg Curl",
            primaryMuscles: [.hamstrings], secondaryMuscles: [],
            equipment: [.machine], difficulty: "Beginner",
            exerciseDescription: "Sit in the seated leg curl machine with the pad in front of your ankles. Press down, curling your heels toward the floor. The seated position provides a different stretch angle than the lying version.",
            formTips: ["Adjust the pad to sit on your lower shin", "Curl through the full range of motion", "Hold the contraction at the bottom for 1 second", "Don't let the weight stack touch between reps"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Good Morning",
            primaryMuscles: [.hamstrings], secondaryMuscles: [.glutes, .back],
            equipment: [.barbell], difficulty: "Advanced",
            exerciseDescription: "Place a barbell on your upper back (like a squat). With legs slightly bent, hinge at the hips and bow forward until your torso is nearly parallel to the floor. Stand back up by driving hips forward.",
            formTips: ["Keep a slight bend in the knees", "Hinge until torso is nearly parallel to the floor", "Keep the bar stable on your traps", "This is a hip hinge — not a squat"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: ["back"]
        ),
        ExerciseTemplate(
            name: "Nordic Hamstring Curl",
            primaryMuscles: [.hamstrings], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Advanced",
            exerciseDescription: "Kneel on the floor with someone holding your ankles (or hook them under something). Slowly lower yourself forward using your hamstrings to control the descent, then pull yourself back up. Elite-level hamstring exercise.",
            formTips: ["Keep your body straight from knees to shoulders", "Lower as slowly as possible", "Catch yourself with your hands if needed at the bottom", "Push off the floor to help with the concentric if you can't pull yourself up yet"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 140, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Dumbbell Stiff-Leg Deadlift",
            primaryMuscles: [.hamstrings], secondaryMuscles: [.glutes, .back],
            equipment: [.dumbbell], difficulty: "Intermediate",
            exerciseDescription: "Stand holding dumbbells in front of your thighs. With legs kept straighter than an RDL, hinge forward lowering the dumbbells toward the floor. Return to standing by squeezing hamstrings and glutes.",
            formTips: ["Keep legs straighter than a Romanian deadlift", "Lower dumbbells along the front of your legs", "Feel the stretch in your hamstrings before returning", "Don't round your lower back"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: ["back"]
        ),
        ExerciseTemplate(
            name: "Glute-Ham Raise",
            primaryMuscles: [.hamstrings], secondaryMuscles: [.glutes],
            equipment: [.machine], difficulty: "Advanced",
            exerciseDescription: "Set up on a GHD (glute-ham developer) with knees on the pad and feet against the foot plate. Lower your torso forward, then pull yourself back up using your hamstrings. One of the best hamstring exercises for strength and injury prevention.",
            formTips: ["Start with torso vertical, knees on the pad", "Lower forward with control", "Pull yourself back up using hamstrings, not lower back", "Keep your body in a straight line from knees to shoulders"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Swiss Ball Hamstring Curl",
            primaryMuscles: [.hamstrings], secondaryMuscles: [.glutes, .core],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Lie on your back with heels on a stability ball. Lift your hips off the floor and curl the ball toward your glutes. A great home exercise that combines hip extension with knee flexion.",
            formTips: ["Keep hips elevated throughout", "Curl the ball toward your glutes", "Squeeze hamstrings at the peak", "Extend legs slowly on the return"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
    ]

    // MARK: - Glutes

    static let glutes: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Hip Thrust",
            primaryMuscles: [.glutes], secondaryMuscles: [.hamstrings],
            equipment: [.barbell, .bench], difficulty: "Intermediate",
            exerciseDescription: "Sit on the floor with your upper back against a bench. Place a barbell across your hips. Drive through your heels to thrust your hips up until your body forms a straight line from shoulders to knees. The #1 glute builder.",
            formTips: ["Upper back rests against the bench edge", "Drive through your heels", "Squeeze glutes hard at the top — hold for 1 second", "Chin should be tucked — look forward at the top, not at the ceiling"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 160, jointStress: []
        ),
        ExerciseTemplate(
            name: "Glute Bridge",
            primaryMuscles: [.glutes], secondaryMuscles: [.hamstrings],
            equipment: [.bodyweight, .dumbbell], difficulty: "Beginner",
            exerciseDescription: "Lie on your back with knees bent and feet flat on the floor. Drive through your heels to lift your hips until your body forms a straight line from shoulders to knees. Squeeze glutes at the top.",
            formTips: ["Keep feet flat on the floor, about hip-width apart", "Drive through your heels", "Squeeze glutes at the top for 2-3 seconds", "Don't hyperextend your lower back"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Cable Pull-Through",
            primaryMuscles: [.glutes], secondaryMuscles: [.hamstrings],
            equipment: [.cable], difficulty: "Beginner",
            exerciseDescription: "Stand facing away from a low cable pulley with a rope between your legs. Hinge at the hips, then stand up straight by driving hips forward. A safer hip hinge pattern that's perfect for learning the movement.",
            formTips: ["Face away from the cable machine", "Hinge at the hips — push your butt back", "Stand up by squeezing glutes, not pulling with arms", "Keep arms relaxed — they just hold the rope"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 130, jointStress: []
        ),
        ExerciseTemplate(
            name: "Sumo Deadlift",
            primaryMuscles: [.glutes], secondaryMuscles: [.quads, .hamstrings, .back],
            equipment: [.barbell], difficulty: "Intermediate",
            exerciseDescription: "Stand with a wide stance and toes pointed out. Grip the bar with hands inside your legs. Drive through your feet to stand up. The wide stance increases glute activation compared to conventional deadlifts.",
            formTips: ["Stance should be wide — toes pointed out 30-45 degrees", "Push knees out over toes", "Keep chest up and back flat", "Drive through the whole foot to stand up"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 190, jointStress: ["hips", "back"]
        ),
        ExerciseTemplate(
            name: "Single-Leg Glute Bridge",
            primaryMuscles: [.glutes], secondaryMuscles: [.hamstrings, .core],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Lie on your back with one knee bent and foot on the floor. Extend the other leg up. Drive through the working foot to lift your hips, squeezing the glute at the top.",
            formTips: ["Keep your non-working leg extended or bent toward chest", "Don't rotate your hips — keep them level", "Squeeze the glute at the top for 2 seconds", "Lower with control"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 130, jointStress: []
        ),
        ExerciseTemplate(
            name: "Cable Kickback",
            primaryMuscles: [.glutes], secondaryMuscles: [],
            equipment: [.cable], difficulty: "Beginner",
            exerciseDescription: "Attach an ankle cuff to a low cable. Face the machine, kick one leg straight back while keeping your body stable. Squeeze the glute at full extension. Great isolation work for the glute max.",
            formTips: ["Keep a slight bend in the standing leg", "Don't arch your lower back", "Kick straight back — not to the side", "Squeeze the glute at the top for 1-2 seconds"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
    ]

    // MARK: - Calves

    static let calves: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Standing Calf Raise",
            primaryMuscles: [.calves], secondaryMuscles: [],
            equipment: [.machine, .barbell], difficulty: "Beginner",
            exerciseDescription: "Stand on a raised platform with the balls of your feet on the edge. Rise up on your toes as high as possible, then lower your heels below the platform for a full stretch. The primary calf mass builder.",
            formTips: ["Full range of motion — deep stretch at the bottom, high on toes at the top", "Hold the peak contraction for 1-2 seconds", "Don't bounce — smooth controlled reps", "Keep knees slightly bent to avoid hyperextension"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 110, jointStress: ["ankles"]
        ),
        ExerciseTemplate(
            name: "Seated Calf Raise",
            primaryMuscles: [.calves], secondaryMuscles: [],
            equipment: [.machine], difficulty: "Beginner",
            exerciseDescription: "Sit in the seated calf raise machine with the pad on your lower thighs. Rise up on your toes, then lower for a full stretch. The seated position targets the soleus muscle (deeper calf muscle) more than standing variations.",
            formTips: ["Adjust the pad so it sits on your lower thigh", "Full stretch at the bottom", "Pause at the top for 2 seconds", "Use a 3-second negative"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 110, jointStress: []
        ),
        ExerciseTemplate(
            name: "Single-Leg Calf Raise",
            primaryMuscles: [.calves], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Stand on one foot on the edge of a step. Rise up on your toes as high as possible, then lower below the step for a deep stretch. Hold onto something for balance. Unilateral work for calf development.",
            formTips: ["Use full range of motion", "Hold the contraction at the top for 2 seconds", "Lower slowly — 3 seconds down", "Hold something for balance"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["ankles"]
        ),
    ]

    // MARK: - Core

    static let core: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Plank",
            primaryMuscles: [.core], secondaryMuscles: [.shoulders],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Support yourself on your forearms and toes, body in a straight line from head to heels. Hold this position. The foundational core stability exercise — trains the deep stabilizers of the trunk.",
            formTips: ["Keep body in a straight line — no sagging or piking", "Engage your core by pulling belly button to spine", "Keep breathing — don't hold your breath", "Squeeze glutes to maintain position"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "Hanging Leg Raise",
            primaryMuscles: [.core], secondaryMuscles: [],
            equipment: [.pullupBar], difficulty: "Intermediate",
            exerciseDescription: "Hang from a pull-up bar with arms straight. Raise your legs until they're parallel to the floor (or higher), then lower with control. One of the most effective exercises for lower abs.",
            formTips: ["Don't swing — controlled movement", "Raise legs to at least parallel with the floor", "Lower slowly — don't drop your legs", "Tilt your pelvis posteriorly to maximize ab engagement"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Cable Woodchop",
            primaryMuscles: [.core], secondaryMuscles: [],
            equipment: [.cable], difficulty: "Intermediate",
            exerciseDescription: "Set a cable at shoulder height. Stand sideways to the machine and pull the handle diagonally across your body from high to low (or low to high). Trains rotational core strength essential for sports and daily life.",
            formTips: ["Rotate through your torso, not your arms", "Keep arms relatively straight", "Control the return — don't let the cable snap back", "Keep feet planted and rotate from the core"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Ab Wheel Rollout",
            primaryMuscles: [.core], secondaryMuscles: [.shoulders],
            equipment: [.bodyweight], difficulty: "Advanced",
            exerciseDescription: "Kneel on the floor holding an ab wheel. Roll forward, extending your body as far as you can while keeping your core tight. Pull yourself back to the starting position. Extremely high core activation.",
            formTips: ["Start on your knees", "Keep your core tight throughout — don't let your hips sag", "Extend as far as you can control", "Pull back by contracting your abs, not your hip flexors"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: []
        ),
        ExerciseTemplate(
            name: "Russian Twist",
            primaryMuscles: [.core], secondaryMuscles: [],
            equipment: [.bodyweight, .dumbbell], difficulty: "Beginner",
            exerciseDescription: "Sit on the floor with knees bent and feet slightly elevated. Lean back slightly and rotate your torso from side to side, optionally holding a weight. Targets the obliques and rotational core muscles.",
            formTips: ["Lean back about 45 degrees", "Rotate from the torso, not just the arms", "Touch the floor on each side", "Keep feet elevated for added difficulty"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 100, jointStress: []
        ),
        ExerciseTemplate(
            name: "Dead Bug",
            primaryMuscles: [.core], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Lie on your back with arms extended toward the ceiling and knees bent at 90 degrees. Slowly extend one arm and the opposite leg while pressing your lower back into the floor. Return and repeat on the other side.",
            formTips: ["Press your lower back firmly into the floor", "Move slowly — speed is not the goal", "Extend the arm and opposite leg simultaneously", "Breathe out as you extend"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 100, jointStress: []
        ),
        ExerciseTemplate(
            name: "Bicycle Crunch",
            primaryMuscles: [.core], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Lie on your back with hands behind your head. Bring one knee toward your chest while rotating your opposite elbow to meet it. Alternate sides in a pedaling motion. Excellent for oblique activation.",
            formTips: ["Don't pull on your neck", "Fully rotate — elbow to opposite knee", "Extend the non-working leg fully", "Slow and controlled — not fast"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 90, jointStress: []
        ),
        ExerciseTemplate(
            name: "Pallof Press",
            primaryMuscles: [.core], secondaryMuscles: [],
            equipment: [.cable, .resistanceBand], difficulty: "Beginner",
            exerciseDescription: "Stand sideways to a cable machine, holding the handle at your chest. Press the handle straight out in front of you, resisting the cable's pull to rotate you. Hold, then return. The gold standard for anti-rotation core training.",
            formTips: ["Stand far enough from the machine to feel tension", "Press straight out from your chest", "Hold the extended position for 2-3 seconds", "Don't let the cable rotate your body"],
            isCompound: false, baseCategory: .main, estimatedDurationSeconds: 100, jointStress: []
        ),
        ExerciseTemplate(
            name: "Mountain Climber",
            primaryMuscles: [.core], secondaryMuscles: [.shoulders, .quads],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Start in a push-up position. Drive one knee toward your chest, then quickly switch legs. Alternates rapidly. Combines core stability with cardiovascular conditioning.",
            formTips: ["Keep hips level — don't pike up", "Drive knees toward your chest", "Maintain a strong plank position", "Can be done slowly for core focus or fast for cardio"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 60, jointStress: []
        ),
    ]

    // MARK: - Full Body

    static let fullBody: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Kettlebell Swing",
            primaryMuscles: [.glutes, .hamstrings], secondaryMuscles: [.core, .shoulders, .back],
            equipment: [.kettlebell], difficulty: "Intermediate",
            exerciseDescription: "Stand with feet shoulder-width apart, kettlebell between your feet. Hinge at the hips to grab the bell, then drive your hips forward explosively to swing it to chest height. The bell should float — you're not lifting it with your arms.",
            formTips: ["This is a hip hinge, not a squat", "Drive your hips forward explosively", "Let the bell float — arms are just along for the ride", "Squeeze glutes hard at the top"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["back"]
        ),
        ExerciseTemplate(
            name: "Thruster",
            primaryMuscles: [.quads, .shoulders], secondaryMuscles: [.glutes, .triceps, .core],
            equipment: [.barbell, .dumbbell], difficulty: "Intermediate",
            exerciseDescription: "Hold a barbell or dumbbells at shoulder height. Squat down, then drive up explosively and press the weight overhead in one fluid movement. The ultimate full-body compound exercise.",
            formTips: ["Squat to full depth", "Drive up explosively from the squat", "Use the momentum from the squat to help the press", "Lock out overhead before lowering"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: ["knees", "shoulders"]
        ),
        ExerciseTemplate(
            name: "Clean and Press",
            primaryMuscles: [.shoulders, .back], secondaryMuscles: [.quads, .glutes, .core, .biceps],
            equipment: [.barbell, .dumbbell], difficulty: "Advanced",
            exerciseDescription: "Start with the weight on the floor. Pull it explosively to your shoulders (the clean), then press overhead. Lower to shoulders and back to the floor. Builds total body power and coordination.",
            formTips: ["Start with the weight near your shins", "Explode through the hips to clean the weight", "Catch at your shoulders in a front rack position", "Press overhead with control"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 180, jointStress: ["back", "shoulders", "wrists"]
        ),
        ExerciseTemplate(
            name: "Burpee",
            primaryMuscles: [.fullBody], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Intermediate",
            exerciseDescription: "From standing, squat down and place hands on the floor. Jump feet back to a push-up position, perform a push-up, jump feet back to squat position, then jump up explosively. Maximum calorie burn and total body conditioning.",
            formTips: ["Maintain proper push-up form — don't sag", "Land softly when jumping back", "Explode upward on the jump", "Scale by stepping instead of jumping if needed"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 90, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "Turkish Get-Up",
            primaryMuscles: [.core, .shoulders], secondaryMuscles: [.glutes, .quads],
            equipment: [.kettlebell, .dumbbell], difficulty: "Advanced",
            exerciseDescription: "Lie on your back holding a weight above your shoulder. Stand up through a series of movements while keeping the weight overhead the entire time, then reverse to lie back down. Builds total body stability and mobility.",
            formTips: ["Keep your eyes on the weight at all times", "Move slowly and deliberately through each position", "The arm should stay locked out overhead", "Practice without weight first to learn the pattern"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 120, jointStress: ["shoulders"]
        ),
        ExerciseTemplate(
            name: "Man Maker",
            primaryMuscles: [.fullBody], secondaryMuscles: [],
            equipment: [.dumbbell], difficulty: "Advanced",
            exerciseDescription: "Start in a push-up position holding dumbbells. Perform a push-up, row each dumbbell, jump feet to hands, clean the dumbbells, and press overhead. One of the most demanding full-body exercises.",
            formTips: ["Control the push-up — don't rush", "Row each dumbbell without rotating your hips", "Jump feet wide to squat position", "Use the momentum to clean and press"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 150, jointStress: ["shoulders", "knees"]
        ),
        ExerciseTemplate(
            name: "Farmer's Walk",
            primaryMuscles: [.core], secondaryMuscles: [.shoulders, .back, .glutes],
            equipment: [.dumbbell, .kettlebell], difficulty: "Beginner",
            exerciseDescription: "Hold heavy dumbbells or kettlebells at your sides. Walk with control for a set distance or time. Builds grip strength, core stability, and total body conditioning simultaneously.",
            formTips: ["Stand tall — chest up, shoulders back", "Take short, controlled steps", "Keep the weights from swinging", "Breathe steadily — don't hold your breath"],
            isCompound: true, baseCategory: .main, estimatedDurationSeconds: 60, jointStress: []
        ),
    ]

    // MARK: - Warmups

    static let warmups: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Jumping Jacks",
            primaryMuscles: [.fullBody], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Start standing with arms at your sides. Jump while spreading your legs and raising arms overhead. Jump back to the starting position. A classic warm-up to elevate heart rate and loosen up the whole body.",
            formTips: ["Land softly on the balls of your feet", "Full arm extension overhead", "Maintain a steady rhythm", "Start slow and increase pace"],
            isCompound: true, baseCategory: .warmup, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "Arm Circles",
            primaryMuscles: [.shoulders], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Stand with arms extended to the sides. Make small circles, gradually increasing to larger circles. Reverse direction. Warms up the shoulder joint and activates the rotator cuff muscles.",
            formTips: ["Start with small circles", "Gradually increase circle size", "Reverse direction halfway through", "Keep arms at shoulder height"],
            isCompound: false, baseCategory: .warmup, estimatedDurationSeconds: 45, jointStress: []
        ),
        ExerciseTemplate(
            name: "Hip Circles",
            primaryMuscles: [.glutes], secondaryMuscles: [.core],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Stand on one leg and draw large circles with the other knee. This warms up the hip joint, activates the glutes, and improves hip mobility. Essential before any lower body workout.",
            formTips: ["Hold onto something for balance if needed", "Make large, smooth circles", "Do both directions", "10 circles each direction per leg"],
            isCompound: false, baseCategory: .warmup, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "Bodyweight Squat",
            primaryMuscles: [.quads, .glutes], secondaryMuscles: [.core],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Stand with feet shoulder-width apart. Squat down until thighs are parallel to the floor, then stand back up. Without any load, this warms up the knees, hips, and ankles for heavier work.",
            formTips: ["Keep weight on your full foot", "Push knees out over toes", "Go to full depth", "Control both the descent and ascent"],
            isCompound: true, baseCategory: .warmup, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "Inchworm",
            primaryMuscles: [.core, .hamstrings], secondaryMuscles: [.shoulders],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "From standing, bend forward and walk your hands out to a plank position. Hold briefly, then walk your feet toward your hands and stand up. Warms up the entire posterior chain and shoulders.",
            formTips: ["Keep legs as straight as possible when walking hands out", "Hold the plank position for 2 seconds", "Walk feet toward hands with small steps", "Stand up fully between each rep"],
            isCompound: true, baseCategory: .warmup, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "Band Pull-Apart",
            primaryMuscles: [.shoulders, .back], secondaryMuscles: [],
            equipment: [.resistanceBand], difficulty: "Beginner",
            exerciseDescription: "Hold a resistance band at arm's length in front of you. Pull the band apart by squeezing your shoulder blades together until the band touches your chest. Warms up the rear delts and scapular muscles.",
            formTips: ["Keep arms at shoulder height", "Squeeze shoulder blades together", "Control the return — don't let the band snap back", "15-20 reps is ideal for warm-up"],
            isCompound: false, baseCategory: .warmup, estimatedDurationSeconds: 45, jointStress: []
        ),
        ExerciseTemplate(
            name: "Cat-Cow Stretch",
            primaryMuscles: [.core, .back], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Start on all fours. Alternate between arching your back (cow) and rounding it (cat). This rhythmic movement warms up the spine, relieves tension, and improves spinal mobility.",
            formTips: ["Move slowly through each position", "Breathe in during cow, out during cat", "Initiate the movement from your pelvis", "Hold each position for 2-3 seconds"],
            isCompound: false, baseCategory: .warmup, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "Leg Swing",
            primaryMuscles: [.hamstrings, .quads], secondaryMuscles: [.glutes],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Hold onto something for support. Swing one leg forward and backward in a controlled motion. Then swing laterally (side to side). Dynamically warms up the hip flexors, hamstrings, and adductors.",
            formTips: ["Start with small swings and increase range", "Keep your standing leg slightly bent", "Do forward/back and side-to-side", "10-15 swings per direction per leg"],
            isCompound: false, baseCategory: .warmup, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "High Knees",
            primaryMuscles: [.quads, .core], secondaryMuscles: [.calves],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Run in place, driving your knees as high as possible. Pump your arms in sync with your legs. Rapidly elevates heart rate and warms up the entire lower body.",
            formTips: ["Drive knees to hip height", "Land on the balls of your feet", "Pump arms to increase intensity", "Maintain an upright posture"],
            isCompound: true, baseCategory: .warmup, estimatedDurationSeconds: 45, jointStress: ["knees"]
        ),
        ExerciseTemplate(
            name: "World's Greatest Stretch",
            primaryMuscles: [.hamstrings, .glutes], secondaryMuscles: [.shoulders, .core],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Step into a deep lunge. Place the same-side hand on the floor and rotate the other arm to the sky. Return and switch sides. This comprehensive stretch hits the hip flexors, hamstrings, thoracic spine, and shoulders.",
            formTips: ["Start in a deep lunge position", "Place one hand on the floor inside your front foot", "Rotate the other arm to the ceiling", "Hold the rotation for 2-3 seconds"],
            isCompound: true, baseCategory: .warmup, estimatedDurationSeconds: 90, jointStress: []
        ),
    ]

    // MARK: - Cooldowns

    static let cooldowns: [ExerciseTemplate] = [
        ExerciseTemplate(
            name: "Standing Hamstring Stretch",
            primaryMuscles: [.hamstrings], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Stand and place one heel on an elevated surface. Keep that leg straight and hinge forward from the hips until you feel a stretch in the back of your thigh. Hold for 30 seconds each side.",
            formTips: ["Keep the stretching leg straight", "Hinge from the hips — don't round your back", "Hold for 30 seconds per side", "Breathe deeply and relax into the stretch"],
            isCompound: false, baseCategory: .cooldown, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "Chest Doorway Stretch",
            primaryMuscles: [.chest], secondaryMuscles: [.shoulders],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Stand in a doorway with your forearm on the frame at shoulder height. Lean forward until you feel a stretch across your chest. Hold for 30 seconds each side. Counteracts the tightness from pressing movements.",
            formTips: ["Place forearm against the door frame", "Step through the doorway", "Keep elbow at shoulder height", "Hold 30 seconds per side"],
            isCompound: false, baseCategory: .cooldown, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "Quad Stretch",
            primaryMuscles: [.quads], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Stand on one leg, pull the other foot behind you toward your glute. Hold the foot with the same-side hand. You should feel a stretch along the front of your thigh. Hold for 30 seconds each side.",
            formTips: ["Hold onto something for balance", "Keep knees together", "Push your hips slightly forward for a deeper stretch", "Hold 30 seconds per side"],
            isCompound: false, baseCategory: .cooldown, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "Child's Pose",
            primaryMuscles: [.back], secondaryMuscles: [.shoulders],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Kneel on the floor, sit back on your heels, and stretch your arms forward on the floor. Rest your forehead on the ground. This gently stretches the lower back, lats, and shoulders while promoting relaxation.",
            formTips: ["Sit your hips back toward your heels", "Reach arms forward as far as possible", "Rest your forehead on the floor", "Breathe deeply and hold for 30-60 seconds"],
            isCompound: false, baseCategory: .cooldown, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "Pigeon Stretch",
            primaryMuscles: [.glutes], secondaryMuscles: [.hamstrings],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "From a plank or all-fours position, bring one knee forward and place it behind your wrist. Extend the other leg behind you. Lower your torso toward the floor. Deep stretch for the glutes and hip rotators.",
            formTips: ["Bring your shin as parallel to the front of the mat as possible", "Keep hips level and squared", "Fold forward for a deeper stretch", "Hold 30-60 seconds per side"],
            isCompound: false, baseCategory: .cooldown, estimatedDurationSeconds: 60, jointStress: ["hips"]
        ),
        ExerciseTemplate(
            name: "Seated Spinal Twist",
            primaryMuscles: [.core, .back], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Sit on the floor with one leg extended. Cross the other foot over and place it outside the extended knee. Rotate your torso toward the bent knee. Releases tension in the spine and obliques.",
            formTips: ["Sit up tall — don't slouch", "Use your arm to deepen the twist", "Look over the shoulder you're rotating toward", "Hold 30 seconds per side"],
            isCompound: false, baseCategory: .cooldown, estimatedDurationSeconds: 60, jointStress: []
        ),
        ExerciseTemplate(
            name: "Shoulder Cross-Body Stretch",
            primaryMuscles: [.shoulders], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Bring one arm across your chest at shoulder height. Use the other hand to gently pull it closer to your body. Stretches the posterior deltoid and helps maintain shoulder mobility.",
            formTips: ["Keep the arm at shoulder height", "Pull gently — don't force it", "Hold for 20-30 seconds per side", "Keep your torso facing forward — don't rotate"],
            isCompound: false, baseCategory: .cooldown, estimatedDurationSeconds: 45, jointStress: []
        ),
        ExerciseTemplate(
            name: "Deep Breathing",
            primaryMuscles: [.core], secondaryMuscles: [],
            equipment: [.bodyweight], difficulty: "Beginner",
            exerciseDescription: "Sit or lie down comfortably. Breathe in through your nose for 4 seconds, hold for 4 seconds, exhale through your mouth for 6 seconds. Activates the parasympathetic nervous system to accelerate recovery.",
            formTips: ["Breathe from your diaphragm — belly should expand", "Inhale through nose, exhale through mouth", "4 seconds in, 4 hold, 6 out", "5-10 breath cycles"],
            isCompound: false, baseCategory: .cooldown, estimatedDurationSeconds: 90, jointStress: []
        ),
    ]

    // MARK: - Filtering

    static func exercises(for muscles: [MuscleGroup], equipment: Set<EquipmentType>, difficulty: String?, category: ExerciseCategory = .main, excludeJoints: [String] = []) -> [ExerciseTemplate] {
        all.filter { template in
            guard template.baseCategory == category else { return false }
            let muscleMatch = template.primaryMuscles.contains(where: { muscles.contains($0) })
            guard muscleMatch else { return false }
            let equipmentMatch = template.equipment.isEmpty || template.equipment.contains(where: { equipment.contains($0) })
            guard equipmentMatch else { return false }
            if let diff = difficulty {
                let diffOrder = ["Beginner": 0, "Intermediate": 1, "Advanced": 2]
                let templateLevel = diffOrder[template.difficulty] ?? 1
                let maxLevel = diffOrder[diff] ?? 1
                guard templateLevel <= maxLevel else { return false }
            }
            if !excludeJoints.isEmpty {
                let hasConflict = template.jointStress.contains(where: { joint in
                    excludeJoints.contains(where: { $0.lowercased() == joint.lowercased() })
                })
                if hasConflict { return false }
            }
            return true
        }
    }

    static func warmupExercises(equipment: Set<EquipmentType>, excludeJoints: [String] = []) -> [ExerciseTemplate] {
        warmups.filter { template in
            let equipmentMatch = template.equipment.isEmpty || template.equipment.allSatisfy({ $0 == .bodyweight || $0 == .resistanceBand }) || template.equipment.contains(where: { equipment.contains($0) })
            if !excludeJoints.isEmpty {
                let hasConflict = template.jointStress.contains(where: { joint in
                    excludeJoints.contains(where: { $0.lowercased() == joint.lowercased() })
                })
                if hasConflict { return false }
            }
            return equipmentMatch
        }
    }

    static func cooldownExercises(muscles: [MuscleGroup]) -> [ExerciseTemplate] {
        cooldowns.filter { template in
            template.primaryMuscles.contains(where: { muscles.contains($0) }) || template.primaryMuscles.contains(.core) || template.primaryMuscles.contains(.back)
        }
    }
}
