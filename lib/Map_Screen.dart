import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:http/http.dart' as http;
import 'package:map_project/Add_Location_Screen.dart';
import 'dart:convert';

import 'Search_Screen.dart';

class MapScreen extends StatefulWidget {
  final double lat;
  final double lng;
  final String description;
  final String locationName;

  const MapScreen({
    super.key,
    required this.lat,
    required this.lng,
    required this.description,
    required this.locationName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final Location location = Location();
  Set<Marker> markers = {};
  late String locationName;
  late String markerDescription;

  @override
  void initState() {
    super.initState();

    locationName = widget.locationName;
    markerDescription = widget.description;

    markers.add(
      Marker(
        markerId: const MarkerId('selectedPlace'),
        position: LatLng(widget.lat, widget.lng),
        infoWindow: InfoWindow(title: markerDescription),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    await _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool permissionGranted = await requestLocationPermission();
    if (!permissionGranted) {
      await _showPermissionDeniedDialog(
        'Permission Denied',
        'Location permission was denied. Please allow location access to use this feature.',
      );
      return;
    }

    try {
      final userLocation = await location.getLocation();

      final userLatLng = LatLng(
        userLocation.latitude!,
        userLocation.longitude!,
      );

      setState(() {
        markers.clear();
        markers.add(
          Marker(
            markerId: const MarkerId('userLocation'),
            position: userLatLng,
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
      });

      await mapController?.animateCamera(CameraUpdate.newLatLng(userLatLng));
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showPermissionDeniedDialog(
        'Location Services Disabled',
        'Please enable location services on your device.',
      );
      return false;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _showPermissionDeniedDialog(
        'Permission Denied Forever',
        'Location permission is permanently denied. Please enable it from app settings.',
      );
      return false;
    }

    return true;
  }

  Future<void> _showPermissionDeniedDialog(String title, String message) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _onMapTap(LatLng position) async {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('selectedPlace'),
          position: position,
          infoWindow: InfoWindow(title: markerDescription),
        ),
      );
    });

    await mapController?.animateCamera(CameraUpdate.newLatLng(position));

    try {
      final geocodeUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$kPLACES_API_KEY';

      final response = await http.get(Uri.parse(geocodeUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'];
          if (results != null && results.length > 0) {
            final formattedAddress = results[0]['formatted_address'];

            setState(() {
              locationName = formattedAddress;
              markerDescription = formattedAddress;

              markers.clear();
              markers.add(
                Marker(
                  markerId: const MarkerId('selectedPlace'),
                  position: position,
                  infoWindow: InfoWindow(title: markerDescription),
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps in Flutter')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.lat, widget.lng),
              zoom: 12,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: _onMapTap,
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  listOfLocations.add({
                    "$myCustomLocationName": "$locationName",
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddLocationScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      locationName,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
