
//
//  Users.swift
//  HUBAPI
//
//  Created by Alon Yakoby on 02/05/2017.
//
//

import Foundation
import SwiftyJSON
import Kitura
import LoggerAPI
import CloudFoundryEnv
import Configuration
import CouchDB

extension Server {
    
    func parseUsers(_ document: JSON) throws -> [UserItem] {
        guard let rows = document["rows"].array else {
            throw APICollectionError.ParseError
        }
        
        
        let users: [UserItem] = rows.flatMap {
            let doc = $0["value"]
            guard let id = doc[0].string,
                let first = doc[1].string,
                let last = doc[2].string,
                let profileImageURL = doc[3].string,
                let email = doc[4].string,
                let password = doc[5].string,
                let mobile = doc[6].string,
                let office = doc[7].string,
                let officeaddress = doc[8].string,
                let country = doc[9].string,
                let myProds = doc[10].arrayObject else {
                    return nil
            }
            return UserItem(docId: id, first: first, last: last, profileImageURL: profileImageURL, email: email, password: password, mobile: mobile, office: office, officeaddress: officeaddress, country: country, myProds: myProds as! [String])
        }
        return users
    }
    
    public func getAllUsers(completion: @escaping ([UserItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.queryByView("all_users", ofDesign: designName, usingParameters: [.descending(true), .includeDocs(true)]) { doc, err in
            if let doc = doc, err == nil {
                do {
                    let users = try self.parseUsers(doc)
                    completion(users, nil)
                } catch {
                    completion(nil ,err)
                }
            } else {
                completion(nil, err)
            }
        }
    }
    
    public func getUser(docId: String, completion: @escaping (UserItem?, Error?) -> Void) {
        
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.retrieve(docId) { (doc, err) in
            guard let doc = doc,
                let docId = doc["_id"].string,
                let first = doc["first"].string,
                let last = doc["last"].string,
                let profileImageURL = doc["profileImageURL"].string,
                let password = doc["password"].string,
                let email = doc["email"].string,
                let mobile = doc["mobile"].string,
                let office = doc["office"].string,
                let officeaddress = doc["officeaddress"].string,
                let country = doc["country"].string,
                let myProds = doc["myProds"].arrayObject else {
                    completion(nil, err)
                    return
            }
            
            let userItem = UserItem(docId: docId, first: first, last: last, profileImageURL: profileImageURL, email: email, password: password, mobile: mobile, office: office, officeaddress: officeaddress, country: country, myProds: myProds as! [String])
            
            completion(userItem, nil)
        }
    }

    public func addUser(first: String, last: String, profileImageURL: String, email: String, password: String, mobile: String, office: String, officeaddress: String, country: String, myProds: [String]?, completion: @escaping (UserItem?, Error?) -> Void) {
        
        let json: [String:Any] = [
            "type": "user",
            "first": first,
            "last": last,
            "profileImageURL": profileImageURL,
            "email": email,
            "password": password,
            "mobile": mobile,
            "office": office,
            "officeaddress": officeaddress,
            "country": country,
            "myProds": myProds as Any
            
        ]
        
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.create(JSON(json)) { (id, rev, doc, err) in
            if let id = id {
                let useritem = UserItem(docId: id, first: first, last: last, profileImageURL: profileImageURL, email: email, password: password, mobile: mobile, office: office, officeaddress: officeaddress, country: country, myProds: myProds!)
                completion(useritem, nil)
            } else {
                completion(nil, err)
            }
        }
    }
    
    public func updateUser(docId: String, first: String?, last: String?, profileImageURL: String?, email: String?, password: String?, mobile: String?, office: String?, officeaddress: String?, country: String?, myProds: [String]?, completion: @escaping (UserItem?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.retrieve(docId) { (doc, err) in
            guard let doc = doc else {
                completion(nil, APICollectionError.AuthError)
                return
            }
            
            guard let rev = doc["_rev"].string else {
                completion(nil, APICollectionError.ParseError)
                return
            }
            
            let type = "user"
            let first = first ?? doc["first"].stringValue
            let last = last ?? doc["last"].stringValue
            let profileImageURL = profileImageURL ?? doc["profileImageURL"].stringValue
            let email = email ?? doc["email"].stringValue
            let password = password ?? doc["password"].stringValue
            let mobile = mobile ?? doc["mobile"].stringValue
            let office = office ?? doc["office"].stringValue
            let officeaddress = officeaddress ?? doc["officeaddress"].stringValue
            let country = country ?? doc["country"].stringValue
            let myProds = myProds ?? doc["myProds"].arrayObject
            
            let json: [String: Any] = [
                "type": type,
                "first": first,
                "last": last,
                "profileImageURL": profileImageURL,
                "email": email,
                "password": password,
                "mobile": mobile,
                "office": office,
                "officeaddress": officeaddress,
                "country": country,
                "myProds": myProds as Any
            ]
            
            database.update(docId, rev: rev, document: JSON(json), callback: { (rev, doc, err) in
                guard err == nil else {
                    completion(nil, err)
                    return
                }
                
                completion(UserItem(docId: docId, first: first, last: last, profileImageURL: profileImageURL, email: email, password: password, mobile: mobile, office: office, officeaddress: officeaddress, country: country, myProds: myProds as! [String]), nil)
            })
        }
    }
    
    public func deleteUser(docId: String, completion: @escaping (Error?) -> Void) {
        
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.retrieve(docId) { (doc, err) in
            guard let doc = doc, err == nil else {
                completion(err)
                return
            }
            let rev = doc["_rev"].stringValue
            database.delete(docId, rev: rev) { (err) in
                if err != nil {
                    completion(err)
                } else {
                    completion(nil)
                }
            }
        }
    }
    

}

extension ServerController {
     
    func getUsers(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        hub.getAllUsers{ (users, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                guard let users = users else {
                    try response.status(.internalServerError).end()
                    Log.error("Failed to get Users")
                    return
                }
                
                let json = JSON(users.toDict())
                try response.status(.OK).send(json: json).end()
            } catch {
                Log.error("Communications error")
            }
        }
    }
        
    
    func addUser(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let first: String = json["first"].stringValue
        let last: String = json["last"].stringValue
        let profileImageURL: String = json["profileImageURL"].stringValue
        let email: String = json["email"].stringValue
        let password: String = json["password"].stringValue
        let mobile: String = json["mobile"].stringValue
        let office: String = json["office"].stringValue
        let officeaddress: String = json["officeaddress"].stringValue
        let country: String = json["country"].stringValue
        let myProds: [String] = json["myProds"].arrayObject as! [String]
        
        
        guard first != "" else {
            response.status(.badRequest)
            Log.error("Necessary fields not supplied")
            return
        }
        
        hub.addUser(first: first, last: last, profileImageURL: profileImageURL, email: email, password: password, mobile: mobile, office: office, officeaddress: officeaddress, country: country, myProds: myProds ) { (user, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                
                guard let user = user else {
                    try response.status(.internalServerError).end()
                    Log.error("User not found")
                    return
                }
                
                let result = JSON(user.toDict())
                Log.info("\(first) added to Product list")
                do {
                    try response.status(.OK).send(json: result).end()
                } catch {
                    Log.error("Error sending response")
                }
            } catch {
                Log.error("Communications error")
            }
        }
    }
    
    func getUser(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let docId = request.parameters["id"] else {
            response.status(.badRequest)
            Log.error("No ID supplied")
            return
        }
        
        hub.getUser(docId: docId) { (user, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                
                if let user = user {
                    let result = JSON(user.toDict())
                    try response.status(.OK).send(json: result).end()
                } else {
                    Log.warning("Could not find a User by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
     func deleteUser(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let docId = request.parameters["id"] else {
            response.status(.badRequest)
            Log.warning("ID not found in request")
            return
        }
        
        hub.deleteUser(docId: docId) { (err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                try response.status(.OK).end()
                Log.info("\(docId) successfully deleted")
            } catch {
                Log.error("Communication Error")
            }
        }
    }
    
     func updateUser(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let docId = request.parameters["id"] else {
            response.status(.badRequest)
            Log.error("ID Not found in request")
            return
        }
        
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No Body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let first: String? = json["first"].stringValue == "" ? nil : json["first"].stringValue
        let last: String? = json["last"].stringValue == "" ? nil : json["last"].stringValue
        let profileImageURL: String? = json["profileImageURL"].floatValue == 0 ? nil : json["profileImageURL"].stringValue
        let email: String? = json["email"].stringValue == "" ? nil : json["email"].stringValue
        let password: String? = json["password"].stringValue == "" ? nil : json["password"].stringValue
        let mobile: String? = json["mobile"].stringValue == "" ? nil : json["mobile"].stringValue
        let office: String? = json["office"].stringValue == "" ? nil : json["office"].stringValue
        let officeaddress: String? = json["officeaddress"].stringValue == "" ? nil : json["officeaddress"].stringValue
        let country: String? = json["country"].stringValue == "" ? nil : json["country"].stringValue
        let myProds: [String]? = json["myProds"].arrayObject as? [String]
        
        hub.updateUser(docId: docId, first: first, last: last, profileImageURL: profileImageURL, email: email, password: password, mobile: mobile, office: office, officeaddress: officeaddress, country: country, myProds: myProds) { (updatedUser, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    
                    return
                }
                if let updatedUser = updatedUser {
                    let result = JSON(updatedUser.toDict())
                    try response.status(.OK).send(json: result).end()
                } else {
                    Log.error("Invalid User Returned")
                    try response.status(.badRequest).end()
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
}
