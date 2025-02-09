//
//  LibrarySheet.swift
//  AR World
//
//  Created by Zachary Tao on 1/29/25.
//

import SwiftUI
import ARKit
import SwiftData

struct LibrarySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CustomARView.self) private var customARView

    @State private var isEditing = false
    @Query(sort: \SavedMap.dateCreated, order: .reverse) private var savedMaps: [SavedMap]

    let columns = [
        GridItem(.adaptive(minimum: isIPhone() ? 130 : 300))
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(savedMaps) { savedMap in
                        LibraryItemView(isEditing: $isEditing, savedMap: savedMap)
                    }
                }
                .padding()
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        customARView.resumeSession()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
            }
        }
        .onAppear {
            customARView.pauseSession()
        }
    }

    struct LibraryItemView: View {
        @Environment(CustomARView.self) var customARView
        @Environment(\.dismiss) var dismiss
        @Environment(\.modelContext) var context

        @State var showingExperienceOptions = false
        @State private var showingDeleteAlert = false
        @State private var itemToDelete: SavedMap?
        @Binding var isEditing: Bool

        var savedMap: SavedMap

        var body: some View {
            VStack {
                displayMapImage(map: savedMap)
                Text(savedMap.name)
            }
            .padding(10)
            .onTapGesture {
                if !isEditing {
                    showingExperienceOptions = true
                }
            }
            .confirmationDialog("How do you want to load this drawing?", isPresented: $showingExperienceOptions, titleVisibility: .visible) {
                Button("Use Saved Position") {
                    customARView.loadExperience(savedMap: savedMap)
                    dismiss()
                }
                Button("Use My Current Position") {
                    customARView.loadStrokesOnCurrentMap(savedMap: savedMap)
                    customARView.resumeSession()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Delete Map", isPresented: $showingDeleteAlert, presenting: itemToDelete) { _ in
                Button("Delete", role: .destructive) {
                    if let itemToDelete {
                        withAnimation {
                            context.delete(itemToDelete)
                            try? context.save()
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: { _ in
                Text("Are you sure you want to delete this map?")
            }
        }

        @ViewBuilder
        func deleteButton(map: SavedMap) -> some View {
            if isEditing {
                Button {
                    itemToDelete = map
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .background(Color.white.clipShape(Circle()))
                        .padding(5)
                }
            }
        }

        @ViewBuilder
        func displayMapImage(map: SavedMap) -> some View {
            let size = CGSize(width: 300, height: 300)
            DownsizedImageView(image: UIImage(data: map.snapshot ?? Data()), size: size) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .overlay(deleteButton(map: map), alignment: .topTrailing)
        }
    }

}

#Preview {
    LibrarySheet()
        .environment(CustomARView())
}
