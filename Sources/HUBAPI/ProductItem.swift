//
//  ProductItem.swift
//  HUBAPI
//
//  Created by Alon Yakoby on 02/05/2017.
//
//

import Foundation
import SwiftyJSON

typealias JSONDictionary = [String: Any]

protocol DictionaryConvertable {
    func toDict() -> JSONDictionary
}

public struct ProductItem {
    
    // MARK - MAIN VARS
    
    // MARK VARS/CLASSES NEED TO ADD
    //    public let packingDimensions: Specs
    
    
    // ID
    public let docId: String
    // Item code
    public let itemcode: String
    //imageUrl
    public let imageURL: String
    //Brand
    public let brand: String
    //Name of Item
    public let name: String
    // Category
    public let category: String
    //Main Category
    public let mainCategory: String
    //Sub Category
    public let subCategory: String
    //Inner Barcode
    public let innerbarcode: String?
    //Export Barcode
    public let exportBarcode: String?
    //Series Name
    public let seriesName: String?
    //COO
    public let coo: String?
    //CustomerDescription
    public let customerDescription: String?
    //Packing Detail
    public let packingdetail: String?
    //Size
    public let size: String?
    // capacity
    public let capacity: String?
    // Material
    public let material: String?
    // Thickness
    public let thickness: String?
    // Finish
    public let finish: String?
    // Style
    public let style: String?
    //capsule
    public let capsule: String?
    // Price
    public let price: Float
    
    
    public init(docId: String, itemcode: String, imageURL: String, brand: String, name: String, category: String, mainCategory: String, subCategory: String, innerbarcode: String?, exportBarcode: String?, seriesName: String?, coo: String?, customerDescription: String?, packingdetail: String?, size: String?, capacity: String?, material: String?, thickness: String?, finish: String?, style: String?, capsule: String?, price: Float) {
        
        self.docId = docId
        self.itemcode = itemcode
        self.imageURL = imageURL
        self.brand = brand
        self.name = name
        self.category = category
        self.mainCategory = mainCategory
        self.subCategory = subCategory
        self.innerbarcode = innerbarcode
        self.exportBarcode = exportBarcode
        self.seriesName = seriesName
        self.coo = coo
        self.customerDescription = customerDescription
        self.packingdetail = packingdetail
        self.size = size
        self.capacity = capacity
        self.material = material
        self.thickness = thickness
        self.finish = finish
        self.style = style
        self.capsule = capsule
        self.price = price
        
        
    }
}

extension ProductItem: Equatable {
    public static func == (lhs: ProductItem, rhs: ProductItem) -> Bool {
        return lhs.docId == rhs.docId &&
            lhs.itemcode == rhs.itemcode &&
            lhs.imageURL == rhs.imageURL &&
            lhs.brand == rhs.brand &&
            lhs.name == rhs.name &&
            lhs.mainCategory == rhs.mainCategory &&
            lhs.category == rhs.category &&
            lhs.subCategory == rhs.subCategory &&
            lhs.innerbarcode == rhs.innerbarcode &&
            lhs.exportBarcode == rhs.exportBarcode &&
            lhs.seriesName == rhs.seriesName &&
            lhs.coo == rhs.coo &&
            lhs.customerDescription == rhs.customerDescription &&
            lhs.packingdetail == rhs.packingdetail &&
            lhs.size == rhs.size &&
            lhs.capacity == rhs.capacity &&
            lhs.material == rhs.material &&
            lhs.thickness == rhs.thickness &&
            lhs.finish == rhs.finish &&
            lhs.style == rhs.style &&
            lhs.capsule == rhs.capsule &&
            lhs.price == rhs.price
        
        
    }
}

extension ProductItem: DictionaryConvertable {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = self.docId
        result["brand"] = self.brand
        result["itemcode"] = self.itemcode
        result["imageURL"] = self.imageURL
        result["name"] = self.name
        result["mainCategory"] = self.mainCategory
        result["category"] = self.category
        result["subCategory"] = self.subCategory
        result["innerbarcode"] = self.innerbarcode
        result["exportBarcode"] = self.exportBarcode
        result["seriesName"] = self.seriesName
        result["coo"] = self.coo
        result["customerDescription"] = self.customerDescription
        result["packingdetail"] = self.packingdetail
        result["size"] = self.size
        result["capacity"] = self.capacity
        result["material"] = self.material
        result["thickness"] = self.thickness
        result["finish"] = self.finish
        result["style"] = self.style
        result["capsule"] = self.capsule
        result["price"] = self.price
        
        return result
    }
}


extension Array where Element: DictionaryConvertable {
    func toDict() -> [JSONDictionary] {
        return self.map { $0.toDict() }
    }
}

