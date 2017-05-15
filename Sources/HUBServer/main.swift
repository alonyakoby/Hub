import Foundation
import Kitura
import HeliumLogger
import LoggerAPI
import CloudFoundryEnv
import Configuration
import HUBAPI
import CouchDB

HeliumLogger.use()
let server: Server

do {
    Log.info("Attempting init with CF Enviroment")
    let service = try getConfig()
    Log.warning("Init with Service")
    server = Server(service: service)
} catch {
    Log.warning("Could not init with CF enviroment: init with Defaults")
    server = Server()
}

let controller = ServerController(backend: server)

do {
    let port = ConfigurationManager().port
    Log.verbose("Assign=ed Port \(port)")
    
    Kitura.addHTTPServer(onPort: port, with: controller.router)
    
    Kitura.run()
} catch {
    Log.error("Server Failed to start")
}

