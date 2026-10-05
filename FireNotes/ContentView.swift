import SwiftUI

struct ContentView: View {
    @State private var store = NotesStore()
    @State private var draft = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("New note", text: $draft)
                            .onSubmit(submit)
                        Button("Add", action: submit)
                            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section {
                    ForEach(store.notes) { note in
                        Button {
                            store.toggle(note)
                        } label: {
                            HStack {
                                Image(systemName: note.done ? "checkmark.circle.fill" : "circle")
                                Text(note.text).strikethrough(note.done)
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                    .onDelete { offsets in
                        offsets.map { store.notes[$0] }.forEach(store.delete)
                    }
                }

                if let error = store.errorMessage {
                    Section("Error") {
                        Text(error).foregroundStyle(.red).font(.footnote)
                    }
                }
            }
            .navigationTitle("FireNotes")
            .safeAreaInset(edge: .bottom) {
                if let uid = store.uid {
                    Text("uid: \(uid)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .task { await store.start() }
        }
    }

    private func submit() {
        store.add(draft)
        draft = ""
    }
}
