import 'package:flutter/material.dart';
import 'package:map_project/Map_Screen.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

String kPLACES_API_KEY = "AIzaSyC3TOoFBvO5AnmUXUIOgTbRv126U9tdJFM";

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final Uuid uuid = Uuid();

  String? _sessionToken;
  List<dynamic> _placeList = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  Future<void> getSuggestion(String input) async {
    String kPLACES_API_KEY =
        "AIzaSyC3TOoFBvO5AnmUXUIOgTbRv126U9tdJFM";
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';

    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      setState(() {
        _placeList = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Location Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search location",
                prefixIcon: Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _placeList.clear();
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _placeList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.place),
                    title: Text(_placeList[index]["description"]),
                    onTap: () async {
                      String placeId = _placeList[index]["place_id"];
                      String detailsUrl =
                          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kPLACES_API_KEY';

                      final detailResponse = await http.get(
                        Uri.parse(detailsUrl),
                      );

                      if (detailResponse.statusCode == 200) {
                        final result =
                            json.decode(detailResponse.body)['result'];
                        final location = result['geometry']['location'];
                        final lat = location['lat'];
                        final lng = location['lng'];
                        print("Resultttt :$result");

                        print('Lat: $lat, Lng: $lng');

                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text('Lat: $lat, Lng: $lng')),
                        // );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MapScreen(
                                  lat: lat,
                                  lng: lng,
                                  description: result['name'],
                                  locationName:
                                      _placeList[index]["description"],
                                ),
                          ),
                        );
                      } else {
                        throw Exception('Failed to load place details');
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
