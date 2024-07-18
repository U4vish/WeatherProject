
//  WeatherApi.swift
//  Lab03

import Foundation

public class WeatherApi {
    
    static var weather: WeatherModel = WeatherModel()
    static let shared = WeatherApi()
    
    let Url = "https://api.weatherapi.com/v1/current.json?key=63bf3386574546de88d175954242304&q="
    
    func getCords (lat: Double, lon: Double,completion: @escaping (WeatherModel) -> Void) {
        let url = URL(string: "\(Url)\(lat),\(lon)")!
        
        print(url)
        
        let dataTask = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
                
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                        do {
                            let weather = try JSONDecoder().decode(WeatherModel.self, from: data)
                            WeatherApi.weather = weather
                            completion(weather)
                        } catch {
                            print("error in", error)
                        }
                    }
        }
        
        dataTask.resume()
    }
    
    func getCityStat(city: String, completion: @escaping (WeatherModel) -> Void) {
        
        let url = URL(string: "\(Url)\(city)")!
        
        let dataTask = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
                if let data = data {
                    do{
                        let weather = try JSONDecoder().decode(WeatherModel.self, from: data)
                        completion(weather)
                    } catch {
                        print("error in", error)
                    }
                }
        }
        
        dataTask.resume()
    }
}
