//
//  Server.swift
//  HUBAPI
//
//  Created by Alon Yakoby on 02/05/2017.
//
//

import Foundation
import SwiftyJSON
import LoggerAPI
import CloudFoundryEnv
import Configuration
import CouchDB

#if os(Linux)
    typealias Valuetype = Any
    
#else
    typealias Valuetype = AnyObject
#endif

public enum APICollectionError: Error {
    case ParseError
    case AuthError
}

public class Server: HUBAPI {

    
    //
    //// //ORIGINAL
    //    static let defaultDBHost = "9628c5f7-f404-4252-a842-5ed8dc20a5c9-bluemix.cloudant.com"
    //    static let defaultDBPort = UInt16(5984)
    //    static let defaultDBName = "matrixapi"
    //    static let defaultUsername = "9628c5f7-f404-4252-a842-5ed8dc20a5c9-bluemix"
    //    static let defaultPassword = "1bed5f813a3f31c50996e3ae68ff5d7998ed45996abcd62fb5eedb9b5d930b74"
    //
    // DEVELOPMENT
    static let defaultDBHost = "localhost"
    static let defaultDBPort = UInt16(5984)
    static let defaultDBName = "hubapi"
    static let defaultUsername = "alon"
    static let defaultPassword = "Passw00rd"
    
    let dbName = "hubapi"
    let designName = "hubapidesign"
    let connectionProps: ConnectionProperties
    
    public init(database: String = Server.defaultDBName,
                host: String = Server.defaultDBHost,
                port: UInt16 = Server.defaultDBPort,
                username: String? = Server.defaultUsername,
                password: String? = Server.defaultPassword)
    {
        
        let secured = (host == Server.defaultDBHost) ?  false : true
        connectionProps = ConnectionProperties(host: host,
                                               port: Int16(port),
                                               secured: secured,
                                               username: username,
                                               password: password)
        setupDB()
    }
    
    public convenience init (service: Service) {
        let host: String
        let username: String?
        let password: String?
        let port: UInt16
        let databaseName: String = "HUBapi"
        
        if let credentials = service.credentials, let tempHost = credentials["host"] as? String, let tempUsername = credentials["username"] as? String, let tempPassword = credentials["password"] as? String, let tempPort = credentials["port"] as? Int {
            
            host = tempHost
            username = tempUsername
            password = tempPassword
            port = UInt16(tempPort)
            
            Log.info("Using CF Service Credentials")
            
        } else {
            host = "localhost"
            username = "alon"
            password = "2204"
            port = UInt16(5984)
            Log.info("Using Service Development Credentials")
        }
        
        self.init(database: databaseName, host: host, port: port, username: username, password: password)
    }
    
    private func setupDB () {
        let couchClient = CouchDBClient(connectionProperties: self.connectionProps)
        couchClient.dbExists(dbName) { (exists, error) in
            if (exists) {
                Log.info("DB already exists")
            } else {
                Log.error("DB Does not exits \(String(describing: error))")
                couchClient.createDB(self.dbName, callback: { (db, error) in
                    if (db != nil) {
                        Log.info("Database Created!")
                        self.setupDbDesign(db: db!)
                    }else {
                        Log.error("Unable to create DB \(self.dbName): Error \(String(describing: error))")
                    }
                })
            }
        }
    }
    
    private func setupDbDesign(db: Database) {
        let design: [String: Any] = [
            "_id": "_design/HUBAPI",
            "views": [
                "all_documents": [
                    "map": "function(doc) { emit(doc._id, [doc._id, doc._rev]); }"
                ],
                "all_products": [
                    "map": "function(doc) { if (doc.type == 'product') { emit(doc._id, [doc._id, doc.itemcode, doc.brand, doc.name, doc.category, doc.mainCategory, doc.subCategory, doc.innerbarcode, doc.exportBarcode, doc.seriesName, doc.coo, doc.customerDescription, doc.packingdetail, doc.size, doc.capacity, doc.material, doc.thickness, doc.finish, doc.style, doc.capsule, doc.imageURL, doc.price]); }}"
                 ],
                "all_users": [
                    "map": "function(doc) { if (doc.type == 'user') { emit(doc._id, [doc._id, doc.first, doc.last, doc.profileImageURL, doc.email, doc.password, doc.mobile, doc.office, doc.officeaddress, doc.country, doc.myProds]);}}"
                ]
            ]
        ]
        
        
        db.createDesign(self.designName, document: JSON(design)) { (json, error) in
            if error != nil {
                Log.error("Failed to create Design \(String(describing: error))")
            } else {
                Log.info("Design Created:  \(String(describing: json))")
            }
        }
    }


    
    public func clearAll(completion: @escaping (Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.queryByView("all_documents", ofDesign: "matrixapidesign", usingParameters: [.descending(true), .includeDocs(true)]) { (doc, err) in
            guard let doc = doc else {
                completion(err)
                return
            }
            
            guard let idAndRev = try? self.getIdAndRev(doc) else {
                completion(err)
                return
            }
            
            if idAndRev.count == 0 {
                completion(nil)
            } else {
                for i in 0...idAndRev.count - 1 {
                    let product = idAndRev[i]
                    
                    database.delete(product.0, rev: product.1, callback: { (err) in
                        guard err == nil else {
                            completion(err)
                            return
                        }
                        completion(nil)
                    })
                }
            }
        }
    }
    
    func getIdAndRev(_ document: JSON) throws -> [(String, String)] {
        guard let rows = document["rows"].array else {
            throw APICollectionError.ParseError
        }
        
        return rows.flatMap {
            let doc = $0["doc"]
            let id = doc["_id"].stringValue
            let rev = doc["_rev"].stringValue
            return (id, rev)
        }
    }
    


}
