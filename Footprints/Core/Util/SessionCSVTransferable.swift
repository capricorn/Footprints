//
//  SessionCSVTransferable.swift
//  Footprints
//
//  Created by Collin Palmer on 5/14/24.
//

import Foundation
import CoreTransferable
import GRDB
import CodableCSV

struct SessionCSVTransferable: Transferable {
    let dbQueue: DatabaseQueue
    let baseURL: URL = .temporaryDirectory
    
    static func encodeSessionsCSV(dbQueue: DatabaseQueue) throws -> Data {
        let csvSessions = try dbQueue.read { db in
            try SessionModel.fetchAll(db)
        }.map {
            SessionCSV.from($0)
        }
        
        let encoder = CSVEncoder { $0.headers = SessionCSV.headers }
        return try encoder.encode(csvSessions)
    }
    
    private static func exportTask(transferable: SessionCSVTransferable) async throws -> URL {
        // TODO: Implement separately (implement as an extension of CSVEncoder)
        // TODO: Cursor?
        // TODO: Case of no sessions?
        
        let data = try encodeSessionsCSV(dbQueue: transferable.dbQueue)
        let filename = "\(Date.now.ISO8601Format())_.csv"
        let dataURL = transferable.baseURL.appending(path: filename)
        try data.write(to: dataURL)
        
        return dataURL
    }
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .data, exporting: { transferable in
            let csvURL = try await exportTask(transferable: transferable)
            return SentTransferredFile(csvURL)
        })
    }
}
