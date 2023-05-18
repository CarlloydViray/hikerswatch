import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hikerswatch_viraycarlloyd/screens/cityWeatherScreen.dart';
import 'package:http/http.dart' as http;

class homePageScreen extends StatefulWidget {
  const homePageScreen({super.key});

  @override
  State<homePageScreen> createState() => _homePageScreenState();
}

class _homePageScreenState extends State<homePageScreen> {
  TextEditingController fullAddy = TextEditingController();
  final StreamController<Position?> _positionStreamController =
      StreamController<Position?>();

  String address = "Unknown Address";
  String desc = "";
  String icon = "http://openweathermap.org/img/wn/01d@4x.png";
  String temp = "";
  int humidity = 0;

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

  Future<void> getCurrentLocation() async {
    if (!await checkServicePermission()) {
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position? position) async {
      _positionStreamController.add(position);
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
      if (position != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          String newAddress =
              "${placemark.subThoroughfare} ${placemark.thoroughfare}, "
              "${placemark.locality}, ${placemark.administrativeArea} "
              "${placemark.postalCode}, ${placemark.country}";

          String placemarker = placemark.toString();
          print('Address: $newAddress');

          setState(() {
            fullAddy.text = newAddress;
          });
        }

        String apiKey = 'd9606132814cd7bf13483c0ef40ca7e2';
        var url = Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude.toString()}&lon=${position.longitude.toString()}&appid=$apiKey');
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
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Position?>(
      stream: _positionStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          currentPosition = snapshot.data!;
        }
        return SafeArea(
            child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'My Location',
                  style: TextStyle(fontSize: 20),
                ),
                Text(currentPosition == null
                    ? 'Unknown Latitude'
                    : 'Latitude: ${currentPosition!.latitude}'),
                Text(currentPosition == null
                    ? 'Unknown Longitude'
                    : 'Longitude: ${currentPosition!.longitude}'),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                  decoration:
                      const InputDecoration(label: Text('Full Address')),
                  controller: fullAddy,
                  maxLines: 2,
                  readOnly: true,
                ),
                const SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => const cityWeatherScreen()));
                    },
                    child: const Text('Search City Weather')),
                const SizedBox(
                  height: 12,
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
        ));
      },
    );
  }
}
