import Foundation

struct PatchItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sourceFileName: String
    var targetRelativePath: String
    var isEnabled: Bool = false
}

class PatchEngine: ObservableObject {
    @Published var patches: [PatchItem] = []
    @Published var statusMessage: String = ""
    @Published var isError: Bool = false
    
    private let configURL: URL
    
    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.configURL = docs.appendingPathComponent("patches.json")
        loadPatches()
    }
    
    func loadPatches() {
        guard let data = try? Data(contentsOf: configURL),
              let list = try? JSONDecoder().decode([PatchItem].self, from: data) else { return }
        self.patches = list
    }
    
    func savePatches() {
        if let data = try? JSONEncoder().encode(patches) {
            try? data.write(to: configURL, options: .atomic)
        }
    }
    
    func addPatch(name: String, sourceFileName: String, targetRelativePath: String) {
        let newPatch = PatchItem(
            name: name,
            sourceFileName: sourceFileName,
            targetRelativePath: targetRelativePath,
            isEnabled: false
        )
        patches.append(newPatch)
        savePatches()
    }
    
    func applyPatch(_ patch: PatchItem, baseTargetDirectory: URL) -> Bool {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let sourceURL = docs.appendingPathComponent("PatchSources").appendingPathComponent(patch.sourceFileName)
        let destinationURL = baseTargetDirectory.appendingPathComponent(patch.targetRelativePath)
        
        guard fm.fileExists(atPath: sourceURL.path) else {
            self.statusMessage = "Loi: Khong tim thay file nguon [\(patch.sourceFileName)] trong PatchSources!"
            self.isError = true
            return false
        }
        
        do {
            let parentDir = destinationURL.deletingLastPathComponent()
            if !fm.fileExists(atPath: parentDir.path) {
                try fm.createDirectory(at: parentDir, withIntermediateDirectories: true, attributes: nil)
            }
            if fm.fileExists(atPath: destinationURL.path) {
                try fm.removeItem(at: destinationURL)
            }
            try fm.copyItem(at: sourceURL, to: destinationURL)
            self.statusMessage = "Thanh cong: Da dan patch [\(patch.name)]!"
            self.isError = false
            return true
        } catch {
            self.statusMessage = "Loi dan file: \(error.localizedDescription)"
            self.isError = true
            return false
        }
    }
    
    func revertPatch(_ patch: PatchItem, baseTargetDirectory: URL) {
        let destinationURL = baseTargetDirectory.appendingPathComponent(patch.targetRelativePath)
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try? FileManager.default.removeItem(at: destinationURL)
        }
        self.statusMessage = "Da tat patch [\(patch.name)]."
        self.isError = false
    }
}
