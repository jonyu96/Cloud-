//
//  ViewController.swift
//  Cloud°
//
//  Created by Jonathan Yu on 7/4/18.
//  Copyright © 2018 Jonathan Yu. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    //Weather icon
    @IBOutlet var row1: [UIImageView]!
    @IBOutlet var row2: [UIImageView]!
    @IBOutlet var row3: [UIImageView]!
    @IBOutlet var row4: [UIImageView]!
    @IBOutlet var row5: [UIImageView]!
    @IBOutlet var row6: [UIImageView]!
    @IBOutlet var row7: [UIImageView]!
    @IBOutlet var row8: [UIImageView]!
    
    
    //Location name/icon
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var cityIcon: UIImageView!
    
    //Current weather IBOutlets
    @IBOutlet weak var currentTemp: UILabel!
    
    @IBOutlet weak var currentMinTemp: UILabel!
    @IBOutlet weak var currentMaxTemp: UILabel!
    
    @IBOutlet weak var currentHumidity: UILabel!
    @IBOutlet weak var currentWindSpeed: UILabel!
    
    
    //Five-day weather IBOutlets
    @IBOutlet var fiveDayWeatherIcon: [UIImageView]!
    @IBOutlet var fiveDayTemp: [UILabel]!
    
    //Current day label
    @IBOutlet weak var currentDay: UILabel!
    
    //Five-day label
    @IBOutlet var fiveDay: [UILabel]!
    
    //Constants
    let DARKSKY_URL = "https://api.darksky.net/forecast/"
    let DARKSKY_API_KEY = "c6d021fb0d9e997328b1fdfd94469cfb"
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideWeather()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeek = dateFormatter.string(from: date)
        
        currentDay.text = dayOfWeek
        
        
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showWeather()
    
    }*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                
                let city = placeMark.locality!
                let state = placeMark.administrativeArea!
                self.cityName.text = city
                if (UIImage(named: "\(city)") != nil) {
                    self.cityIcon.image = UIImage(named: "\(city)")
                } else if (UIImage(named: "\(state)") != nil) {
                    self.cityIcon.image = UIImage(named: "\(state)")
                } else {
                    self.cityIcon.image = UIImage(named: "City")
                }
                
            })
            
            getWeatherData(lat : latitude, lon : longitude)
        }
    }
    
    func getWeatherData(lat : String, lon : String) {
        
        let url = DARKSKY_URL + DARKSKY_API_KEY + "/" + lat + "," + lon + "?exclude=minutely,hourly,alerts"
        Alamofire.request(url).responseJSON
            {
                response in
                if response.result.isSuccess {
                    
                    let weatherJSON : JSON = JSON(response.result.value!)
                    //print(weatherJSON)
                    self.updateWeatherUI(weatherData: weatherJSON)
                }
                else {
                    print("Error \(String(describing: response.result.error))")
                }
        }
    }
    
    func updateWeatherUI(weatherData : JSON) {
        if let currentTempResult = weatherData["currently"]["apparentTemperature"].double {
            
            let weatherType = weatherData["currently"]["icon"].stringValue
            if weatherType == "clear-day" {
                loadClearDay()
            } else if weatherType == "partly-cloudy-day" {
                loadPartlyCloudyDay()
            } else if weatherType == "partly-cloudy-night" {
                loadPartlyCloudyNight()
            } else if weatherType == "rain" {
                loadRain()
            } else if weatherType == "snow" {
                loadSnow()
            } else if weatherType == "cloudy" {
                loadCloudy()
            } else if weatherType == "thunderstorm" {
                loadThunderstorm()
            } else if weatherType == "fog" {
                loadFog()
            }
            
            currentTemp.text = "\(Int(currentTempResult))°"
            currentMinTemp.text = "\(weatherData["daily"]["data"][0]["temperatureMin"].intValue)°"
            currentMaxTemp.text = "\(weatherData["daily"]["data"][0]["temperatureMax"].intValue)°"
            
            currentHumidity.text = "\(Int(weatherData["currently"]["humidity"].double! * 100.0))%"
            currentWindSpeed.text = "\(weatherData["currently"]["windSpeed"].intValue) m/s"
            
            for i in 0..<5 {
                
                let unixTimestamp = weatherData["daily"]["data"][i + 1]["time"].double!
                let date = Date(timeIntervalSince1970: unixTimestamp)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                var dayOfWeek = dateFormatter.string(from: date)
                
                if (dayOfWeek == "Sunday" || dayOfWeek == "Thursday" || dayOfWeek == "Saturday") {
                    dayOfWeek = String(dayOfWeek.prefix(2))
                } else {
                    dayOfWeek = String(dayOfWeek.prefix(1))
                }
                fiveDay[i].text = dayOfWeek
                
                let weatherIcon = weatherData["daily"]["data"][i + 1]["icon"].stringValue
                fiveDayWeatherIcon[i].image = UIImage(named: weatherIcon)
                
                let weatherTemp = weatherData["daily"]["data"][i + 1]["temperatureHigh"].intValue
                fiveDayTemp[i].text = "\(weatherTemp)°"
            }
            
        } else {
            cityName.text = "Weather Unavailable"
            currentTemp.text = "..."
            currentMinTemp.text = "..."
            currentMaxTemp.text = "..."
            currentHumidity.text = "..."
            currentWindSpeed.text = "..."
        }
    }
    
    func loadClearDay() {
        UIView.animate(withDuration: 0.15, animations: {
            for i in 0..<8 {
                if i == 2 || i == 3 || i == 4 || i == 5 {
                    self.row2[i].image = UIImage(named: "yellow2")
                    self.row2[i].alpha = 0.3
                }
            }
        }) { (true) in
            UIView.animate(withDuration: 0.15, animations: {
                for i in 0..<8 {
                    if i == 1 || i == 6 {
                        self.row3[i].image = UIImage(named: "yellow2")
                        self.row3[i].alpha = 0.4
                    } else if i == 2 || i == 3 || i == 4 || i == 5 {
                        self.row3[i].image = UIImage(named: "yellow2")
                        self.row3[i].alpha = 0.8
                    }
                }
            }, completion: { (true) in
                UIView.animate(withDuration: 0.15, animations: {
                    for i in 0..<8 {
                        if i == 1 || i == 6 {
                            self.row4[i].image = UIImage(named: "yellow2")
                            self.row4[i].alpha = 0.4
                        } else if i == 2 || i == 3 || i == 4 || i == 5 {
                            self.row4[i].image = UIImage(named: "yellow2")
                            self.row4[i].alpha = 0.8
                        }
                    }
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.15, animations: {
                        for i in 0..<8 {
                            if i == 1 || i == 6 {
                                self.row5[i].image = UIImage(named: "yellow2")
                                self.row5[i].alpha = 0.4
                            } else if i == 2 || i == 3 || i == 4 || i == 5 {
                                self.row5[i].image = UIImage(named: "yellow2")
                                self.row5[i].alpha = 0.8
                            }
                        }
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.15, animations: {
                            for i in 0..<8 {
                                if i == 1 || i == 6 {
                                    self.row6[i].image = UIImage(named: "yellow2")
                                    self.row6[i].alpha = 0.4
                                } else if i == 2 || i == 3 || i == 4 || i == 5 {
                                    self.row6[i].image = UIImage(named: "yellow2")
                                    self.row6[i].alpha = 0.8
                                }
                            }
                        }, completion: { (true) in
                            UIView.animate(withDuration: 0.15, animations: {
                                for i in 0..<8 {
                                    if i == 2 || i == 3 || i == 4 || i == 5 {
                                        self.row7[i].image = UIImage(named: "yellow2")
                                        self.row7[i].alpha = 0.3
                                    }
                                }
                            })
                        })
                    })
                })
            })
        }
    }
    
    func loadPartlyCloudyDay() {
        UIView.animate(withDuration: 0.15, animations: {
            for i in 1..<3 {
                self.row1[i].image = UIImage(named: "gray")
                self.row1[i].alpha = 0.7
            }
        }) { (true) in
            UIView.animate(withDuration: 0.15, animations: {
                for i in 0..<4 {
                    self.row2[i].image = UIImage(named: "gray")
                    self.row2[i].alpha = 0.7
                }
                for i in 4..<6 {
                    self.row2[i].image = UIImage(named: "yellow2")
                    self.row2[i].alpha = 0.8
                }
            }, completion: { (true) in
                UIView.animate(withDuration: 0.15, animations: {
                    for i in 1..<7 {
                        self.row3[i].image = UIImage(named: "yellow2")
                        self.row3[i].alpha = 0.8
                    }
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.15, animations: {
                        for i in 1..<7 {
                            self.row4[i].image = UIImage(named: "yellow2")
                            self.row4[i].alpha = 0.8
                        }
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.15, animations: {
                            for i in 1..<7 {
                                self.row5[i].image = UIImage(named: "yellow2")
                                self.row5[i].alpha = 0.8
                            }
                        }, completion: { (true) in
                            UIView.animate(withDuration: 0.15, animations: {
                                for i in 1..<4 {
                                    self.row6[i].image = UIImage(named: "yellow2")
                                    self.row6[i].alpha = 0.8
                                }
                                for i in 4..<7 {
                                    self.row6[i].image = UIImage(named: "gray")
                                    self.row6[i].alpha = 0.7
                                }
                            }, completion: { (true) in
                                UIView.animate(withDuration: 0.15, animations: {
                                    for i in 2..<8 {
                                        self.row7[i].image = UIImage(named: "gray")
                                        self.row7[i].alpha = 0.7
                                    }
                                }, completion: { (true) in
                                    UIView.animate(withDuration: 0.15, animations: {
                                        for i in 3..<7 {
                                            self.row8[i].image = UIImage(named: "gray")
                                            self.row8[i].alpha = 0.7
                                        }
                                    })
                                })
                            })
                        })
                    })
                })
            })
        }
    }
    
    func loadPartlyCloudyNight() {
        UIView.animate(withDuration: 0.15, animations: {
            for i in 4..<6 {
                self.row1[i].image = UIImage(named: "moon-color")
                self.row1[i].alpha = 1
            }
        }) { (true) in
            UIView.animate(withDuration: 0.15, animations: {
                for i in 1..<3 {
                    self.row2[i].image = UIImage(named: "gray")
                    self.row2[i].alpha = 0.7
                }
                for i in 3..<5 {
                    self.row2[i].image = UIImage(named: "moon-color")
                    self.row2[i].alpha = 1
                }
            }, completion: { (true) in
                UIView.animate(withDuration: 0.15, animations: {
                    for i in 0..<4 {
                        self.row3[i].image = UIImage(named: "gray")
                        self.row3[i].alpha = 0.7
                    }
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.15, animations: {
                        self.row4[1].image = UIImage(named: "gray")
                        self.row4[1].alpha = 0.7
                        for i in 2..<4 {
                            self.row4[i].image = UIImage(named: "moon-color")
                            self.row4[i].alpha = 1
                        }
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.15, animations: {
                            for i in 2..<4 {
                                self.row5[i].image = UIImage(named: "moon-color")
                                self.row5[i].alpha = 1
                            }
                            for i in 5..<7 {
                                self.row5[i].image = UIImage(named: "gray")
                                self.row5[i].alpha = 0.7
                            }
                        }, completion: { (true) in
                            UIView.animate(withDuration: 0.15, animations: {
                                self.row6[2].image = UIImage(named: "moon-color")
                                self.row6[2].alpha = 1
                                for i in 3..<8 {
                                    self.row6[i].image = UIImage(named: "gray")
                                    self.row6[i].alpha = 0.7
                                }
                            }, completion: { (true) in
                                UIView.animate(withDuration: 0.15, animations: {
                                    self.row7[3].image = UIImage(named: "moon-color")
                                    self.row7[3].alpha = 1
                                    for i in 4..<6 {
                                        self.row7[i].image = UIImage(named: "gray")
                                        self.row7[i].alpha = 0.7
                                    }
                                }, completion: { (true) in
                                    UIView.animate(withDuration: 0.15, animations: {
                                        for i in 4..<6 {
                                            self.row8[i].image = UIImage(named: "moon-color")
                                            self.row8[i].alpha = 1
                                        }
                                    })
                                })
                            })
                        })
                    })
                })
            })
        }
    }
    
    func loadRain() {
        UIView.animate(withDuration: 0.15, animations: {
            for i in 0..<8 {
                if i % 2 != 0 {
                    self.row2[i].image = UIImage(named: "rain-color2")
                    if i == 1 || i == 5 {
                        self.row2[i].alpha = 0.7
                    } else {
                        self.row2[i].alpha = 0.4
                    }
                }
            }
        }) { (true) in
            UIView.animate(withDuration: 0.15, animations: {
                for i in 0..<8 {
                    if i % 2 == 0 {
                        self.row3[i].image = UIImage(named: "rain-color2")
                        if i == 0 || i == 4 {
                            self.row3[i].alpha = 0.7
                        } else {
                            self.row3[i].alpha = 0.4
                        }
                    }
                }
            }, completion: { (true) in
                UIView.animate(withDuration: 0.15, animations: {
                    for i in 0..<8 {
                        if i % 2 != 0 {
                            self.row4[i].image = UIImage(named: "rain-color2")
                            if i == 1 || i == 5 {
                                self.row4[i].alpha = 0.4
                            } else {
                                self.row4[i].alpha = 0.7
                            }
                        }
                    }
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.15, animations: {
                        for i in 0..<8 {
                            if i % 2 == 0 {
                                self.row5[i].image = UIImage(named: "rain-color2")
                                if i == 0 || i == 4 {
                                    self.row5[i].alpha = 0.4
                                } else {
                                    self.row5[i].alpha = 0.7
                                }
                            }
                        }
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.15, animations: {
                            for i in 0..<8 {
                                if i % 2 != 0 {
                                    self.row6[i].image = UIImage(named: "rain-color2")
                                    if i == 1 || i == 5 {
                                        self.row6[i].alpha = 0.7
                                    } else {
                                        self.row6[i].alpha = 0.4
                                    }
                                }
                            }
                        }, completion: { (true) in
                            UIView.animate(withDuration: 0.15, animations: {
                                for i in 0..<8 {
                                    if i % 2 == 0 {
                                        self.row7[i].image = UIImage(named: "rain-color2")
                                        if i == 0 || i == 4 {
                                            self.row7[i].alpha = 0.7
                                        } else {
                                            self.row7[i].alpha = 0.4
                                        }
                                    }
                                }
                            })
                        })
                    })
                })
            })
        }
    }
    
    func loadSnow() {
        UIView.animate(withDuration: 0.15, animations: {
            for i in 0..<8 {
                if i % 2 != 0 {
                    self.row2[i].image = UIImage(named: "snow-color")
                    if i == 1 || i == 5 {
                        self.row2[i].alpha = 0.9
                    } else {
                        self.row2[i].alpha = 0.5
                    }
                }
            }
        }) { (true) in
            UIView.animate(withDuration: 0.15, animations: {
                for i in 0..<8 {
                    if i % 2 == 0 {
                        self.row3[i].image = UIImage(named: "snow-color")
                        if i == 0 || i == 4 {
                            self.row3[i].alpha = 0.9
                        } else {
                            self.row3[i].alpha = 0.5
                        }
                    }
                }
            }, completion: { (true) in
                UIView.animate(withDuration: 0.15, animations: {
                    for i in 0..<8 {
                        if i % 2 != 0 {
                            self.row4[i].image = UIImage(named: "snow-color")
                            if i == 1 || i == 5 {
                                self.row4[i].alpha = 0.5
                            } else {
                                self.row4[i].alpha = 0.9
                            }
                        }
                    }
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.15, animations: {
                        for i in 0..<8 {
                            if i % 2 == 0 {
                                self.row5[i].image = UIImage(named: "snow-color")
                                if i == 0 || i == 4 {
                                    self.row5[i].alpha = 0.5
                                } else {
                                    self.row5[i].alpha = 0.9
                                }
                            }
                        }
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.15, animations: {
                            for i in 0..<8 {
                                if i % 2 != 0 {
                                    self.row6[i].image = UIImage(named: "snow-color")
                                    if i == 1 || i == 5 {
                                        self.row6[i].alpha = 0.9
                                    } else {
                                        self.row6[i].alpha = 0.5
                                    }
                                }
                            }
                        }, completion: { (true) in
                            UIView.animate(withDuration: 0.15, animations: {
                                for i in 0..<8 {
                                    if i % 2 == 0 {
                                        self.row7[i].image = UIImage(named: "snow-color")
                                        if i == 0 || i == 4 {
                                            self.row7[i].alpha = 0.9
                                        } else {
                                            self.row7[i].alpha = 0.5
                                        }
                                    }
                                }
                            })
                        })
                    })
                })
            })
        }
    }
    
    func loadCloudy() {
        UIView.animate(withDuration: 0.15, animations: {
            for i in 0..<8 {
                if i % 2 != 0 {
                    self.row2[i].image = UIImage(named: "cloudy-color")
                    self.row2[i].alpha = 0.8
                }
            }
        }) { (true) in
            UIView.animate(withDuration: 0.15, animations: {
                for i in 0..<8 {
                    if i % 2 == 0 {
                        self.row3[i].image = UIImage(named: "cloudy-color")
                        if i == 0 {
                            self.row3[i].alpha = 0.8
                        } else {
                            self.row3[i].alpha = 0.3
                        }
                    }
                }
            }, completion: { (true) in
                UIView.animate(withDuration: 0.15, animations: {
                    for i in 0..<8 {
                        if i % 2 != 0 {
                            self.row4[i].image = UIImage(named: "cloudy-color")
                            if i == 7 {
                                self.row4[i].alpha = 0.8
                            } else {
                                self.row4[i].alpha = 0.3
                            }
                        }
                    }
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.15, animations: {
                        for i in 0..<8 {
                            if i % 2 == 0 {
                                self.row5[i].image = UIImage(named: "cloudy-color")
                                if i == 0 {
                                    self.row5[i].alpha = 0.8
                                } else {
                                    self.row5[i].alpha = 0.3
                                }
                            }
                        }
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.15, animations: {
                            for i in 0..<8 {
                                if i % 2 != 0 {
                                    self.row6[i].image = UIImage(named: "cloudy-color")
                                    if i == 7 {
                                        self.row6[i].alpha = 0.8
                                    } else {
                                        self.row6[i].alpha = 0.3
                                    }
                                }
                            }
                        }, completion: { (true) in
                            UIView.animate(withDuration: 0.15, animations: {
                                for i in 0..<8 {
                                    if i % 2 == 0 {
                                        self.row7[i].image = UIImage(named: "cloudy-color")
                                        self.row7[i].alpha = 0.8
                                    }
                                }
                            })
                        })
                    })
                })
            })
        }
    }
    
    func loadThunderstorm() {
        UIView.animate(withDuration: 0.15, animations: {
            for i in 2..<7 {
                self.row2[i].image = UIImage(named: "cloudy-color")
                if i % 2 == 0 {
                    self.row2[i].alpha = 0.7
                } else {
                    self.row2[i].alpha = 1
                }
            }
        }) { (true) in
            UIView.animate(withDuration: 0.15, animations: {
                for i in 1..<6 {
                    self.row3[i].image = UIImage(named: "cloudy-color")
                    if i % 2 != 0 {
                        self.row3[i].alpha = 0.7
                    } else {
                        self.row3[i].alpha = 1
                    }
                }
            }, completion: { (true) in
                UIView.animate(withDuration: 0.15, animations: {
                    for i in 2..<7 {
                        self.row4[i].image = UIImage(named: "cloudy-color")
                        if i % 2 == 0 {
                            self.row4[i].alpha = 0.7
                        } else {
                            self.row4[i].alpha = 1
                        }
                    }
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.15, animations: {
                        for i in 1..<6 {
                            if i % 2 != 0 {
                                self.row5[i].image = UIImage(named: "yellow2")
                                self.row5[i].alpha = 0.8
                            } else {
                                self.row5[i].image = UIImage(named: "cloudy-color")
                                self.row5[i].alpha = 1
                            }
                        }
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.15, animations: {
                            for i in 2..<7 {
                                if i % 2 == 0 {
                                    self.row6[i].image = UIImage(named: "yellow2")
                                    self.row6[i].alpha = 0.8
                                }
                            }
                        }, completion: { (true) in
                            UIView.animate(withDuration: 0.15, animations: {
                                for i in 1..<6 {
                                    if i % 2 != 0 {
                                        self.row7[i].image = UIImage(named: "yellow2")
                                        self.row7[i].alpha = 0.8
                                    }
                                }
                            })
                        })
                    })
                })
            })
        }
    }
    
    func loadFog() {
        UIView.animate(withDuration: 0.15, animations: {
            for i in 0..<7 {
                self.row2[i].image = UIImage(named: "snow-color")
                self.row2[i].alpha = 1
            }
        }) { (true) in
            UIView.animate(withDuration: 0.15, animations: {
                for i in 1..<8 {
                    self.row3[i].image = UIImage(named: "snow-color")
                    self.row3[i].alpha = 0.3
                }
            }, completion: { (true) in
                UIView.animate(withDuration: 0.15, animations: {
                    for i in 0..<7 {
                        self.row4[i].image = UIImage(named: "snow-color")
                        self.row4[i].alpha = 1
                    }
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.15, animations: {
                        for i in 1..<8 {
                            self.row5[i].image = UIImage(named: "snow-color")
                            self.row5[i].alpha = 0.3
                        }
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.15, animations: {
                            for i in 0..<7 {
                                self.row6[i].image = UIImage(named: "snow-color")
                                self.row6[i].alpha = 1
                            }
                        }, completion: { (true) in
                            UIView.animate(withDuration: 0.15, animations: {
                                for i in 1..<8 {
                                    self.row7[i].image = UIImage(named: "snow-color")
                                    self.row7[i].alpha = 0.3
                                }
                            })
                        })
                    })
                })
            })
        }
    }

    
    func hideWeather() {
        
        cityIcon.image = nil
        cityName.text = ""
        currentTemp.text = ""
        currentDay.text = ""
        currentMaxTemp.text = ""
        currentMinTemp.text = ""
        currentHumidity.text = ""
        currentWindSpeed.text = ""
        
        for i in 0..<5 {
            fiveDay[i].text = ""
            fiveDayWeatherIcon[i].image = nil
            fiveDayTemp[i].text = ""
        }
        
        for i in 0..<8 {

            self.row1[i].roundedImage()
            self.row1[i].alpha = 0
            
            self.row2[i].roundedImage()
            self.row2[i].alpha = 0
            
            self.row3[i].roundedImage()
            self.row3[i].alpha = 0
            
            self.row4[i].roundedImage()
            self.row4[i].alpha = 0
            
            self.row5[i].roundedImage()
            self.row5[i].alpha = 0
            
            self.row6[i].roundedImage()
            self.row6[i].alpha = 0
            
            self.row7[i].roundedImage()
            self.row7[i].alpha = 0
            
            self.row8[i].roundedImage()
            self.row8[i].alpha = 0
            
        }
    }
    
    func showWeather() {
        for i in 0..<8 {
            
            self.row1[i].alpha = 1
            
            self.row2[i].alpha = 1
            
            self.row3[i].alpha = 1
            
            self.row4[i].alpha = 1
            
            self.row5[i].alpha = 1
            
            self.row6[i].alpha = 1
            
            self.row7[i].alpha = 1
            
            self.row8[i].alpha = 1
            
        }
    }
}

