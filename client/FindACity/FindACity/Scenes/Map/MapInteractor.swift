//
//  MapInteractor.swift
//  FindACity
//
//  Created by Nisum on 7/8/18.
//  Copyright (c) 2018 Orlando Arzola. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import CoreLocation

enum GlobalErrors {
    case notValidCountry
    case notValidCity
    case genericError
}

protocol MapBusinessLogic {
    func getCountriesAndCities()
    func userIsInValidCountryAndCity(request: Map.PlaceMark.Request)
    func updateMap(request: Map.CurrentCity.Request)
}

protocol MapDataStore {
    var countries: [Country] { get set }
    var cities: [City] { get set }
    var city: City? { get set }
    var isLocationSelected: Bool { get set }
}

class MapInteractor: MapBusinessLogic, MapDataStore {
    var isLocationSelected: Bool = false
    var cities: [City] = []
    var countries: [Country] = []
    var city: City?
    var geoCoder = CLGeocoder()
    
    var presenter: MapPresentationLogic?
    var worker: MapWorker = MapWorker()
    var dispatchGroup = DispatchGroup()
    
    func updateMap(request: Map.CurrentCity.Request) {
        geoCoder.geocodeAddressString("\(request.city.name), \(request.country)") { [weak self](placemarks, error) in
            guard error == nil else { return }
            guard let placemarks = placemarks, let placemark = placemarks.first else {return}
            let response = Map.Location.Response(location: placemark.location!, workingArea: request.city.workingArea)
            self?.presenter?.presentUpdateLocation(response: response)
            self?.findCity(withId: request.city.code)
        }
    }
    
    func getCountriesAndCities() {
        presenter?.presentLoading()
        dispatchGroup.enter()
        worker.getCountries {[weak self] (countries) in
            self?.dispatchGroup.leave()
            guard let countries = countries else { return }
            self?.countries = countries
        }
        
        dispatchGroup.enter()
        worker.getCities {[weak self] (cities) in
            self?.dispatchGroup.leave()
            guard let cities = cities else { return }
            self?.cities = cities
        }
        
        dispatchGroup.notify(queue: .main) {[weak self] in
            self?.presenter?.hideLoading()
            self?.presenter?.presentView()
        }
    }
        
    func userIsInValidCountryAndCity(request: Map.PlaceMark.Request) {
        guard let country = countries.first(where: {$0.code == request.countryCode}) else {
            let response = Map.Error.Response(error: .notValidCountry)
            self.presenter?.presentError(response: response)
            return
        }
        let currentCities = cities.filter({$0.countryCode == country.code})
        guard let city = currentCities.first(where: {$0.code.prefix(2) == request.cityCode}) else {
            let response = Map.Error.Response(error: .notValidCity)
            self.presenter?.presentError(response: response)
            return
        }
        findCity(withId: city.code)
    }
    
    private func findCity(withId id: String) {
        presenter?.presentLoading()
        worker.getCity(withId: id) { [weak self](city) in
            DispatchQueue.main.async {
                self?.presenter?.hideLoading()
            }
            guard let city = city else {
                DispatchQueue.main.async {
                    let response = Map.Error.Response(error: .notValidCity)
                    self?.presenter?.presentError(response: response)
                }
                return
            }
            self?.city = city
            let response = Map.CurrentCity.Response(city: city)
            let response2 = Map.Location.Response(location: CLLocation(latitude: 0, longitude: 0), workingArea: city.workingArea)
            DispatchQueue.main.async {
                self?.presenter?.presentCityInfo(response: response)
                self?.presenter?.presentWorkingArea(response: response2)
            }
        }
    }
}
