//
//  SessionModelTransferable.swift
//  Footprints
//
//  Created by Collin Palmer on 4/23/24.
//

import Foundation
import GRDB
import CoreTransferable

struct SessionModelTransferable: Transferable {
    let dbQueue: DatabaseQueue
    let session: SessionModel
    let baseURL: URL = FileManager.default.temporaryDirectory
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .xml, exporting: { transferable in
            let dbQueue = transferable.dbQueue
            let session = transferable.session
            
            // TODO: Test to verify gpx file exists?
            let gpxURL = try session.exportGPXToURL(dbQueue: dbQueue, saveAt: transferable.baseURL)
            return SentTransferredFile(gpxURL)
        })
    }
}
