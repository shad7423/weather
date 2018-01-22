//
//  ViewController.swift
//  WeatherApp
//
//  Created by Shadab Khan on 11/30/17.
//  Copyright © 2017 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController , CLLocationManagerDelegate, changeCityDelegate{
    
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    //let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let APP_ID = "8afce4f0ee19f4ce69db8c512f775b32"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url : String , parameters : [String:String]){
        Alamofire.request(url, method : .get, parameters : parameters).responseJSON {
            response in
            if response.result.isSuccess{
               print("Success! Got the Weather Data")
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherDataa(json: weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherDataa(json : JSON){
        
        if let tempresult = json["main"]["temp"].double {
        weatherDataModel.temperature = Int(tempresult - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition =  json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherdata()
        }
        else{
            self.cityLabel.text = "Weather Unavailable"
        }
        
    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherdata(){
        
        self.cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named : weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            print("longitude = \(location.coordinate.longitude),lattitude = \(location.coordinate.latitude)")
            
            let lattitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String:String] = ["lat" : lattitude, "lon" : longitude, "appId" : APP_ID]
            getWeatherData(url : WEATHER_URL , parameters : params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Location UnAvailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        print(city)
        let params : [String:String] = ["q" : city, "appId" : APP_ID]
        getWeatherData(url : WEATHER_URL , parameters : params)
    }
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
            
            
        }
    }
    
    
}


