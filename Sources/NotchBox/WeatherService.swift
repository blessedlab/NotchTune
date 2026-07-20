import Foundation
import CoreLocation

struct WeatherData {
    let temperature: Int
    let condition: String
    let icon: String
}

class WeatherService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var completion: ((WeatherData?) -> Void)?

    func fetchWeather(completion: @escaping (WeatherData?) -> Void) {
        self.completion = completion
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,weather_code&temperature_unit=celsius"

        guard let url = URL(string: urlString) else {
            completion?(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { self.completion?(nil) }
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let current = json?["current"] as? [String: Any]
                let temp = current?["temperature_2m"] as? Double ?? 0
                let code = current?["weather_code"] as? Int ?? 0

                let weather = WeatherData(
                    temperature: Int(temp),
                    condition: WeatherService.conditionName(code),
                    icon: WeatherService.conditionIcon(code)
                )

                DispatchQueue.main.async { self.completion?(weather) }
            } catch {
                DispatchQueue.main.async { self.completion?(nil) }
            }
        }.resume()
    }

    static func conditionIcon(_ code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill"
        case 1...3: return "cloud.sun.fill"
        case 45...48: return "cloud.fog.fill"
        case 51...57: return "cloud.drizzle.fill"
        case 61...67: return "cloud.rain.fill"
        case 71...77: return "cloud.snow.fill"
        case 80...82: return "cloud.heavyrain.fill"
        case 85...86: return "cloud.snow.fill"
        case 95...99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }

    static func conditionName(_ code: Int) -> String {
        switch code {
        case 0: return "Clear"
        case 1...3: return "Cloudy"
        case 45...48: return "Fog"
        case 51...57: return "Drizzle"
        case 61...67: return "Rain"
        case 71...77: return "Snow"
        case 80...82: return "Rain"
        case 85...86: return "Snow"
        case 95...99: return "Thunder"
        default: return "Unknown"
        }
    }
}
