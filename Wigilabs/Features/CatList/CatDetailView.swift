//
//  CatDetailView.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import SwiftUI

struct CatDetailView: View {
    let catImage: CatImage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: catImage.url)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    default:
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if let breed = catImage.breeds?.first {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(breed.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        if let origin = breed.origin {
                            Text(String(format: String(localized: "catdetail.origin_format", defaultValue: "Origen: %@"), origin))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let temperament = breed.temperament {
                            Text(String(format: String(localized: "catdetail.temperament_format", defaultValue: "Temperamento: %@"), temperament))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let description = breed.description {
                            Text(description)
                                .font(.body)
                                .padding(.top, 4)
                        }
                    }
                } else {
                    Text("catdetail.no_breed_info")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("catdetail.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
