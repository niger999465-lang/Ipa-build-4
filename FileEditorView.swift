import SwiftUI

struct FileEditorView: View {
    let fileURL: URL
    @Environment(\.dismiss) var dismiss
    @State private var content = ""
    @State private var message = ""

    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $content)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding()
                
                if !message.isEmpty {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .navigationTitle(fileURL.lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dong") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Luu") {
                        try? content.write(to: fileURL, atomically: true, encoding: .utf8)
                        message = "Da luu thanh cong!"
                    }
                }
            }
            .onAppear {
                content = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? "[Khong the doc van ban UTF-8]"
            }
        }
    }
}
