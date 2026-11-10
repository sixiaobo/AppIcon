import Foundation

@main
struct ExportIcon {
    static func main() {
        let arguments = Array(CommandLine.arguments.dropFirst())
        let styles = IconDrawingStyle.allCases.map(\.rawValue).joined(separator: ", ")
        let usage = "用法：Scripts/export-icon <样式> [Documents 目录]\n样式：\(styles)"
        if arguments == ["--help"] {
            print(usage)
            return
        }
        guard (1...2).contains(arguments.count),
              let style = IconDrawingStyle(rawValue: arguments[0]) else {
            FileHandle.standardError.write(Data((usage + "\n").utf8))
            exit(2)
        }

        let documentsPath = arguments.count == 2 ? arguments[1] : "\(NSHomeDirectory())/Documents"
        let documentsDirectory = URL(filePath: documentsPath, directoryHint: .isDirectory)
        do {
            let image = IconRenderer().generateIcon(for: style)
            try IconExporter(documentsDirectory: documentsDirectory).save(image, includeCompressed: true)
            print("已导出 \(style.rawValue) 的 7 张 JPEG 到 \(documentsDirectory.path)")
        } catch {
            let message = "导出失败：\(error.localizedDescription)\n"
            FileHandle.standardError.write(Data(message.utf8))
            exit(1)
        }
    }
}
