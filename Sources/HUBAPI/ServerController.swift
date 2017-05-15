//
//  ServerController.swift
//  HUBAPI
//
//  Created by Alon Yakoby on 02/05/2017.
//
//

import Foundation
import SwiftyJSON
import LoggerAPI
import Kitura

public final class ServerController {

    public let hub: HUBAPI
    public let router = Router()
    public let productspath = "api/v1/products"
    public let userspath = "api/v1/users"
    public let contactspath = "api/v1/contacts"
    public let ordersspath = "api/v1/orders"
    public let customerspath = "api/v1/customer"

    
    public init(backend: HUBAPI) {
        self.hub = backend
        routeSetup()
    }
    
    public func routeSetup() {
        
        router.all("/*", middleware: BodyParser())
        // Product Handling
        router.get(productspath, handler: getProducts)
        // Specific Product
        router.get("\(productspath)/:id", handler: getProductbyId)
        // Delete Product
        router.delete("\(productspath)/:id", handler: deleteProductById)
        // Update Product (PUT)
        router.put("\(productspath)/:id", handler: updateProductById)
        // Add Truck
        router.post(productspath, handler: addProduct)
        
        // USERS
        router.all("/*", middleware: BodyParser())
        // Product Handling
        router.get(userspath, handler: getUsers)
        // Specific Product
        router.get("\(userspath)/:id", handler: getUser)
        // Delete Product
        router.delete("\(userspath)/:id", handler: deleteUser)
        // Update Product (PUT)
        router.put("\(userspath)/:id", handler: updateUser)
        // Add Truck
        router.post(userspath, handler: addUser)
        
        
    }

}
