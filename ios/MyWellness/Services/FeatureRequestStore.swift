import Foundation
import SwiftUI

@Observable
final class FeatureRequestStore {
    private(set) var requests: [FeatureRequest] = []
    private(set) var votedIDs: Set<UUID> = []

    private let requestsKey = "featureRequests_v2"
    private let votedKey = "featureRequestVotedIDs_v2"

    init() {
        load()
    }

    func vote(for id: UUID) {
        guard let idx = requests.firstIndex(where: { $0.id == id }) else { return }
        if votedIDs.contains(id) {
            votedIDs.remove(id)
            requests[idx].votes = max(0, requests[idx].votes - 1)
        } else {
            votedIDs.insert(id)
            requests[idx].votes += 1
        }
        save()
    }

    func hasVoted(for id: UUID) -> Bool {
        votedIDs.contains(id)
    }

    func submit(title: String, description: String, category: String) {
        let new = FeatureRequest(
            title: title,
            description: description,
            votes: 1,
            status: .review,
            category: category
        )
        requests.insert(new, at: 0)
        votedIDs.insert(new.id)
        save()
    }

    func sorted(by filter: SortFilter) -> [FeatureRequest] {
        switch filter {
        case .popular:
            return requests.sorted { $0.votes > $1.votes }
        case .newest:
            return requests.sorted { $0.createdAt > $1.createdAt }
        case .planned:
            return requests.filter { $0.status == .planned || $0.status == .inProgress }
                .sorted { $0.votes > $1.votes }
        case .completed:
            return requests.filter { $0.status == .completed }
                .sorted { $0.votes > $1.votes }
        }
    }

    enum SortFilter: String, CaseIterable {
        case popular = "filter_popular"
        case newest = "filter_newest"
        case planned = "filter_planned"
        case completed = "filter_completed"

        var localizedName: String { Lang.s(rawValue) }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(requests) {
            UserDefaults.standard.set(data, forKey: requestsKey)
        }
        let votedArray = Array(votedIDs.map { $0.uuidString })
        UserDefaults.standard.set(votedArray, forKey: votedKey)
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: requestsKey),
           let decoded = try? JSONDecoder().decode([FeatureRequest].self, from: data) {
            requests = decoded
        }
        if let strings = UserDefaults.standard.stringArray(forKey: votedKey) {
            votedIDs = Set(strings.compactMap { UUID(uuidString: $0) })
        }
    }


}
