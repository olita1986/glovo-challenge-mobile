//
//  APILocation.swift
//  FindACity
//
//  Created by Nisum on 7/8/18.
//  Copyright © 2018 Orlando Arzola. All rights reserved.
//

import Foundation

class APILocation: APILocationService {
    
    let urlSession: URLSession
    let decoder: JSONDecoder
    
    init(urlSession: URLSession = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.decoder = decoder
    }
    
    func getCities(onSuccess: @escaping (_ cities: [City]?) -> Void) {
        genericRequest(withType: [City].self, url: "http://localhost:3000/api/cities/", onSuccess: onSuccess)
    }
    
    func getCountry(onSuccess: @escaping (_ countries: [Country]?) -> Void) {
        genericRequest(withType: [Country].self, url: "http://localhost:3000/api/countries/", onSuccess: onSuccess)
    }
    
    func findCity(withId id: String, onSuccess: @escaping (_ city: City?) -> Void) {
        genericRequest(withType: City.self, url: "http://localhost:3000/api/cities/\(id)", onSuccess: onSuccess)
    }
    
    private func genericRequest<T: Decodable>(withType type: T.Type, url: String, onSuccess: @escaping (_ decodedObject: T?) -> Void) {
        let request = URLRequest(url: URL(string: url)!)
        urlSession.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decodedObject = try self.decoder.decode(T.self, from: data)
                onSuccess(decodedObject)
            } catch {
                onSuccess(nil)
            }
        }.resume()
    }
}

protocol APILocationService {
    func getCities(onSuccess: @escaping (_ cities: [City]?) -> Void)
    func getCountry(onSuccess: @escaping (_ countries: [Country]?) -> Void)
    func findCity(withId id: String, onSuccess: @escaping (_ city: City?) -> Void)
}
