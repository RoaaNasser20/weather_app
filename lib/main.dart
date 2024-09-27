import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _cityController = TextEditingController();
  
  String _apiKey = '186b7da5f7cf43d0af5213224242409'; // Replace with your WeatherAPI key

  var _weatherData;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> fetchWeather(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; 
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://api.weatherapi.com/v1/current.json?key=$_apiKey&q=$city&aqi=no'
        )
      );

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _weatherData = null;
          _isLoading = false;
          _errorMessage = 'City not found!';
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _weatherData = null;
          _isLoading = false;
          _errorMessage = 'Invalid API key! Please check your key.';
        });
      } else {
        setState(() {
          _weatherData = null;
          _isLoading = false;
          _errorMessage = 'Something went wrong! Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to connect. Check your network connection.';
      });
    }
  }

  void _searchCity() {
    if (_cityController.text.isNotEmpty) {
      fetchWeather(_cityController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Enter city name',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _searchCity,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : _errorMessage != null
                      ? Text(
                          _errorMessage!,
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        )
                      : _weatherData != null
                          ? WeatherDetails(weatherData: _weatherData)
                          : Text(
                              'Enter a city to get weather data',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherDetails extends StatelessWidget {
  final Map weatherData;

  WeatherDetails({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    var weatherDescription = weatherData['current']['condition']['text'];
    var temperature = weatherData['current']['temp_c'].toString();
    var humidity = weatherData['current']['humidity'].toString();
    var windSpeed = weatherData['current']['wind_kph'].toString();
    var cityName = weatherData['location']['name'];
    var country = weatherData['location']['country'];

    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 500),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$cityName, $country',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.thermostat, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    'Temperature: $temperature°C',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.water, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    'Humidity: $humidity%',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.air, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    'Wind Speed: $windSpeed kph',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Weather: $weatherDescription',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
