//
//  City.swift
//  FindACity
//
//  Created by Nisum on 7/8/18.
//  Copyright © 2018 Orlando Arzola. All rights reserved.
//

struct City: Decodable {
    let workingArea: [String]
    let code: String
    let name: String
    let countryCode: String
    let languageCode: String
    let currency: String
    let timeZone: String
    
    init(workingArea: [String], code: String, name: String, countryCode: String, languageCode: String, currency: String, timeZone: String) {
        self.workingArea = workingArea
        self.code = code
        self.name = name
        self.countryCode  = countryCode
        self.languageCode = languageCode
        self.currency = currency
        self.timeZone = timeZone
    }
    
    enum CityKeys: String, CodingKey {
        case code
        case name
        case workingArea = "working_area"
        case countryCode = "country_code"
        case languageCode = "language_code"
        case currency
        case timeZone = "time_zone"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CityKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let code = try container.decode(String.self, forKey: .code)
        let countryCode = try container.decode(String.self, forKey: .countryCode)
        let workingArea = try container.decode([String].self, forKey: .workingArea)
        let languageCode = try container.decodeIfPresent(String.self, forKey: .languageCode) ?? ""
        let currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? ""
        let timeZone = try container.decodeIfPresent(String.self, forKey: .timeZone) ?? ""
        
        self.init(workingArea: workingArea, code: code, name: name, countryCode: countryCode, languageCode: languageCode, currency: currency, timeZone: timeZone)
    }
}
