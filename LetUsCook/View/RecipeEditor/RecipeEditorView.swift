//
//  RecipeCreationView.swift
//  LetUsCook
//
//  Created by Justin Hoang on 3/30/24.
//

import PhotosUI
import SwiftUI

/// View for creating a recipe
///
/// Define all the variables that the user might be able to change as state
/// variables.
/// This ensure that SwiftData does not save changes until the
/// user is ready to submit and save those changes. Moreover, the user can
/// discard changes if they don't like what they have entered.

struct RecipeEditorView: View {
    @Environment(\.modelContext) private var modelContext

    /// Dismiss pushes away the current context
    @Environment(\.dismiss) private var dismiss

    /// The recipe that we are currently viewing
    ///
    /// If the recipe is `nil`, that means we are creating a recipe in the view.
    /// Otherwise, we are editing a recipe.
    /// Regardless, the data entered by the user create or edit the recipe.
    @Binding var recipe: Recipe?

    /// Define all the variables that the user might be able to change as state
    /// variables.
    ///
    /// This ensure that SwiftData does not save changes until the
    /// user is ready to submit and save those changes. Moreover, the user can
    /// discard changes if they don't like what they have entered.

    /// The name of the recipe
    @State private var name = ""

    /// An image for the recipe.
    ///
    /// Note that the photo is nullable because they don't have to include one.
    /// Or maybe they can add a picture of their own dish after they've cooked
    /// it once
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedPhotoImage: Image? = nil

    /// The categories that the recipe falls under
    ///
    /// For example, this might be "breakfast", "easy", etc.
    /// Ideally, these categories are unique and may be reused across other
    /// recipes as well
    @State private var categories: [Category] = []

    /// The amount of time that it takes to prepare the recipe
    @State private var prepTime = ""

    /// The amount of time that it takes to cook the recipe
    @State private var cookTime = ""

    /// Any final remarks about the recipe
    @State private var comments = ""

    /// Describes how to make the recipe
    ///
    /// The instructions are parsed into an array of `Instruction` in
    /// `instructionArray`. It just needs to be a string so that we can use a
    /// text field
    @State private var instructions: [String] = []
    @State private var instructionText: String = ""

    /// Describes which ingredients are needed for the recipe
    ///
    /// The ingredients are parsed into an array of `Ingredient` in
    /// `ingredientArray`. It just needs to be a string so that we can use a
    /// text field
    @State private var ingredients: [String] = []
    @State private var ingredientText: String = ""

    var body: some View {
        Form {
            NameView(name: $name)
            ImageView(
                selectedPhotoItem: $selectedPhoto,
                selectedPhotoImage: $selectedPhotoImage
            )
            TimeView(prepTime: $prepTime, cookTime: $cookTime)
            CommentsView(comments: $comments)

            EditorView(
                title: "Instruction",
                input: $instructionText
            )
            EditorView(
                title: "Ingredients",
                input: $ingredientText
            )
        }
        .textFieldStyle(.roundedBorder)
        .onAppear {
            if let recipe {
                name = recipe.name

                // TODO: how to save photo?

                categories = recipe.categories
                prepTime = recipe.prepTime
                cookTime = recipe.cookTime
                comments = recipe.comments

                // TODO: let's not use a string??
                // TODO: WHY DO WE HAVE TO SORT EVERY TIME
                instructionText = Instruction
                    .asString(recipe.instructions.sorted {
                        $0.index < $1.index
                    })
                ingredientText = Ingredient.asString(recipe.ingredients.sorted {
                    $0.name < $1.name
                })
            }
        }

        // Add buttons to the toolbar
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    withAnimation {
                        save()
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
//        // TODO: i don't really like how this is done here..
//        /// Perform an async function whenever the photo value changes
//        .task(id: selectedPhoto) {
//            if let loadedImage = try? await selectedPhoto?
//                .loadTransferable(type: Image.self),
//                let loadedData = try? await selectedPhoto?
//                .loadTransferable(type: Data.self)
//            {
//                selectedPhotoImage = loadedImage
//
//                // TODO: save the image in a cache and point the recipe's
//                // imageURL to it
        ////                recipe?.imageData = loadedData
//            }
//        }
//
        .navigationTitle("Recipe Editor")
        .frame(minWidth: 600)
        .padding()
    }

    /// Save the recipe in the model context
    /// If we are editing a recipe, then update the recipe's properties
    private func save() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)

        // TODO: do more input validation here...
        if name.isEmpty {
            return
        }

        // Get the instructinos and ingredients as arrays
        let instructions = Instruction.parseInstructions(instructionText)
        let ingredients = Ingredient.parseIngredients(ingredientText)

        if let recipe {
            recipe.name = name
            // TODO: save the image data
            recipe.categories = categories
            recipe.prepTime = prepTime
            recipe.cookTime = cookTime
            recipe.comments = comments

            recipe.updateInstructions(withInstructions: instructions)
            recipe.updateIngredients(withIngredients: ingredients)

        } else { // Add a new recipe.
            let newRecipe = Recipe(
                name: name,
                // TODO: save the image data
                // imageData: recipe.imageData,
                categories: categories,
                prepTime: prepTime,
                cookTime: cookTime,
                comments: comments
            )

            // Remember to insert the recipe into the model context after
            modelContext.insert(newRecipe)

            // The item has to first exist in the model context before we can
            // create any links to other existing items!!
            newRecipe.updateInstructions(withInstructions: instructions)
            newRecipe.updateIngredients(withIngredients: ingredients)
        }
    }
}
