import Foundation

struct LinkMetadataService {
    func fetchMetadata(for url: URL) async -> LinkMetadataResult? {
        LinkMetadataResult(
            title: nil,
            host: url.host,
            previewImageData: nil,
            faviconData: nil
        )
    }
}
