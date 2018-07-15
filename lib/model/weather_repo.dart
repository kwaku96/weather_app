import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:geolocation/geolocation.dart';

import 'package:flutter_app_weather_tutorial/json/response.dart';

import 'package:flutter_app_weather_tutorial/model/model.dart';
import 'package:flutter_app_weather_tutorial/const.dart';

class WeatherRepo {
  final http.Client client;

  WeatherRepo({this.client});

  int cnt = 50;
  String lang = "en";

  void addCities(int count) {
    cnt = count;
  }

  void setLanguage(String code) {
    lang = code;
  }

  Future<List<WeatherModel>> updateWeather(LocationResult result) async {
    String url;
    if (result != null) {
      url =
          'http://api.openweathermap.org/data/2.5/find?lat=${result.location.latitude}&lon=${result.location.longitude}&cnt=$cnt&appid=$API_KEY&lang=$lang';
    } else {
      url =
          'http://api.openweathermap.org/data/2.5/find?lat=43&lon=-79&cnt=10&appid=$API_KEY';
    }
    final response = await client.get(url);

    List<WeatherModel> req = BaseResponse
        .fromJson(json.decode(response.body) as Map<String, dynamic>)
        .cities
        .map((city) => WeatherModel.fromResponse(city))
        .toList();

    return req;
  }

  // Future<LocationResult> updateLocation() async {
  //   Future<LocationResult> result = Geolocation.lastKnownLocation();
  //   return result;
  // }

  //uses Stream instead of future.  Mainly done because lastKnownLocation isn't as reliable as locationUpdates.
  //when geolocation plugin is fixed or better plugin is released, will update code.

  Stream<LocationResult> updateLocationStream(dynamic item) {
    Stream<LocationResult> stream = Geolocation.currentLocation(
        accuracy: LocationAccuracy.best, inBackground: false);
    return stream;
  }

  Future<bool> getGps() async {
    final GeolocationResult result = await Geolocation.isLocationOperational();
    if (result.isSuccessful)
      return true;
    else
      return false;
  }
}
