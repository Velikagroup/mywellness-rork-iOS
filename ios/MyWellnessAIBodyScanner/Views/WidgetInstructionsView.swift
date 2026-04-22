import SwiftUI

struct WidgetInstructionsView: View {
    @Environment(\.dismiss) private var dismiss

    private var steps: [(icon: String, text: String)] {
        [
            ("hand.tap.fill", Lang.s("widget_step_1")),
            ("plus.circle.fill", Lang.s("widget_step_2")),
            ("magnifyingglass", Lang.s("widget_step_3")),
            ("hand.draw.fill", Lang.s("widget_step_4")),
            ("checkmark.circle.fill", Lang.s("widget_step_5"))
        ]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "square.grid.3x3.topleft.filled")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.wellnessTeal)
                    .padding(.top, 8)

                Text(Lang.s("widget_add_title"))
                    .font(.title2.bold())

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.wellnessTeal.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                Text("\(index + 1)")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.wellnessTeal)
                            }

                            Text(step.text)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("close")) { dismiss() }
                }
            }
        }
    }
}
