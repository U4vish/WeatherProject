//
//  ViewController.swift
//  Lab03
//
//  Created by Urvish Patel on 2024-04-23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var weatherStr: UILabel!
    @IBOutlet weak var FCToggle: UISwitch!
    
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var tempStr: UILabel!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var Search: UIButton!
    @IBOutlet weak var currentLocation: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    @IBAction func locationClicked(_ sender: UIButton) {
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            let location = locationManager.location
            
            WeatherApi().getCords(lat: location?.coordinate.latitude ?? 0, lon: location?.coordinate.longitude ?? 0, completion: {
                (weather) in
                self.showUI(weather: weather)
//                print(weather)
            })
        } else {
            print("No location")
        }
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        let searchStr = searchText.text
        
        WeatherApi().getCityStat(city: searchStr ?? "") {
            (weather) in
            self.showUI(weather: weather)
        }
    }
    
    func showUI (weather: WeatherModel) {
        
        let mainStr = weather.current.condition.text
        let location = weather.location.name
        let province = weather.location.region
        
        let celcius = weather.current.temp_c
        let farenht = weather.current.temp_f
        
        
        DispatchQueue.main.async {
            self.weatherStr.text = "\(mainStr) in \(location), \(province)"
            
            if self.FCToggle.isOn {
                self.tempStr.text = "\(celcius)' C"
            } else {
                self.tempStr.text = "\(farenht)' F"
            }
            
            switch mainStr {
            case "Sunny":
                self.Image.image = UIImage(systemName: "sun.max")
                break
                
            case "Clear":
                self.Image.image = UIImage(systemName: "moon")
                break
                
            case "Cloudy":
                self.Image.image = UIImage(systemName: "cloud")
                break
                
            case "Partly cloudy":
                self.Image.image = UIImage(systemName: "cloud.sun")
                break
                
            default:
                self.Image.image = UIImage(systemName: "sun.min")
            }
            
        }
    }
    @IBAction func FToggleed(_ sender: UISwitch) {
        
        self.searchTapped(sender)
        
    }
    
    

}

