//
//  VotingView.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import SwiftUI
import SwiftData

struct VotingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: VotingViewModel?
    @State private var showHistory = false

    var body: some View {
        Group {
            if let viewModel {
                content(for: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("voting.title")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("voting.history") { showHistory = true }
            }
        }
        .sheet(isPresented: $showHistory) {
            NavigationStack {
                VoteHistoryView()
            }
        }
        .task {
            guard viewModel == nil else { return }
            let apiService = CatAPIService()
            let voteStore = VoteStore(context: modelContext)
            let repository = VotingRepository(apiService: apiService, voteStore: voteStore)
            let newViewModel = VotingViewModel(repository: repository)
            viewModel = newViewModel
            newViewModel.loadBreedsIfNeeded()
        }
    }

    @ViewBuilder
    private func content(for viewModel: VotingViewModel) -> some View {
        VStack(spacing: 24) {
            breedImage(for: viewModel)

            Text(viewModel.currentBreed?.name ?? " ")
                .font(.title2)
                .fontWeight(.semibold)

            if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("common.retry") { viewModel.retry() }
                        .buttonStyle(.bordered)
                }
            } else {
                voteButtons(for: viewModel)
            }

            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    private func breedImage(for viewModel: VotingViewModel) -> some View {
        if let image = viewModel.currentImage, let url = URL(string: image.url) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 280, maxHeight: 320)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(.quaternary)
                .frame(maxWidth: .infinity, minHeight: 280, maxHeight: 320)
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
        }
    }

    private func voteButtons(for viewModel: VotingViewModel) -> some View {
        HStack(spacing: 32) {
            Button {
                viewModel.vote(.dislike)
            } label: {
                Label("voting.dislike", systemImage: "hand.thumbsdown.fill")
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.currentBreed == nil || viewModel.isLoading)

            Button {
                viewModel.vote(.like)
            } label: {
                Label("voting.like", systemImage: "hand.thumbsup.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.currentBreed == nil || viewModel.isLoading)
        }
    }
}
