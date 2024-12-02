import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; 

class SearchMap extends StatefulWidget {
  final Function(double latitude, double longitude) onLocationFound;

  const SearchMap({Key? key, required this.onLocationFound}) : super(key: key);

  @override
  _SearchMapState createState() => _SearchMapState();
}

class _SearchMapState extends State<SearchMap> {
  String city = '';
  String country = '';

  Future<void> _searchLocation() async {
    
    if (city.isNotEmpty && country.isNotEmpty) {
      try {
        
        List<Location> locations = await locationFromAddress('$city, $country');
        if (locations.isNotEmpty) {
          widget.onLocationFound(locations.first.latitude, locations.first.longitude);
          Navigator.pop(context); 
        }
      } catch (e) {
        print("Error fetching coordinates: $e");
        Navigator.pop(context); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter City and Country"),
      content: Container(
        width: 250, // Set a smaller width for the dialog box
        height: 150, // Set a smaller height for the dialog box
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevent the dialog from expanding
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "City"),
              onChanged: (value) => city = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Country"),
              onChanged: (value) => country = value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: _searchLocation,
          child: const Text("Search"),
        ),
      ],
    );
  }
}
