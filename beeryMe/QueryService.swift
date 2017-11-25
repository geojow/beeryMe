//
//  QueryService.swift
//  beeryMe
//
//  Created by George Jowitt on 07/11/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class QueryService {
    
    // MARK: Type Alias'
    
    typealias QueryResult = ([Pub]?, String) -> ()
    
    // MARK: Variables & Constants
    
    var pubs: [Pub] = []
    var errorMessage = ""
    var defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    let client_id = foursquareClientId
    let client_secret = foursquareClientSecret
    
    // MARK: Networking Functionality
    
    func getSearchResults(location: CLLocation, searchRadius: Int, numberOfResults: Int, completion: @escaping QueryResult) {
        
        dataTask?.cancel()
        
        let centreLatitude = location.coordinate.latitude, centreLongitude = location.coordinate.longitude, radius = searchRadius, numberOfResults = numberOfResults
        
        let urlString = "https://api.foursquare.com/v2/venues/search?ll=\(centreLatitude),\(centreLongitude)&v=20160607&intent=checkin&limit=\(numberOfResults)&radius=\(radius)&categoryId=4bf58dd8d48988d116941735,50327c8591d4c4b30a586d5d&client_id=\(client_id)&client_secret=\(client_secret)"
        let queryUrl = URL(string: urlString)
        
        guard let url = queryUrl else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        dataTask = defaultSession.dataTask(with: request) { data, response, error in
            
            defer { self.dataTask = nil }
            
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                self.updateSearchResults(data)
            }
            
            DispatchQueue.main.async {
                completion(self.pubs, self.errorMessage)
            }
        }
        dataTask?.resume()
    }
    
    fileprivate func updateSearchResults(_ data: Data) {
        
        pubs.removeAll()
        
        do {
            let json =  try JSON(data: data)
            let venues = json["response"]["venues"]
            for venueIndex in 0..<venues.count {
                let id = venues[venueIndex]["id"].string
                let name = venues[venueIndex]["name"].string
                let location = venues[venueIndex]["location"]
                
                if let latitude = location["lat"].double, let longitude = location["lng"].double {
                    let newPub = Pub(id: id!, name: name!, latitude: latitude, longitude: longitude, visited: false)
                    if let formattedAddress = location["formattedAddress"].array {
                        var address = ""
                        if formattedAddress.count > 1 {
                            for item in formattedAddress {
                                address += "\(item.string!)\n"
                            }
                        } else {
                            address = "No formatted address found!"
                        }
                        newPub.formattedAddress += address
                    }
                    if let pubUrl = venues[venueIndex]["url"].string {
                        if pubUrl.count > 3 {
                            newPub.website = "Website:\n\(pubUrl)"
                        }
                    }
                    if let street = location["address"].string {
                        newPub.street = street
                    }
                    
                    newPub.visited = UserDefaults.standard.isPubWithIdInUserDefaults(id: newPub.id)
                    print(newPub.visited)
                    pubs.append(newPub)
                }

            }
        } catch {
            print(error)
        }
        
        
    }
}
