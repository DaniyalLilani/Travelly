// https://www.thunderforest.com/tutorials/flutter/

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';


class MapView extends StatelessWidget {
  const MapView({
    super.key,
    required this.thunderforestApiKey,
  });

  final String thunderforestApiKey;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(43.887501, -79.428406), // Richmond Hill (hehe)
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
            maxZoom: 15,
            markers: [
              Marker(
                point: const LatLng(51.509364, -0.128928), // London
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin, color: Colors.red),
              ),
              Marker(
                point: const LatLng(48.8566, 2.3522), // Paris
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin, color: Colors.red),
              ),
              Marker(
                point: const LatLng(41.9028, 12.4964), // Rome
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin, color: Colors.red),
              ),
            ],
            builder: (context, markers) {
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue),
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
          // According to Terms and Conditions, Attribution must be given 
          //to both “Thunderforest” and “OpenStreetMap contributors”.
          // https://www.thunderforest.com/terms/
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
}
