//
//  GRDBToCSVTransferable.swift
//  Footprints
//
//  Created by Collin Palmer on 5/22/24.
//

import Foundation
import GRDB
import CoreTransferable
import UniformTypeIdentifiers
import CodableCSV

struct GRDBToCSVTransferable<Record: FetchableRecord & PersistableRecord & CSVRepresentable, CSV: CSVRepresentable>: FileTransferable {
    let dbQueue: DatabaseQueue
    let filename: () -> String
    let recordFetcher: (Database) throws -> [Record]
    let codableMap: (Record) -> CSV
    let exportBaseURL: URL
    
    // TODO: CSV type?
    static var fileType: UTType { .data }
    
    init(
        dbQueue: DatabaseQueue,
        filename: @escaping () -> String,
        codableMap: @escaping (Record) -> CSV,
        recordFetcher: @escaping (Database) throws -> [Record] = { db in try Record.fetchAll(db) },
        exportBaseURL: URL = FileManager.default.temporaryDirectory
    ) {
        self.dbQueue = dbQueue
        self.filename = filename
        self.recordFetcher = recordFetcher
        self.codableMap = codableMap
        self.exportBaseURL = exportBaseURL
    }
    
    func exportFileTask() async throws -> URL {
        let csvEncoder: CSVEncoder = CSVEncoder { $0.headers = Record.headers }
        let csvEntries: [CSV] = try await dbQueue.read { db in
            try recordFetcher(db)
        }.map {
            codableMap($0)
        }
        
        let csvData: Data = try csvEncoder.encode(csvEntries)
        let dataURL = exportBaseURL.appending(path: "\(filename()).csv")
        try csvData.write(to: dataURL)
        
        return dataURL
    }
}
