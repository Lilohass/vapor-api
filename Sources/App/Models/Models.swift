//
//  Models.swift
//  AppTests
//
//  Created by William Hass on 2020-02-01.
//

import Foundation
import FluentPostgreSQL


enum UnitOfMeasurement: String, CaseIterable {
    case unknown
    case unit
    case kg
    case lb
    case g
    case ml
    case l
    case oz
    
    init?(fromString: String?) {
        guard let fromString = fromString,
            let value = UnitOfMeasurement(rawValue: fromString) else { return nil }
        self = value
    }
}


enum BarcodeType: Int {
    case unknown
    case ean13
}

class Barcode {
    var dateRegistered = Date(timeIntervalSince1970: 0)
    var value = ""
    private(set) var typeRawValue = BarcodeType.unknown.rawValue
    var type: BarcodeType? {
        get { BarcodeType(rawValue: typeRawValue) }
        set { typeRawValue = newValue?.rawValue ?? BarcodeType.unknown.rawValue }
    }
    convenience init(value: String) {
        self.init()
        self.value = value
    }
}

class UserGroup {
    var name = ""
    var color = ""
    var dateRegistered = Date(timeIntervalSince1970: 0)
}


class ProductPrice {
    var product: Product?
    var price: Double = 0
    var currency = ""
    var isOnSale = false
    var supermarketBranch: SupermarketBranch?
    var dateRegistered = Date()
}

class Address {
    var street = ""
    var number: Int = 0
    var complement = ""
    var zipCode = ""
    var city = ""
    var stateOrProvince = ""
    var country = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var dateRegistered = Date(timeIntervalSince1970: 0)
}


class SupermarketBranch {
    var supermarket: Supermarket?
    var shortDescription = ""
    var address: Address?
    var picture: Picture?
    var dateRegistered = Date(timeIntervalSince1970: 0)
}

class Supermarket {
    var name = ""
    var shortDescription = ""
    var picture: Picture?
    var brandLogo: Data?
    var dateRegistered = Date(timeIntervalSince1970: 0)
}


class PersistentColor {
    var red: Double = 0
    var green: Double = 0
    var blue: Double = 0
}

class ProductCategory {
    var name = ""
    var color: PersistentColor?
    var icon: Data?
    var dateRegistered = Date(timeIntervalSince1970: 0)
}

// If picture request contains ID:
//  - Check for lastChange
// If picture request DOES NOT contain ID:
//  - Create a bew picture in DB with current User as owner
final class Picture: PostgreSQLModel {
    var id: Int?
    var path = ""
    var picture: Data? = nil
    var dateRegistered = Date(timeIntervalSince1970: 0)
    var lastChange = Date(timeIntervalSince1970: 0)
}

final class Brand: PostgreSQLModel {
    var id: Int?
    var name = ""
    var picture: Picture?
    var dateRegistered = Date(timeIntervalSince1970: 0)
}

class ProductRate {
    var min: Double = 0
    var max: Double = 0
    var value: Double = 0
}


class Product {
    var name = ""
    var shortDescription: String?
    private(set) var unitOfMeasurementRawValue: String?
    var amount: Double = 0
    var brand: Brand?
    var barCode: Barcode?
    var dateRegistered = Date(timeIntervalSince1970: 0)
    var rate: ProductRate?
    let pictures = [Picture]()
    let categories = [ProductCategory]()
    
    var unitOfMeasurement: UnitOfMeasurement? {
        get { UnitOfMeasurement(fromString: unitOfMeasurementRawValue) }
        set { unitOfMeasurementRawValue = newValue?.rawValue ?? UnitOfMeasurement.unknown.rawValue }
    }
    
    public static func ==(lhs: Product, rhs: Product) -> Bool {
        lhs.name == rhs.name
            && lhs.brand?.name == rhs.brand?.name
            && lhs.barCode?.value == rhs.barCode?.value
    }
    
    func isEqual(_ object: Any?) -> Bool {
        guard let otherProduct = object as? Product else { return false }
        return self == otherProduct
    }
    
}
