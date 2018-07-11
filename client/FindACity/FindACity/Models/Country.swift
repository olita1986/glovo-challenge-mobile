//
//  Country.swift
//  FindACity
//
//  Created by Nisum on 7/8/18.
//  Copyright © 2018 Orlando Arzola. All rights reserved.
//

import Foundation

struct Country: Decodable {
    let code: String
    let name: String
    
    init(code: String, name: String) {
        self.code = code
        self.name = name
    }
    
    enum CountryKeys: String, CodingKey {
        case code
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CountryKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let code = try container.decode(String.self, forKey: .code)
        
        self.init(code: code, name: name)
    }
}
