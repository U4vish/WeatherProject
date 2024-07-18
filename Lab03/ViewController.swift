//done by Anup Rayamajhi

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
  
   private let locationManager=CLLocationManager()
    var currentTempinC:Float?=nil;
    var currentTempinF:Float?=nil;
    
    var searchedCities: [WeatherResponse]? = []
  

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
       
    @IBOutlet weak var weatherConditionImage: UIImageView!
    

    @IBOutlet weak var locationLabel: UILabel!
    
    
    @IBOutlet weak var conditionLabel: UILabel!
   
    @IBOutlet weak var sButton: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        self.sButton.setOn(true, animated: true)


    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "gotosecond",
              let destinationVC = segue.destination as? secondPage {
            destinationVC.searchedCities = searchedCities
              destinationVC.isC = sButton.isOn
          }
      }
    
    
    @IBAction func onCitiesTap(_ sender: Any) {
        
        performSegue(withIdentifier: "gotosecond", sender: self)
    }
    
    

    @IBAction func onSwitchToggle(_ sender: UISwitch) {
        if sButton.isOn {
            
            self.temperatureLabel.text =  "\(currentTempinC ?? 0.0)C"
            } else {
          
            self.temperatureLabel.text =  "\(currentTempinF ?? 0.0)F"

        }
    }
    
    
    @IBAction func onLocationTapp(_ sender: UIButton) {
        
        searchTextField.text="";
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    

    
    @IBAction func onSearchTap(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
    }
    
   
    
    private func displayImage(icon:String){
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemRed, .systemTeal, .systemYellow])
        weatherConditionImage.preferredSymbolConfiguration = config
        weatherConditionImage.image=UIImage(systemName: icon)
    }
    
  
    private func loadWeather(search: String?){
        guard let search=search else{
            return
        }
        
        print(search)
        //STEP 1: GET URL
        guard let  url = getUrl(city: search)else{
            print("Cound not get URL")
            return
        }
        
        print(url)
        
        //STEP 2: Create Urlsession
        
        let session = URLSession.shared
        
        //STEP 3: Create task for session
        let dataTask = session.dataTask(with: url){data,response,error in
        print("Network call finished")
            //
            guard error == nil else{
                print("received error")
                return
            }
            guard let data = data else{
                print("No data found")
                return
            }
        
            //decode the data
            if let weatherRes = self.parseJson(data:data){
                print(weatherRes)
                

                DispatchQueue.main.async {
                    self.sButton.isEnabled = true

                    self.locationLabel.text = weatherRes.location.name;
                    self.currentTempinC=weatherRes.current.temp_c;
                    self.currentTempinF=weatherRes.current.temp_f;
                    self.conditionLabel.text = weatherRes.current.condition.text
                                        
                    if(self.sButton.isOn){
                        self.temperatureLabel.text="\(weatherRes.current.temp_c)C";
                    }else{
                        self.temperatureLabel.text="\(weatherRes.current.temp_f)F";
                    }
        
                    let icon = mapWeatherIcon(code: weatherRes.current.condition.code,is_day: weatherRes.current.is_day)
                    self.displayImage(icon: icon)
                    // Set app appearance mode based on whether it's day or night
                    if weatherRes.current.is_day == 1 {
                    self.overrideUserInterfaceStyle = .light
                    } else {
                    self.overrideUserInterfaceStyle = .dark
                    }
                    self.searchedCities?.append(weatherRes)

                }
                

                
        
            }
           
        }
        
        //STEP 4: Start the task
        dataTask.resume()
    }
    
     
    private func getUrl(city: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndPoint = "current.json"
        let apiKey = "63bf3386574546de88d175954242304"
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "\(baseUrl)\(currentEndPoint)?key=\(apiKey)&q=\(encodedCity)"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return url
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
          loadWeather(search: "\(latitude),\(longitude)")
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
    }
    
    private func parseJson(data:Data)->WeatherResponse?{
        let decoder = JSONDecoder()
        var weather:WeatherResponse?
        do{
             weather = try decoder.decode(WeatherResponse.self,from: data)
        }catch{
            print("ERROR DECODING")
        }
        return weather;
    }
}


struct WeatherResponse:Decodable{
    let location: Location
    let current:Weather
}


struct Location:Decodable{
    let name:String
}

struct Weather:Decodable{
    let is_day: Int
    let temp_c:Float
    let temp_f: Float
    let condition:WeatherCondition
    
}


struct WeatherCondition:Decodable{
    let text:String
    let code:Int
}


let weatherIcons: [Int: (day: String, night: String)] = [
    1000: ("sun.max", "moon.stars.fill"),
    1003: ("cloud.sun.fill", "cloud.moon.fill"),
    1006: ("cloud.fill", "cloud.fill"),
    1009: ("cloud.fog.fill", "cloud.fog.fill"),
    1030: ("cloud.fog.fill", "cloud.fog.fill"),
    1063: ("cloud.drizzle.fill", "cloud.drizzle.fill"),
    1066: ("cloud.sun.rain.fill", "cloud.moon.rain.fill"),
    1069: ("cloud.sun.sleet.fill", "cloud.moon.sleet.fill"),
    1072: ("cloud.sun.hail.fill", "cloud.moon.hail.fill"),
    1087: ("cloud.bolt.fill", "cloud.bolt.fill"),
    1114: ("wind.snow", "wind.snow"),
    1117: ("wind.snow", "wind.snow"),
    1135: ("cloud.fog.fill", "cloud.fog.fill"),
    1147: ("cloud.fog.fill", "cloud.fog.fill"),
    1150: ("cloud.drizzle.fill", "cloud.drizzle.fill"),
    1153: ("cloud.drizzle.fill", "cloud.drizzle.fill"),
    1168: ("cloud.drizzle.fill", "cloud.drizzle.fill"),
    1171: ("cloud.drizzle.fill", "cloud.drizzle.fill"),
    1180: ("cloud.rain.fill", "cloud.rain.fill"),
    1183: ("cloud.rain.fill", "cloud.rain.fill"),
    1186: ("cloud.heavyrain.fill", "cloud.heavyrain.fill"),
    1189: ("cloud.heavyrain.fill", "cloud.heavyrain.fill"),
    1192: ("cloud.heavyrain.fill", "cloud.heavyrain.fill"),
    1195: ("cloud.heavyrain.fill", "cloud.heavyrain.fill"),
    1198: ("cloud.sleet.fill", "cloud.sleet.fill"),
    1201: ("cloud.sleet.fill", "cloud.sleet.fill"),
    1204: ("cloud.sleet.fill", "cloud.sleet.fill"),
    1207: ("cloud.sleet.fill", "cloud.sleet.fill"),
    1210: ("cloud.snow.fill", "cloud.snow.fill"),
    1213: ("cloud.snow.fill", "cloud.snow.fill"),
    1216: ("cloud.snow.fill", "cloud.snow.fill"),
    1219: ("cloud.snow.fill", "cloud.snow.fill"),
    1222: ("cloud.snow.fill", "cloud.snow.fill"),
    1225: ("cloud.snow.fill", "cloud.snow.fill"),
    1237: ("cloud.hail.fill", "cloud.hail.fill"),
    1240: ("cloud.rain.fill", "cloud.rain.fill"),
    1243: ("cloud.heavyrain.fill", "cloud.heavyrain.fill"),
    1246: ("cloud.heavyrain.fill", "cloud.heavyrain.fill"),
    1249: ("cloud.sleet.fill", "cloud.sleet.fill"),
    1252: ("cloud.sleet.fill", "cloud.sleet.fill"),
    1255: ("cloud.snow.fill", "cloud.snow.fill"),
    1258: ("cloud.snow.fill", "cloud.snow.fill"),
    1261: ("cloud.hail.fill", "cloud.hail.fill"),
    1264: ("cloud.hail.fill", "cloud.hail.fill"),
    1273: ("cloud.bolt.fill", "cloud.bolt.fill"),
    1276: ("cloud.bolt.fill", "cloud.bolt.fill"),
    1279: ("cloud.bolt.fill", "cloud.bolt.fill"),
    1282: ("cloud.bolt.fill", "cloud.bolt.fill")
]


func mapWeatherIcon(code: Int, is_day: Int) -> String {
  guard let icons = weatherIcons[code] else {
      return "sun.max.circle"
  }

  return is_day==1 ? icons.day : icons.night
}



