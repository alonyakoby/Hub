//
//  Product.swift
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
import Kitura


extension Server {

// Parse Products
func parseProducts(_ document: JSON) throws -> [ProductItem] {
    guard let rows = document["rows"].array else {
        throw APICollectionError.ParseError
    }
    let product: [ProductItem] = rows.flatMap {
        let doc = $0["value"]
        guard let id = doc[0].string,
            let itemcode = doc[1].string,
            let brand = doc[2].string,
            let name = doc[3].string,
            let category = doc[4].string,
            let mainCategory = doc[5].string,
            let subCategory = doc[6].string,
            let innerbarcode = doc[7].string,
            let exportBarcode = doc[8].string,
            let seriesName = doc[9].string,
            let coo = doc[10].string,
            let customerDescription = doc[11].string,
            let packingdetail = doc[12].string,
            let size = doc[13].string,
            let capacity = doc[14].string,
            let material = doc[15].string,
            let thickness = doc[16].string,
            let finish = doc[17].string,
            let style = doc[18].string,
            let capsule = doc[19].string,
            let imageURL = doc[20].string,
            let price = doc[21].float else {
                return nil
        }
        return ProductItem(docId: id, itemcode: itemcode, imageURL: imageURL, brand: brand, name: name, category: category, mainCategory: mainCategory, subCategory: subCategory, innerbarcode: innerbarcode, exportBarcode: exportBarcode, seriesName: seriesName, coo: coo, customerDescription: customerDescription, packingdetail: packingdetail, size: size, capacity: capacity, material: material, thickness: thickness, finish: finish, style: style, capsule: capsule, price: price)
    }
    
    return product
}

// Get All Products
public func getAllProducts(completion: @escaping ([ProductItem]?, Error?) -> Void) {
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.queryByView("all_products", ofDesign: designName, usingParameters: [.descending(true), .includeDocs(true)]) { doc, err in
        if let doc = doc, err == nil {
            do {
                let server = try self.parseProducts(doc)
                completion(server, nil)
            } catch {
                completion(nil ,err)
            }
        } else {
            completion(nil, err)
        }
    }
}
    
    
    

// Get specific Products
public func getProduct(docId: String, completion: @escaping (ProductItem?, Error?) -> Void) {
    
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.retrieve(docId) { (doc, err) in
        guard let doc = doc,
            let docId = doc["_id"].string,
            let itemcode = doc["itemcode"].string,
            let brand = doc["brand"].string,
            let name = doc["name"].string,
            let category = doc["category"].string,
            let mainCategory = doc["mainCategory"].string,
            let subCategory = doc["subCategory"].string,
            let innerbarcode = doc["innerbarcode"].string,
            let exportBarcode = doc["exportBarcode"].string,
            let seriesName = doc["seriesName"].string,
            let coo = doc["coo"].string,
            let customerDescription = doc["customerDescription"].string,
            let packingdetail = doc["packingdetail"].string,
            let size = doc["size"].string,
            let capacity = doc["capacity"].string,
            let material = doc["material"].string,
            let thickness = doc["thickness"].string,
            let finish = doc["finish"].string,
            let style = doc["style"].string,
            let capsule = doc["capsule"].string,
            let imageURL = doc["imageURL"].string,
            let price = doc["price"].float  else {
                completion(nil, err)
                return
        }
        
        let productItem = ProductItem(docId: docId, itemcode: itemcode, imageURL: imageURL, brand: brand, name: name, category: category, mainCategory: mainCategory, subCategory: subCategory, innerbarcode: innerbarcode, exportBarcode: exportBarcode, seriesName: seriesName, coo: coo, customerDescription: customerDescription, packingdetail: packingdetail, size: size, capacity: capacity, material: material, thickness: thickness, finish: finish, style: style, capsule: capsule, price: price)
        completion(productItem, nil)
    }
}

// Add Products
public func addProduct(itemcode: String, brand: String, name: String?, imageURL: String?, category: String?, mainCategory: String?, subCategory: String?, innerbarcode: String?, exportBarcode: String?, seriesName: String?, coo: String?, customerDescription: String?, packingdetail: String?, size: String?, capacity: String?, material: String?, thickness: String?, finish: String?, style: String?, capsule: String?, price: Float, completion: @escaping (ProductItem?, Error?) -> Void) {
    
    let json: [String:Any] = [
        "type": "product",
        "itemcode": itemcode,
        "brand": brand,
        "name": name as Any,
        "category": category as Any,
        "mainCategory": mainCategory as Any,
        "subCategory": subCategory as Any,
        "innerbarcode": innerbarcode as Any,
        "exportBarcode": exportBarcode as Any,
        "seriesName": seriesName as Any,
        "coo": coo as Any,
        "customerDescription": customerDescription as Any,
        "packingdetail": packingdetail as Any,
        "size": size as Any,
        "capacity": capacity as Any,
        "material": material as Any,
        "thickness": thickness as Any,
        "finish": finish as Any,
        "style": style as Any,
        "capsule": capsule as Any,
        "imageURL": imageURL as Any,
        "price": price
        
    ]
    
    let couchClient = CouchDBClient(connectionProperties: connectionProps)
    let database = couchClient.database(dbName)
    
    database.create(JSON(json)) { (id, rev, doc, err) in
        if let id = id {
            let productItem = ProductItem(docId: id, itemcode: itemcode, imageURL: imageURL!, brand: brand, name: name!, category: category!, mainCategory: mainCategory!, subCategory: subCategory!, innerbarcode: innerbarcode, exportBarcode: exportBarcode, seriesName: seriesName, coo: coo, customerDescription: customerDescription, packingdetail: packingdetail, size: size, capacity: capacity, material: material, thickness: thickness, finish: finish, style: style, capsule: capsule, price: price)
            completion(productItem, nil)
        } else {
            completion(nil, err)
        }
    }
}

// Delete specific Food Truck
public func deleteProduct(docId: String, completion: @escaping (Error?) -> Void) {
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

// Update specific Food Truck
public func updateProduct(docId: String, itemcode: String?, imageURL: String?, brand: String?, name: String?, category: String?, mainCategory: String?, subCategory: String?, innerbarcode: String?, exportBarcode: String?, seriesName: String?, coo: String?, customerDescription: String?, packingdetail: String?, size: String?, capacity: String?, material: String?, thickness: String?, finish: String?, style: String?, capsule: String?, price: Float?, completion: @escaping (ProductItem?, Error?) -> Void) {
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
        
        let type = "product"
        let name = name ?? doc["name"].stringValue
        let imageURL = imageURL ?? doc["imageURL"].stringValue
        let itemcode = itemcode ?? doc["itemcode"].stringValue
        let brand = brand ?? doc["brand"].stringValue
        let category = category ?? doc["category"].stringValue
        let mainCategory = mainCategory ?? doc["mainCategory"].stringValue
        let subCategory = subCategory ?? doc["subCategory"].stringValue
        let innerbarcode = innerbarcode ?? doc["innerbarcode"].stringValue
        let exportBarcode = exportBarcode ?? doc["exportBarcode"].stringValue
        let coo = coo ?? doc["coo"].stringValue
        let customerDescription = customerDescription ?? doc["customerDescription"].stringValue
        let packingdetail = packingdetail ?? doc["packingdetail"].stringValue
        let size = size ?? doc["size"].stringValue
        let capacity = capacity ?? doc["capacity"].stringValue
        let material = material ?? doc["material"].stringValue
        let thickness = thickness ?? doc["thickness"].stringValue
        let finish = finish ?? doc["finish"].stringValue
        let style = style ?? doc["style"].stringValue
        let capsule = capsule ?? doc["capsule"].stringValue
        let price = price ?? doc["price"].floatValue
        
        let json: [String: Any] = [
            "type": type,
            "itemcode": itemcode,
            "category": category,
            "mainCategory": mainCategory,
            "subCategory": subCategory,
            "innerbarcode": innerbarcode,
            "exportBarcode": exportBarcode,
            "coo": coo,
            "customerDescription": customerDescription,
            "packingdetail": packingdetail,
            "size": size,
            "capacity": capacity,
            "material": material,
            "thickness": thickness,
            "finish": finish,
            "style": style,
            "capsule": capsule,
            "imageURL": imageURL,
            "price": price,
            
            ]
        
        database.update(docId, rev: rev, document: JSON(json), callback: { (rev, doc, err) in
            guard err == nil else {
                completion(nil, err)
                return
            }
            
            completion(ProductItem(docId: docId, itemcode: itemcode, imageURL: imageURL, brand: brand, name: name, category: category, mainCategory: mainCategory, subCategory: subCategory, innerbarcode: innerbarcode, exportBarcode: exportBarcode, seriesName: seriesName, coo: coo, customerDescription: customerDescription, packingdetail: packingdetail, size: size, capacity: capacity, material: material, thickness: thickness, finish: finish, style: style, capsule: capsule, price: price), nil)
        })
    }
}

}


extension ServerController {
    
    func getProducts(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        hub.getAllProducts{ (products, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                guard let products = products else {
                    try response.status(.internalServerError).end()
                    Log.error("Failed to get Products")
                    return
                }
                let json = JSON(products.toDict())
                try response.status(.OK).send(json: json).end()
            } catch {
                Log.error("Communications error")
            }
        }
    }
    
    func addProduct(request: RouterRequest, response: RouterResponse, next: () -> Void) {
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
        
        
        let itemcode: String = json["itemcode"].stringValue
        let imageURL: String? = json["imageURL"].stringValue
        let brand: String = json["brand"].stringValue
        let name: String? = json["name"].stringValue
        let category: String? = json["category"].stringValue
        let mainCategory: String? = json["mainCategory"].stringValue
        let subCategory: String? = json["subCategory"].stringValue
        let innerbarcode: String? = json["innerbarcode"].stringValue
        let exportBarcode: String? = json["exportBarcode"].stringValue
        let seriesName: String? = json["seriesName"].stringValue
        let coo: String? = json["coo"].stringValue
        let customerDescription: String? = json["customerDescription"].stringValue
        let packingdetail: String? = json["packingdetail"].stringValue
        let size: String? = json["size"].stringValue
        let capacity: String? = json["capacity"].stringValue
        let material: String? = json["material"].stringValue
        let thickness: String? = json["thickness"].stringValue
        let finish: String? = json["finish"].stringValue
        let style: String? = json["style"].stringValue
        let capsule: String? = json["capsule"].stringValue
        let price: Float = json["price"].floatValue
        
        guard brand != "" else {
            response.status(.badRequest)
            Log.error("Necessary fields not supplied")
            return
        }
        hub.addProduct(itemcode: itemcode, brand: brand, name: name, imageURL: imageURL, category: category, mainCategory: mainCategory, subCategory: subCategory, innerbarcode: innerbarcode, exportBarcode: exportBarcode, seriesName: seriesName, coo: coo, customerDescription: customerDescription, packingdetail: packingdetail, size: size, capacity: capacity, material: material, thickness: thickness, finish: finish, style: style, capsule: capsule, price: price) { (product, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                
                guard let product = product else {
                    try response.status(.internalServerError).end()
                    Log.error("Product not found")
                    return
                }
                
                let result = JSON(product.toDict())
                Log.info("\(name) added to Product list")
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
    
    func getProductbyId(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let docId = request.parameters["id"] else {
            response.status(.badRequest)
            Log.error("No ID supplied")
            return
        }
        
        hub.getProduct(docId: docId) { (product, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                
                if let product = product {
                    let result = JSON(product.toDict())
                    try response.status(.OK).send(json: result).end()
                } else {
                    Log.warning("Could not find a truck by that ID")
                    response.status(.notFound)
                    return
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
    
    func deleteProductById(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let docId = request.parameters["id"] else {
            response.status(.badRequest)
            Log.warning("ID not found in request")
            return
        }
        
        hub.deleteProduct(docId: docId) { (err) in
            
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
    
    func updateProductById(request: RouterRequest, response: RouterResponse, next: () -> Void) {
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
        
        let name: String? = json["name"].stringValue == "" ? nil : json["name"].stringValue
        let category: String? = json["category"].stringValue == "" ? nil : json["category"].stringValue
        let price: Float? = json["price"].floatValue == 0 ? nil : json["price"].floatValue
        let itemcode: String? = json["itemcode"].stringValue == "" ? nil : json["itemcode"].stringValue
        let imageURL: String? = json["imageURL"].stringValue == "" ? nil : json["imageURL"].stringValue
        let brand: String? = json["brand"].stringValue == "" ? nil : json["brand"].stringValue
        let mainCategory: String? = json["mainCategory"].stringValue == "" ? nil : json["mainCategory"].stringValue
        let subCategory: String? = json["subCategory"].stringValue == "" ? nil : json["subCategory"].stringValue
        let innerbarcode: String? = json["innerbarcode"].stringValue == "" ? nil : json["innerbarcode"].stringValue
        let exportBarcode: String? = json["exportBarcode"].stringValue == "" ? nil : json["exportBarcode"].stringValue
        let seriesName: String? = json["seriesName"].stringValue == "" ? nil : json["seriesName"].stringValue
        let coo: String? = json["coo"].stringValue == "" ? nil : json["coo"].stringValue
        let customerDescription: String? = json["customerDescription"].stringValue == "" ? nil : json["customerDescription"].stringValue
        let packingdetail: String? = json["packingdetail"].stringValue == "" ? nil : json["packingdetail"].stringValue
        let size: String? = json["size"].stringValue == "" ? nil : json["size"].stringValue
        let capacity: String? = json["capacity"].stringValue == "" ? nil : json["capacity"].stringValue
        let material: String? = json["material"].stringValue == "" ? nil : json["material"].stringValue
        let thickness: String? = json["thickness"].stringValue == "" ? nil : json["thickness"].stringValue
        let finish: String? = json["finish"].stringValue == "" ? nil : json["finish"].stringValue
        let style: String? = json["style"].stringValue == "" ? nil : json["style"].stringValue
        let capsule: String? = json["capsule"].stringValue == "" ? nil : json["capsule"].stringValue
        
        hub.updateProduct(docId: docId, itemcode: itemcode, imageURL: imageURL, brand: brand, name: name, category: category, mainCategory: mainCategory, subCategory: subCategory , innerbarcode: innerbarcode, exportBarcode: exportBarcode, seriesName: seriesName, coo: coo, customerDescription: customerDescription, packingdetail: packingdetail, size: size, capacity: capacity, material: material, thickness: thickness, finish: finish, style: style, capsule: capsule, price: price) { (updatedProduct, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                if let updatedProduct = updatedProduct {
                    let result = JSON(updatedProduct.toDict())
                    try response.status(.OK).send(json: result).end()
                } else {
                    Log.error("Invalid Truck Returned")
                    try response.status(.badRequest).end()
                }
            } catch {
                Log.error("Communications Error")
            }
        }
    }
}
