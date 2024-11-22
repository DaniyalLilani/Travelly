import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'create_pin.dart';



class MapView extends StatelessWidget {
  const MapView({
    super.key,
    required this.thunderforestApiKey,
  });

  final String thunderforestApiKey;

  Future<List<Marker>> _getPins(BuildContext context) async {
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
            print('Invalid or missing coordinates for document ${doc.id}');
            continue; // Skip this document
        }


        print("latitude: $latitude longitude: $longitude");

        pins.add(
          Marker(
            point: LatLng(latitude, longitude),
            width: 70,
            height: 70, 
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(username),
                    content: Text(description),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(Icons.location_pin, color: Colors.red),
            ),
          ),
        );
        print(pins);
      }
    } catch (e) {
      print('Error fetching markers: $e');
    }
    return pins;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         final newPinCreated= await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePin()),
          );
          if (newPinCreated == true) {
            // reload with new pins.
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  MapView(thunderforestApiKey: thunderforestApiKey)));
        }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add new pin',
      ),
      body: FutureBuilder<List<Marker>>(
        future: _getPins(context), // Fetch pins asynchronously
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Error
          } else {
            return FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(43.887501, -79.428406), // Richmond Hill
                initialZoom: 4,
                maxZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.thunderforest.com/{style}/{z}/{x}/{y}{r}.png?apikey={apiKey}',
                  subdomains: const ['a', 'b', 'c'],
                  additionalOptions: {
                    'style': 'atlas',
                    'apiKey': thunderforestApiKey,
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