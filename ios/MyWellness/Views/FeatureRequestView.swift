import SwiftUI

struct FeatureRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = FeatureRequestStore()
    @State private var searchText: String = ""
    @State private var selectedFilter: FeatureRequestStore.SortFilter = .popular
    @State private var showSubmit = false

    private var filtered: [FeatureRequest] {
        let sorted = store.sorted(by: selectedFilter)
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty { return sorted }
        let q = searchText.lowercased()
        return sorted.filter {
            $0.title.lowercased().contains(q) ||
            $0.description.lowercased().contains(q) ||
            $0.category.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar(title: Lang.s("request_feature_title"), onBack: { dismiss() })

            searchBar

            filterPills

            if filtered.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filtered) { request in
                            FeatureRequestCard(request: request, store: store)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .bottom) {
            submitButton
        }
        .sheet(isPresented: $showSubmit) {
            SubmitFeatureSheet(store: store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField(Lang.s("search_feature"), text: $searchText)
                .font(.subheadline)
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FeatureRequestStore.SortFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.localizedName)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedFilter == filter ? Color.wellnessTeal : Color(.systemBackground))
                            .foregroundStyle(selectedFilter == filter ? .white : .secondary)
                            .clipShape(.capsule)
                            .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text(Lang.s("no_results"))
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(Lang.s("no_results_desc"))
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    private var submitButton: some View {
        Button {
            showSubmit = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.body.weight(.semibold))
                Text(Lang.s("suggest_feature"))
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.wellnessTeal)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.wellnessTeal.opacity(0.35), radius: 12, y: 4)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
        .background(
            LinearGradient(
                colors: [Color(.systemGroupedBackground).opacity(0), Color(.systemGroupedBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            .allowsHitTesting(false),
            alignment: .top
        )
    }
}

// MARK: - Card

private struct FeatureRequestCard: View {
    let request: FeatureRequest
    let store: FeatureRequestStore
    @State private var bouncing = false

    private var voted: Bool { store.hasVoted(for: request.id) }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            voteButton
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    statusBadge
                    Spacer()
                    categoryChip
                }
                Text(request.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(request.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var voteButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                bouncing = true
                store.vote(for: request.id)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                bouncing = false
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(voted ? Color.wellnessTeal : Color(.systemGray3))
                    .scaleEffect(bouncing ? 1.3 : 1.0)
                Text("\(request.votes)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(voted ? Color.wellnessTeal : .secondary)
                    .contentTransition(.numericText())
            }
            .frame(width: 44)
            .padding(.vertical, 10)
            .background(voted ? Color.wellnessTeal.opacity(0.1) : Color(.systemGray6))
            .clipShape(.rect(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: request.status.icon)
                .font(.system(size: 9, weight: .semibold))
            Text(request.status.rawValue)
                .font(.system(size: 10, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.12))
        .foregroundStyle(statusColor)
        .clipShape(.capsule)
    }

    private var categoryChip: some View {
        Text(request.category)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            .clipShape(.capsule)
    }

    private var statusColor: Color {
        switch request.status {
        case .review: return .gray
        case .planned: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        }
    }
}

// MARK: - Submit Sheet

private struct SubmitFeatureSheet: View {
    let store: FeatureRequestStore
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: String = "cat_general"
    @State private var submitted = false

    private let categoryKeys = ["cat_general", "cat_nutrition", "cat_training", "cat_health", "cat_integrations", "widget", "cat_social", "cat_statistics", "cat_design"]

    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text(Lang.s("suggest_feature"))
                    .font(.title3.weight(.bold))
                Text(Lang.s("community_votes"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Lang.s("title_label"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                        TextField(Lang.s("title_placeholder"), text: $title)
                            .font(.subheadline)
                            .padding(14)
                            .background(Color(.systemBackground))
                            .clipShape(.rect(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(.systemGray5), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(Lang.s("description_label"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                        TextEditor(text: $description)
                            .font(.subheadline)
                            .frame(minHeight: 100)
                            .padding(10)
                            .background(Color(.systemBackground))
                            .clipShape(.rect(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(.systemGray5), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(Lang.s("category_label"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                            ForEach(categoryKeys, id: \.self) { catKey in
                                Button {
                                    selectedCategory = catKey
                                } label: {
                                    Text(Lang.s(catKey))
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(selectedCategory == catKey ? Color.wellnessTeal : Color(.systemBackground))
                                        .foregroundStyle(selectedCategory == catKey ? .white : .secondary)
                                        .clipShape(.rect(cornerRadius: 10, style: .continuous))
                                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color(.systemGray5), lineWidth: selectedCategory == catKey ? 0 : 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }

            Button {
                guard canSubmit else { return }
                store.submit(title: title, description: description, category: selectedCategory)
                submitted = true
                Task {
                    try? await Task.sleep(for: .seconds(0.8))
                    dismiss()
                }
            } label: {
                HStack(spacing: 8) {
                    if submitted {
                        Image(systemName: "checkmark.circle.fill")
                        Text(Lang.s("submitted"))
                    } else {
                        Image(systemName: "paperplane.fill")
                        Text(Lang.s("submit_request"))
                    }
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canSubmit ? (submitted ? Color.green : Color.wellnessTeal) : Color(.systemGray4))
                .clipShape(.rect(cornerRadius: 16, style: .continuous))
            }
            .disabled(!canSubmit || submitted)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .animation(.spring(response: 0.3), value: submitted)
    }
}
