import SwiftUI

struct RingColorsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            headerBar(title: "Colori degli anelli", onBack: { dismiss() })

            ScrollView {
                VStack(spacing: 20) {
                    ringExplanation(
                        color: .red,
                        title: "Calorie",
                        description: "Mostra le calorie consumate rispetto al tuo obiettivo giornaliero."
                    )
                    ringExplanation(
                        color: Color.wellnessTeal,
                        title: "Proteine",
                        description: "Registra l'assunzione di proteine rispetto al tuo obiettivo."
                    )
                    ringExplanation(
                        color: .orange,
                        title: "Carboidrati",
                        description: "Mostra i carboidrati consumati rispetto al tuo obiettivo."
                    )
                    ringExplanation(
                        color: .purple,
                        title: "Grassi",
                        description: "Mostra l'assunzione di grassi rispetto al tuo limite giornaliero."
                    )
                    ringExplanation(
                        color: .blue,
                        title: "Attività",
                        description: "Rappresenta le calorie bruciate tramite movimento ed esercizio."
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private func ringExplanation(color: Color, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
                    .frame(width: 48, height: 48)
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}
