//
//  CatListView.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import SwiftUI

struct CatListView: View {
    @State private var viewModel = CatListViewModel(repository: CatCatalogRepository(apiService: CatAPIService()))

    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 12)]

    var body: some View {
        Group {
            if let errorMessage = viewModel.errorMessage, viewModel.catImages.isEmpty {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("common.retry") { viewModel.reload() }
                        .buttonStyle(.bordered)
                }
                .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.catImages) { cat in
                            NavigationLink(value: cat) {
                                CatThumbnail(cat: cat)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .overlay {
                    if viewModel.isLoading && viewModel.catImages.isEmpty {
                        ProgressView()
                    }
                }
            }
        }
        .navigationTitle("catlist.title")
        .navigationDestination(for: CatImage.self) { cat in
            CatDetailView(catImage: cat)
        }
        .task {
            viewModel.loadCatsIfNeeded()
        }
    }
}

private struct CatThumbnail: View {
    let cat: CatImage

    var body: some View {
        AsyncImage(url: URL(string: cat.url)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                Image(systemName: "photo").foregroundStyle(.secondary)
            default:
                ProgressView()
            }
        }
        .frame(width: 110, height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .background(RoundedRectangle(cornerRadius: 12).fill(.quaternary))
    }
}
