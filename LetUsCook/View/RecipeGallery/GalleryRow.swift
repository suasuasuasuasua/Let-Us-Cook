//
//  RecipeGalleryIcon.swift
//  LetUsCook
//
//  Created by Justin Hoang on 4/10/24.
//

import SwiftUI

extension GalleryView {
    struct GalleryRow: View {
        let recipe: Recipe
        let iconSize: CGFloat

        var body: some View {
            HStack {
                AsyncImage(url: recipe.imageURL) { image in
                    image.resizable()
                } placeholder: {
                    // ProgressView()
                }
                .frame(width: iconSize, height: iconSize)
                VStack(alignment: .leading) {
                    Text("\(recipe.name)")
                        .bold()
                    Group {
                        Text("Preparation Time: \(recipe.prepTime)")
                        Text("Cook: \(recipe.cookTime)")
                        Text("Comments: \(recipe.comments)")
                    }
                    .font(.caption)
                }
            }
            .padding(.vertical, 10)
        }
    }
}
