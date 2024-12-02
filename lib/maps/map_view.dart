import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'create_pin.dart';
import 'search_map.dart';
import 'post_detail_page.dart';  

class MapView extends StatefulWidget {
  const MapView({
    super.key,
    required this.thunderforestApiKey,
  });

  final String thunderforestApiKey;

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  double _latitude = 43.887501;  // Default latitude (Richmond Hill)
  double _longitude = -79.428406; // Default longitude (Richmond Hill)

  Future<List<Marker>> _getPins() async {
    List<Marker> pins = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('pins').get();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        double latitude = double.tryParse(data['latitude']?.toString() ?? '') ?? 0.0;
        double longitude = double.tryParse(data['longitude']?.toString() ?? '') ?? 0.0;

        String username = data['username'] ?? 'Unknown';
        String description = data['description'] ?? 'No description';

        if (latitude == 0.0 && longitude == 0.0) { 
          continue; // Skip invalid coordinates
        }

        pins.add(
          Marker(
            point: LatLng(latitude, longitude),
            width: 70,
            height: 70, 
            child: GestureDetector(
              onTap: () {
                // Navigate to PostDetailPage when the marker is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailPage(postId: doc.id), 
                  ),
                );
              },
              child: const Icon(Icons.location_pin, color: Colors.purple),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error fetching markers: $e');
    }
    return pins; // Return the list of pins
  }

  // Function to update map center based on the city-country search result
  void _updateMap(double latitude, double longitude) {
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
    });
  }

  @override
  void initState() {
    super.initState();
    _getPins(); // Load pins when the widget is first created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Search a City"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SearchMap(onLocationFound: _updateMap); // Use the SearchMap widget
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPinCreated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePin()),
          );
          if (newPinCreated == true) {
            setState(() {
              _getPins(); // Reload the pins when a new pin is created
            });
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add new pin',
      ),
      body: FutureBuilder<List<Marker>>(
        future: _getPins(), // Fetch pins asynchronously
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Error
          } else {
            return FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(_latitude, _longitude), // Update map center based on search
                initialZoom: 10, // Adjust zoom level
                maxZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.thunderforest.com/{style}/{z}/{x}/{y}{r}.png?apikey={apiKey}',
                  subdomains: const ['a', 'b', 'c'],
                  additionalOptions: {
                    'style': 'atlas',
                    'apiKey': widget.thunderforestApiKey,
                  },
                  maxZoom: 22,
                  userAgentPackageName: 'com.example.app',
                  retinaMode: true,
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(50),
                    maxZoom: 22,
                    markers: snapshot.data!, // Use the resolved markers
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blue,
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const RichAttributionWidget(
                  showFlutterMapAttribution: false,
                  animationConfig: FadeRAWA(),
                  attributions: [
                    TextSourceAttribution(
                      'Maps: © Thunderforest \n  Data: © OpenStreetMap contributors',
                      textStyle: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
