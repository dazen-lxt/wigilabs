//
//  VoteHistoryView.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import SwiftUI
import SwiftData

struct VoteHistoryView: View {
    @Query(sort: \VoteRecord.date, order: .reverse) private var votes: [VoteRecord]
    @Environment(\.dismiss) private var dismiss

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        Group {
            if votes.isEmpty {
                ContentUnavailableView(
                    "history.empty.title",
                    systemImage: "hand.thumbsup",
                    description: Text("history.empty.description")
                )
            } else {
                List(votes) { vote in
                    VoteHistoryRow(vote: vote, dateFormatter: Self.dateFormatter)
                }
            }
        }
        .navigationTitle("history.title")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("history.close") { dismiss() }
            }
        }
    }
}

private struct VoteHistoryRow: View {
    let vote: VoteRecord
    let dateFormatter: DateFormatter

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(vote.breedName)
                    .font(.headline)
                Text(dateFormatter.string(from: vote.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Label(vote.voteType.label, systemImage: vote.voteType == .like ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                .foregroundStyle(vote.voteType == .like ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}
