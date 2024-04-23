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
    let db: Database
    let session: SessionModel
    let baseURL: URL = FileManager.default.temporaryDirectory
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .data, exporting: { transferable in
            let db = transferable.db
            let session = transferable.session
            
            let gpxURL = try session.exportGPXToURL(db: db, saveAt: transferable.baseURL)
            return SentTransferredFile(gpxURL)
        })
    }
}
