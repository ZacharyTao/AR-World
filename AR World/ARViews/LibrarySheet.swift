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
    @Environment(\.modelContext) private var context
    @Environment(CustomARView.self) private var customARView

    @State private var showingDeleteAlert = false
    @State private var itemToDelete: SavedMap?
    @State private var isEditing = false
    @State private var showingExperienceOptions = false
    @State private var selectedMap: SavedMap?
    @Query(sort: \SavedMap.dateCreated, order: .reverse) private var savedMaps: [SavedMap]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(savedMaps) { savedMap in
                        VStack {
                            displayMapImage(map: savedMap)
                            Text(savedMap.name)
                        }
                        .padding(10)
                        .onTapGesture {
                            if !isEditing {
//                                customARView.loadExperience(savedMap: savedMap)
//                                dismiss()
                                selectedMap = savedMap
                                showingExperienceOptions = true
                            }
                        }
                        .confirmationDialog("How do you want to load this drawing?", isPresented: $showingExperienceOptions, titleVisibility: .visible) {
                            Button("Use Saved Position") {
                                if let map = selectedMap {
                                    customARView.loadExperience(savedMap: map)
                                }
                                dismiss()
                            }
                            Button("Use My Current Position") {
                                if let map = selectedMap {
                                    customARView.loadStrokesOnCurrentMap(savedMap: map)
                                }
                                customARView.resumeSession()
                                dismiss()
                            }
                            Button("Cancel", role: .cancel) {}
                        }
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
        .onAppear {
            customARView.pauseSession()
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
        let size = CGSize(width: 200, height: 200)
        DownsizedImageView(image: UIImage(data: map.snapshot ?? Data()), size: size) { image in
            image
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .overlay(deleteButton(map: map), alignment: .topTrailing)
    }
}

#Preview {
    LibrarySheet()
        .environment(CustomARView())
}
