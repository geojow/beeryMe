//
//  QueryService.swift
//  beeryMe
//
//  Created by George Jowitt on 07/11/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import Foundation
import CoreLocation

class QueryService {
    
    typealias QueryResult = ([Pub]?, String) -> ()
    
    var pubs: [Pub] = []
    var errorMessage = ""
    
    var defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    let zomatoKey = "846882afa169c6314aa0953525a382cf"
    
    func getSearchResults(location: CLLocation, completion: @escaping QueryResult) {
        
        dataTask?.cancel()
        
        let centreLatitude = location.coordinate.latitude, centreLongitude = location.coordinate.longitude, radius = 100
     
        let urlString = "https://developers.zomato.com/api/v2.1/search?lat=\(centreLatitude)&lon=\(centreLongitude)&radius=\(radius)&category=11&sort=real_distance"
        
        let queryUrl = URL(string: urlString)
        
        guard let url = queryUrl else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(zomatoKey, forHTTPHeaderField: "user_key")
            
            dataTask = defaultSession.dataTask(with: request) { data, response, error in
                
                defer { self.dataTask = nil }
                //5
                if let error = error {
                    self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    self.updateSearchResults(data)
                }
                //6
                DispatchQueue.main.async {
                    completion(self.pubs, self.errorMessage)
                }
                
            
            }
        
        
        dataTask?.resume()
    }
    
    fileprivate func updateSearchResults(_ data: Data) {
    
        pubs.removeAll()
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            let jsonPubs = jsonResult?["restaurants"] as! [AnyObject]
            
            for pub in jsonPubs {
                
                let myPub = pub["restaurant"] as! NSDictionary
                let name = myPub["name"] as! String
                let location = myPub["location"] as? NSDictionary
                let latitude = (location!["latitude"] as! NSString).doubleValue
                let longitude = (location!["longitude"] as! NSString).doubleValue
                let newPub = Pub(name: name, latitude: latitude, longitude: longitude, visited: false)
                pubs.append(newPub)
            }
        } catch {
            print(error)
        }
        
    }
}
