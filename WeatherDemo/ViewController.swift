//
//  ViewController.swift
//  WeatherDemo
//
//  Created by TheGrey on 2020/2/17.
//  Copyright © 2020 thegrey. All rights reserved.
//

import UIKit

struct CityWeather {
    var location:String?
    var weatherInfo:String?
    var maxTemp:String?
    var minTemp:String?
    var tempFeel:String?
}

struct AllData:Decodable{
    var weather:[Weather]?
    var main:Main?
    var name:String
}
struct Weather:Decodable{
    var main:String?
}
struct Main:Decodable{
    var temp:Double?
    var temp_min:Double?
    var temp_max:Double?
}

class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var weatherInfo: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var tempFeel: UILabel!
    let cityArray = ["請選擇","台北市","台中市","高雄市","台南市","南投"]
    let cityIDArray = ["","1668341","1668399","1673820","1668355","1671566"]
    var choosedCity:String = ""
    //var cityID:String = "1668399"
    var apiKey:String = "4bfbe50cf72abfe9e209b7c2a58289e7"
    let urlSession = URLSession(configuration: .default)
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return cityArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cityArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 && row != 0{
            let cityId = cityIDArray[row]
//            print("cityID: \(cityId)")
            choosedCity = cityArray[row]
//            print("choosedCity: \(choosedCity)")
            let apiAddress:String = "Https://api.openweathermap.org/data/2.5/weather?id=\(cityId)&appid=\(apiKey)"
//            print("apiAddress= \(apiAddress)")
            if let apiUrl = URL(string: apiAddress){
                let task = urlSession.dataTask(with: apiUrl, completionHandler:{
                    (data,response,error) in
                    if error != nil{
                        print("error != nil")
                        let errorcode = (error! as NSError).code
                        print("errorcode= \(errorcode)")
                        if errorcode == -1009{
                            print("no internet")
                        }else{
                            print("something wrong")
                        }
                        return
                    }
                    if let loadedData = data{
                        print("got data")
                        do{
                            let okData = try JSONDecoder().decode(AllData.self, from: loadedData)
                            let tempInK = okData.main?.temp
                            let tempInC = String(tempInK! - 273.15)
                            let tempMaxInK = okData.main?.temp_max
                            let tempMaxInC = String(format: "%.0f", tempMaxInK! - 273.15)
                            
                            let tempMinInK = okData.main?.temp_min
                            let tempMinInC = String(format: "%0.f", tempMinInK! - 273.15)
                            
                            let name = okData.name
                            let weatherType = okData.weather?[0].main
                            let weatherInfo = String(weatherType!)
                            
                            let theWeather = CityWeather(location: self.choosedCity, weatherInfo: weatherType, maxTemp: tempMaxInC, minTemp: tempMinInC, tempFeel: "")
                        
                            DispatchQueue.main.async {
                                self.settingInfo(cityWeather: theWeather)
                            }
                        }catch{
                            
                        }
                        
                    }
                    
                })
                task.resume()
            }
            
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    func settingInfo(cityWeather:CityWeather){
        locationName.text = cityWeather.location
        weatherInfo.text = cityWeather.weatherInfo
        maxTemp.text = cityWeather.maxTemp! + "度Ｃ"
        minTemp.text = cityWeather.minTemp! + "度Ｃ"
        tempFeel.text = cityWeather.tempFeel
    }
    
    
}

