//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {

    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "df49c975040c3806332c1f11744bb46a"

    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self //specifying authority for use of location
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters  //openweatherapi works best in this case
        locationManager.requestWhenInUseAuthorization()     //use it wisely otherwise user will think you are spying :P
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/

    
//    Alamofire.request("https://httpbin.org/get").responseJSON { response in
//    print("Request: \(String(describing: response.request))")   // original url request
//    print("Response: \(String(describing: response.response))") // http url response
//    print("Result: \(response.result)")                         // response serialization result
//
//    if let json = response.result.value {
//    print("JSON: \(json)") // serialized json response
//    }
//
//    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//    print("Data: \(utf8Text)") // original server data as UTF8 string
//    }
//    }
    
    func getWeatherData(url: String, params: [String:String]) {
        
        Alamofire.request(url, method: .get, parameters: params).responseJSON {
            response in //a closure - a function within another function
            if response.result.isSuccess {
                
                print("Successfully connected to server")
                
                let weatherJSON : JSON = JSON(response.result.value!)

                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error fetching data: \(response.result.error)")
                self.cityLabel.text = "Error"
            }
            
        }
        
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    func updateWeatherData(json: JSON){
        
        //use optional binding here:
        if let data = json["main"]["temp"].double {  //if let command binds the optional data to this block
            weatherDataModel.temperature = Int(data - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIcon = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            //update UI after getting all the values
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "Uh oh! Try again!"
        }
    }
    
    //MARK: - UI Updates
    /***************************************************************/

    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)+"°"
        weatherIcon.image = UIImage.init(named: weatherDataModel.weatherIcon)
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mostPreciseLocation = locations[locations.count - 1]
        if mostPreciseLocation.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("Latitude: \(mostPreciseLocation.coordinate.latitude) \n Longtitude: \(mostPreciseLocation.coordinate.longitude)")
            let lat = String(mostPreciseLocation.coordinate.latitude)
            let long = String(mostPreciseLocation.coordinate.longitude)
            let parameters : [String:String] = ["lat" : lat, "lon": long, "appid":APP_ID]
            
            getWeatherData(url: WEATHER_URL, params: parameters)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Error"
    }

    //MARK: - Change City Delegate methods
    /***************************************************************/
    

    func userEnteredANewCityName(city: String) {
        let parameters : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, params: parameters)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCity" {
            let destVC = segue.destination as! ChangeCityViewController
            destVC.delegate = self
            
        }
    }
    
    
    
    
}


