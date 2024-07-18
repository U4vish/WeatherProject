
import UIKit

class secondPage: UIViewController {
    
    var isC:Bool = false;
  
    var searchedCities:[WeatherResponse]? = [
        

    
    ]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension secondPage: UITableViewDelegate {
    
    }

extension secondPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return searchedCities?.count ?? 0
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
           
           // Safely unwrap searchedCities using optional binding
           if let strongCities = searchedCities {
               let item = strongCities[indexPath.row]
               var content = cell.defaultContentConfiguration()
               content.text = item.location.name
               let temp = isC == true ? (item.current.temp_c) : item.current.temp_f
               content.secondaryText =  String(temp) + ( isC == true ? " C" : " F")
               let icon = mapWeatherIcon(code: item.current.condition.code,is_day: item.current.is_day)
               content.image = UIImage(systemName: icon)
               cell.contentConfiguration = content
           }
           
           return cell
       }
}





