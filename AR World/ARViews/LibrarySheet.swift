//
//  LibrarySheet.swift
//  AR World
//
//  Created by Zachary Tao on 1/29/25.
//

import SwiftUI
import ARKit

struct LibrarySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMapID: String?
    @State private var snapshots: [LibraryItem] = []
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: LibraryItem?
    @State private var isEditing = false

    struct LibraryItem: Identifiable {
        let id: String
        let thumbnail: UIImage
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]) {
                    ForEach(snapshots) { item in
                        VStack {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: item.thumbnail)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                if isEditing {
                                    Button {
                                        itemToDelete = item
                                        showingDeleteAlert = true
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Color.white.clipShape(Circle()))
                                            .padding(5)
                                    }
                                }
                            }

                            Text(item.id)
                        }
                        .padding(10)
                        .onTapGesture {
                            if !isEditing {
                                selectedMapID = item.id
                                dismiss()
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
            }
            .alert("Delete Map", isPresented: $showingDeleteAlert, presenting: itemToDelete) { item in
                Button("Delete", role: .destructive) {
                    deleteMap(item)
                }
                Button("Cancel", role: .cancel) {}
            } message: { _ in
                Text("Are you sure you want to delete this map?")
            }
            .onAppear {
                loadSnapshots()
            }
        }
    }

    private func loadSnapshots() {
        let userDefaults = UserDefaults.standard
        let prefix = "map/"

        let allKeys = userDefaults.dictionaryRepresentation().keys
        let mapKeys = allKeys.filter { $0.hasPrefix(prefix) }

        snapshots = []
        for key in mapKeys {
            if let data = userDefaults.data(forKey: key),
               let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
               let snapshotAnchor = worldMap.anchors.first(where: { $0 is SnapshotAnchor }) as? SnapshotAnchor,
               let image = UIImage(data: snapshotAnchor.imageData) {
                let displayName = String(key.dropFirst(prefix.count))
                snapshots.append(LibraryItem(id: displayName, thumbnail: image))
            }
        }
    }

    private func deleteMap(_ item: LibraryItem) {
        withAnimation {
            UserDefaults.standard.removeObject(forKey: "map/\(item.id)")
            loadSnapshots()
        }
    }
}

#Preview {
    LibrarySheet(selectedMapID: .constant(""))
}
