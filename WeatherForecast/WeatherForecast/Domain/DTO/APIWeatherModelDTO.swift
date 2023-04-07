//
//  APIWeatherModelDTO.swift
//  WeatherForecast
//
//  Created by Jason on 2023/04/05.
//

import Foundation
import CoreLocation
import Dispatch

class APIWeatherModelDTO {

    weak var delegate: WeatherModelDelegate?
    //MARK: - Private Property

    private let repository = Repository()
    
    //MARK: - Method
    
    func receiveCurrentLocation() -> CLLocationCoordinate2D {
        guard let location = UserLocation.shared.location?.coordinate else {
            //TODO: - Error 처리
            return CLLocationCoordinate2D()
        }
        return location
    }
    
    func determineDTO(with location: CLLocationCoordinate2D) {
        
        URLPath.allCases.forEach { path in
            switch path {
            case .currentWeather:
                repository.loadData(with: location,
                                    path: path) { weatherModel, error in
                    DispatchQueue.main.async {
                        if let currentWeatherModel = weatherModel as? CurrentWeather {
                            let result = self.makeCurrentWeatherDTO(with: currentWeatherModel)
                            self.delegate?.loadCurrentWeather(of: result)
                        }
                    }
                }
            case .forecastWeather:
                repository.loadData(with: location,
                                    path: path) { weatherModel, error in
                    DispatchQueue.main.async {
                        if let forecastWeatherModel = weatherModel as? ForecastWeather {
                            self.delegate?.loadForecastWeather(of: self.makeForecastWeatherDTO(with: forecastWeatherModel))
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Private Method
    
    private func makeCurrentWeatherDTO(with data: CurrentWeather) -> CurrentViewModel {
        var iconName: String = ""
        let minTemperature = data.main.temperatureMin
        let maxTemperature = data.main.temperatureMax
        let temperature = data.main.temperature
        
        data.weathers.forEach { element in
            iconName = element.icon
        }
        
        return CurrentViewModel(currentWeatherIcon: iconName,
                                      temperature: Temperature(lowestTemperature: String(minTemperature), highestTemperature: String(maxTemperature), currentTemperature: String(temperature)))
    }
    
    private func makeForecastWeatherDTO(with data: ForecastWeather) -> ForecastViewModel {
        var forecastDate: String = ""
        var forecastIcon: String = ""
        var forecastTemperature: Double = 0
        
        data.list.forEach { element in
            forecastDate = element.date
            forecastTemperature = element.main.temperature
            
            element.weather.forEach { element in
                forecastIcon = element.icon
            }
        }
        
        return ForecastViewModel(forecastEmogi: forecastIcon,
                                 forecastInformation: ForecastInformation(forecastDate: forecastDate, forecastDegree: String(forecastTemperature)))
    }
}

protocol WeatherModelDelegate: NSObject {
    func loadCurrentWeather(of: CurrentViewModel)
    func loadForecastWeather(of: ForecastViewModel)
}
