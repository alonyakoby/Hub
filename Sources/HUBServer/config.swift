//
//  cofig.swift
//  HUBAPI
//
//  Created by Alon Yakoby on 02/05/2017.
//
//

import Foundation
import LoggerAPI
import CouchDB
import CloudFoundryEnv
import Configuration

struct ConfigError: LocalizedError {
    var errorDescription: String? {
        return "Could not retreive config info"
    }
}

func getConfig() throws -> Service {
    var appEnv = ConfigurationManager()
    
    do {
        Log.warning("Attempting to retreive CF ENV")
        appEnv = ConfigurationManager()
        
        let services = appEnv.getServices()
        let servicePair = services.filter { element in element.value.label == "cloudantNoSQLDB" }.first
        guard let service = servicePair?.value else {
            throw ConfigError()
        }
        return service
        
    } catch {
        Log.warning("An error occured while trying to retreive configs")
        throw ConfigError()
    }
}
