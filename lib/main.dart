import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:http/http.dart' as http;
import 'package:map_project/Add_Location_Screen.dart';
import 'dart:convert';

import 'Search_Screen.dart';

const String kPLACES_API_KEY = 'AIzaSyC3TOoFBvO5AnmUXUIOgTbRv126U9tdJFM';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AddLocationScreen());
  }
}
