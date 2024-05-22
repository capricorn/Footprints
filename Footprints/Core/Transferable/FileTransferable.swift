//
//  FileTransferable.swift
//  Footprints
//
//  Created by Collin Palmer on 5/22/24.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

protocol FileTransferable: Transferable {
    static var fileType: UTType { get }
    func exportFileTask() async throws -> URL
}

// TODO: Special case of CSV transferable?
extension FileTransferable {
    static var transferRepresentation: some TransferRepresentation {
        return FileRepresentation(exportedContentType: fileType, exporting: { (transferable: Self) in
            let exportURL = try await transferable.exportFileTask()
            return SentTransferredFile(exportURL)
        })
    }
}
