//
//  VotingView.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import SwiftUI
import SwiftData

private let cardCornerRadius: CGFloat = 16

struct VotingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: VotingViewModel?
    @State private var showHistory = false
    @State private var dragOffset: CGSize = .zero
    @State private var flyingCard: VotingCard?
    @State private var flyingOffset: CGSize = .zero

    private let swipeThreshold: CGFloat = 120

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
            newViewModel.loadIfNeeded()
        }
    }

    @ViewBuilder
    private func content(for viewModel: VotingViewModel) -> some View {
        VStack(spacing: 24) {
            cardStack(for: viewModel)
                .frame(maxWidth: .infinity, minHeight: 420, maxHeight: 460)
                .clipped()

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
    private func cardStack(for viewModel: VotingViewModel) -> some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack {
                ForEach(Array(viewModel.deck.enumerated()).reversed(), id: \.element.id) { index, card in
                    let isTop = index == 0
                    CatCardView(card: card)
                        .frame(width: size.width, height: size.height)
                        .overlay(tintOverlay(for: isTop ? dragOffset : .zero))
                        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
                        .scaleEffect(isTop ? 1 : 0.92)
                        .rotationEffect(.degrees(isTop ? Double(dragOffset.width / 20) : 0))
                        .offset(isTop ? dragOffset : CGSize(width: 0, height: 18))
                        .allowsHitTesting(isTop && flyingCard == nil)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    guard isTop, flyingCard == nil else { return }
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    guard isTop else { return }
                                    handleDragEnd(value: value, viewModel: viewModel)
                                }
                        )
                }

                if viewModel.currentCard == nil && viewModel.isLoading {
                    ProgressView()
                        .frame(width: size.width, height: size.height)
                }

                if let flyingCard {
                    CatCardView(card: flyingCard)
                        .frame(width: size.width, height: size.height)
                        .overlay(tintOverlay(for: flyingOffset))
                        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
                        .rotationEffect(.degrees(Double(flyingOffset.width / 20)))
                        .offset(flyingOffset)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: size.width, height: size.height)
        }
    }

    private func tintOverlay(for offset: CGSize) -> some View {
        RoundedRectangle(cornerRadius: cardCornerRadius)
            .fill(offset.width > 0 ? Color.green : Color.red)
            .opacity(min(Double(abs(offset.width)) / 150, 0.35))
    }

    private func handleDragEnd(value: DragGesture.Value, viewModel: VotingViewModel) {
        if value.translation.width > swipeThreshold {
            performSwipe(.like, viewModel: viewModel)
        } else if value.translation.width < -swipeThreshold {
            performSwipe(.dislike, viewModel: viewModel)
        } else {
            withAnimation(.spring()) {
                dragOffset = .zero
            }
        }
    }

    private func performSwipe(_ type: VoteType, viewModel: VotingViewModel) {
        guard flyingCard == nil, let card = viewModel.currentCard else { return }

        let startingOffset = dragOffset
        dragOffset = .zero
        viewModel.vote(type)
        guard viewModel.errorMessage == nil else { return }

        flyingCard = card
        flyingOffset = startingOffset
        let flyDistance: CGFloat = type == .like ? 600 : -600
        withAnimation(.easeOut(duration: 0.3)) {
            flyingOffset = CGSize(width: flyDistance, height: flyingOffset.height)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            flyingCard = nil
        }
    }

    private func voteButtons(for viewModel: VotingViewModel) -> some View {
        HStack(spacing: 32) {
            Button {
                performSwipe(.dislike, viewModel: viewModel)
            } label: {
                Label("voting.dislike", systemImage: "hand.thumbsdown.fill")
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.currentCard == nil || flyingCard != nil)

            Button {
                performSwipe(.like, viewModel: viewModel)
            } label: {
                Label("voting.like", systemImage: "hand.thumbsup.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.currentCard == nil || flyingCard != nil)
        }
    }
}

private struct CatCardView: View {
    let card: VotingCard

    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: card.image.url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            Text(card.breed.name)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
        }
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
    }
}
