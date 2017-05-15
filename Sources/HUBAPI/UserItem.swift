//
//  UserItem.swift
//  HUBAPI
//
//  Created by Alon Yakoby on 02/05/2017.
//
//

import Foundation
import SwiftyJSON
import LoggerAPI
import CouchDB

public struct UserItem {
    
    /// ID
    public let docId: String
    // First
    public let first: String
    // Last
    public let last: String
    //Profile Image URL
    public let profileImageURL: String
    //Email
    public let email: String
    // Password
    public let password: String
    //Phone Number
    public let mobile: String
    //officePhone
    public let office: String
    //Office Address
    public let officeaddress: String
    //Coutry
    public let country: String
    
    var myProds = [String]()

    
    
    // MARK ADD SALESTEAM / PRODUCT LIST/ ORDER LIST / Potential List
    
     init(docId: String, first: String, last: String, profileImageURL: String, email: String, password: String, mobile: String, office: String, officeaddress: String, country: String, myProds: [String] ) {
        
        self.docId = docId
        self.first = first
        self.last = last
        self.profileImageURL = profileImageURL
        self.email = email
        self.password = password
        self.mobile = mobile
        self.office = office
        self.officeaddress = officeaddress
        self.country = country
        self.myProds = myProds
    }
}
extension UserItem: Equatable {
    public static func == (lhs: UserItem, rhs: UserItem) -> Bool {
        return lhs.docId == rhs.docId &&
            lhs.first == rhs.first &&
            lhs.last == rhs.last &&
            lhs.profileImageURL == rhs.profileImageURL &&
            lhs.email == rhs.email &&
            lhs.password == rhs.password &&
            lhs.mobile == rhs.mobile &&
            lhs.office == rhs.office &&
            lhs.officeaddress == rhs.officeaddress &&
            lhs.country == rhs.country &&
            lhs.myProds == rhs.myProds
    }
}

extension UserItem: DictionaryConvertable {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = self.docId
        result["first"] = self.first
        result["last"] = self.last
        result["profileImageURL"] = self.profileImageURL
        result["email"] = self.email
        result["password"] = self.password
        result["mobile"] = self.mobile
        result["office"] = self.office
        result["officeaddress"] = self.officeaddress
        result["country"] = self.country
        result["myProds"] = self.myProds
        
        return result
    }
}

