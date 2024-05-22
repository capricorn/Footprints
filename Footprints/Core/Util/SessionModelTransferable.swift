//
//  SessionModelTransferable.swift
//  Footprints
//
//  Created by Collin Palmer on 4/23/24.
//

import Foundation
import GRDB
import CoreTransferable
import CodableCSV

struct SessionModelTransferable: Transferable {
    let dbQueue: DatabaseQueue
    let session: SessionModel
    let baseURL: URL = FileManager.default.temporaryDirectory
    
    static func exportTask(transferable: SessionModelTransferable) async throws -> URL {
        try await withCheckedThrowingContinuation { cont in
            // TODO: Experiment to see if main thread is blocked without this?
            Task {
                let dbQueue = transferable.dbQueue
                let session = transferable.session
                do {
                    let gpxURL = try session.exportGPXToURL(dbQueue: dbQueue, saveAt: transferable.baseURL)
                    cont.resume(returning: gpxURL)
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .data, exporting: { transferable in
            let gpxURL = try await exportTask(transferable: transferable)
            return SentTransferredFile(gpxURL)
        })
    }
}
