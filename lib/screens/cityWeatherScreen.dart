import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class cityWeatherScreen extends StatefulWidget {
  const cityWeatherScreen({super.key});

  @override
  State<cityWeatherScreen> createState() => _cityWeatherScreenState();
}

class _cityWeatherScreenState extends State<cityWeatherScreen> {
  String address = "Unknown Address";
  String desc = "";
  String icon = "http://openweathermap.org/img/wn/01d@4x.png";
  String temp = "";
  int humidity = 0;
  TextEditingController cityController = TextEditingController();
  Position? currentPosition;

  Future<bool> checkServicePermission() async {
    LocationPermission locationPermission;
    //check service
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
          content: const Text(
              'Location Services is disabled. Please enable it in the settings'),
        ),
      );
      return false;
    }
    //check permission
    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      //request
      locationPermission = await Geolocator.requestPermission();

      if (locationPermission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
            content: const Text(
                'Location Permission is denied. You cannot use the app without allowing location permission'),
          ),
        );
        return false;
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
          content: const Text(
              'Location Permission is forever denied. You cannot use the app without allowing location permission'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> getWeather() async {
    //get gps location if the service and permission is ok
    if (!await checkServicePermission()) {
      return;
    }

    String apiKey = 'd9606132814cd7bf13483c0ef40ca7e2';
    var url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=${cityController.text}&appid=$apiKey');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      List<dynamic> weatherData = decodedResponse['weather'];
      Map<String, dynamic> mainData = decodedResponse['main'];

      if (weatherData.isNotEmpty) {
        Map<String, dynamic> weatherInfo = weatherData[0];
        String descriptionData = weatherInfo['description'];
        String iconData = weatherInfo['icon'];
        print('description: $descriptionData');
        print('icon: $iconData');
        setState(() {
          String capitalizedText = descriptionData.split(' ').map((word) {
            if (word.isEmpty) return '';
            return word[0].toUpperCase() + word.substring(1);
          }).join(' ');

          desc = capitalizedText;
          icon = "http://openweathermap.org/img/wn/$iconData@4x.png";
          print(icon);
        });
      }

      if (mainData.isNotEmpty) {
        double tempData = mainData['temp'];
        int humidityData = mainData['humidity'];

        double convertedTemp = tempData - 273.15;
        String formattedTemp = convertedTemp.toStringAsFixed(2);

        print('temp: $tempData');
        print('humidity: $humidityData');

        setState(() {
          temp = formattedTemp;
          humidity = humidityData;
        });
      }
    } else {
      var error = response.statusCode;
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Check City Weather'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(label: Text('City Name')),
                ),
                const SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                    onPressed: getWeather,
                    child: const Text('Get Current Location')),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width * 1,
                  child: Card(
                    elevation: 10,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Weather Forecast',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CircleAvatar(
                          maxRadius: 50,
                          child: Image.network(
                            icon,
                            height: 150,
                            width: 150,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          desc,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Temperature (Celcius):',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w900),
                            ),
                            Text(temp, style: const TextStyle(fontSize: 20)),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text('Humidity (Percent):',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w900)),
                            Text(humidity.toString(),
                                style: const TextStyle(fontSize: 20)),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
