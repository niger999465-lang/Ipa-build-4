import SwiftUI

struct FileExplorerView: View {
    @State private var currentURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    @State private var items: [URL] = []
    @State private var clipboardURL: URL? = nil
    @State private var selectedFile: URL? = nil
    @State private var showEditor = false

    var body: some View {
        NavigationStack {
            List {
                if let clipboard = clipboardURL {
                    Section("Bo nho tam") {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(.orange)
                            Text(clipboard.lastPathComponent)
                                .lineLimit(1)
                            Spacer()
                            Button("Dan vao day") {
                                pasteFile()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }

                Section("Tep tin & Thu muc") {
                    ForEach(items, id: \.self) { url in
                        let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
                        HStack {
                            Image(systemName: isDir ? "folder.fill" : "doc.text.fill")
                                .foregroundColor(isDir ? .blue : .gray)
                            VStack(alignment: .leading) {
                                Text(url.lastPathComponent)
                                    .font(.headline)
                                Text(url.path)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isDir {
                                currentURL = url
                                reload()
                            } else {
                                selectedFile = url
                                showEditor = true
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                clipboardURL = url
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                try? FileManager.default.removeItem(at: url)
                                reload()
                            } label: {
                                Label("Xoa", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("muyynguyen Explorer")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { reload() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear { reload() }
            .sheet(isPresented: $showEditor) {
                if let file = selectedFile {
                    FileEditorView(fileURL: file)
                }
            }
        }
    }

    private func reload() {
        items = (try? FileManager.default.contentsOfDirectory(at: currentURL, includingPropertiesForKeys: [.isDirectoryKey])) ?? []
    }

    private func pasteFile() {
        guard let source = clipboardURL else { return }
        let dest = currentURL.appendingPathComponent(source.lastPathComponent)
        let fm = FileManager.default
        if fm.fileExists(atPath: dest.path) {
            try? fm.removeItem(at: dest)
        }
        try? fm.copyItem(at: source, to: dest)
        clipboardURL = nil
        reload()
    }
}
