import SwiftUI

@main
struct muyynguyenApp: App {
    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let patchSources = docs.appendingPathComponent("PatchSources")
        let targetSandbox = docs.appendingPathComponent("TargetAppSandbox")
        try? FileManager.default.createDirectory(at: patchSources, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: targetSandbox, withIntermediateDirectories: true)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
