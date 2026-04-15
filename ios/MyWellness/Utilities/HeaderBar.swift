import SwiftUI

func headerBar(title: String?, onBack: @escaping () -> Void) -> some View {
    HStack {
        Button(action: onBack) {
            Image(systemName: "arrow.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }

        Spacer()

        if let title {
            Text(title)
                .font(.subheadline.weight(.semibold))
        }

        Spacer()

        Color.clear.frame(width: 40, height: 40)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
}
