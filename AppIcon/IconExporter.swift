import UIKit
import Darwin

struct IconExporter {
    let documentsDirectory: URL

    private var iconDirectory: URL {
        documentsDirectory.appending(path: "Icon", directoryHint: .isDirectory)
    }

    private var originalURL: URL {
        iconDirectory.appending(path: "app.jpeg")
    }

    func save(_ image: UIImage, includeCompressed: Bool = false) throws {
        let original = try jpegData(from: image)
        var files = [(originalURL, original)]
        files += try variants(from: image, in: iconDirectory, prefix: "app_60pt")
        if includeCompressed {
            files += try compressedVariants(from: original)
        }

        try withExportLock {
            try FileManager.default.createDirectory(at: iconDirectory, withIntermediateDirectories: true)
            try write(files)
        }
    }

    func compress() throws {
        try withExportLock {
            let original = try Data(contentsOf: originalURL)
            try write(compressedVariants(from: original))
        }
    }

    private func compressedVariants(from jpeg: Data) throws -> [(URL, Data)] {
        guard let image = UIImage(data: jpeg) else {
            throw CocoaError(.fileReadCorruptFile, userInfo: [NSURLErrorKey: originalURL])
        }
        return try variants(from: image, in: documentsDirectory, prefix: "app_")
    }

    private func variants(from image: UIImage, in directory: URL, prefix: String) throws -> [(URL, Data)] {
        try (1...3).map { scale in
            let pixelLength = CGFloat(60 * scale)
            let size = CGSize(width: pixelLength, height: pixelLength)
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = true
            let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
                image.draw(in: CGRect(origin: .zero, size: size))
            }
            let url = directory.appending(path: "\(prefix)@\(scale)x.jpeg")
            return (url, try jpegData(from: resized))
        }
    }

    private func jpegData(from image: UIImage) throws -> Data {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw CocoaError(.fileWriteUnknown, userInfo: [
                NSLocalizedDescriptionKey: "无法将图标编码为 JPEG"
            ])
        }
        return data
    }

    private func write(_ files: [(URL, Data)]) throws {
        for (url, data) in files {
            try data.write(to: url, options: .atomic)
        }
    }

    private func withExportLock(_ operation: () throws -> Void) throws {
        try FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
        let descriptor = open(documentsDirectory.path, O_RDONLY | O_DIRECTORY)
        guard descriptor >= 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        defer { close(descriptor) }
        guard flock(descriptor, LOCK_EX) == 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        try operation()
    }
}
