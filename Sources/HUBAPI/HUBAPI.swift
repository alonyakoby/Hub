import SwiftyJSON
import Foundation
public protocol HUBAPI {

    //PRODUCTS
    
    func getAllProducts(completion: @escaping ([ProductItem]?, Error?) -> Void)
    
    func getProduct(docId: String, completion: @escaping (ProductItem?, Error?) -> Void)
    
    func addProduct(itemcode: String, brand: String, name: String?, imageURL: String?, category: String?, mainCategory: String?, subCategory: String?, innerbarcode: String?, exportBarcode: String?, seriesName: String?, coo: String?, customerDescription: String?, packingdetail: String?, size: String?, capacity: String?, material: String?, thickness: String?, finish: String?, style: String?, capsule: String?, price: Float, completion: @escaping (ProductItem?, Error?) -> Void)
    
    func clearAll(completion: @escaping (Error?) -> Void)
    
    func deleteProduct(docId: String, completion: @escaping (Error?) -> Void)
    
    func updateProduct(docId: String, itemcode: String?, imageURL: String?, brand: String?, name: String?, category: String?, mainCategory: String?, subCategory: String?, innerbarcode: String?, exportBarcode: String?, seriesName: String?, coo: String?, customerDescription: String?, packingdetail: String?, size: String?, capacity: String?, material: String?, thickness: String?, finish: String?, style: String?, capsule: String?, price: Float?, completion: @escaping (ProductItem?, Error?) -> Void)

    // USERS
    
    func getAllUsers(completion: @escaping ([UserItem]?, Error?) -> Void)

    func getUser(docId: String, completion: @escaping (UserItem?, Error?) -> Void)
    
    func addUser(first: String, last: String, profileImageURL: String, email: String, password: String, mobile: String, office: String, officeaddress: String, country: String, myProds: [String]?, completion: @escaping (UserItem?, Error?) -> Void)
    
    func updateUser(docId: String, first: String?, last: String?, profileImageURL: String?, email: String?, password: String?, mobile: String?, office: String?, officeaddress: String?, country: String?, myProds: [String]?, completion: @escaping (UserItem?, Error?) -> Void)
    
    func deleteUser(docId: String, completion: @escaping (Error?) -> Void)

}
