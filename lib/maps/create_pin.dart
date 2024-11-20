import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart'; 

class CreatePin extends StatefulWidget {
  const CreatePin({Key? key}) : super(key: key);

  @override
  _CreatePinState createState() => _CreatePinState();
}

class _CreatePinState extends State<CreatePin> {
  String username = "";
  String userId = "";
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _coordinatesResult = "";


  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async { // will use this info as part of making the pins
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? ''; 
          userId = uid;
        });
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  void _getCoordinatesFromAddress() async {
    try {
      String address = _addressController.text;
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          _longitudeController.text = location.longitude.toString();
          _latitudeController.text = location.latitude.toString();
          _coordinatesResult = "Found coordinates";

        });
      } else {
        setState(() {
          _coordinatesResult = "Did not find cordinates";
        });
      }
    } catch (error) {
      setState(() {
        _coordinatesResult = "Error: ${error.toString()}";
      });
    }
  }

  void _getLocation() async{
    bool locationService;
    LocationPermission permission;

    locationService = await Geolocator.isLocationServiceEnabled(); // checking if location services are enabled
    if(locationService == false){
      setState(() {
        _coordinatesResult = "Location services are disabled";
      });
      return;
    }

    // checking for permissions for our app
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _coordinatesResult = "Location permissions are denied.";
        });
        return;
      }
    }

    // Very sad moment, graduation by JUICE WRLD starts playing 
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _coordinatesResult =
            "Location permissions are permanently denied.";
      });
      return;
    }

    // Very happy moment, International Love by Pitbull and Diamonds by Rihanna start playing (what am I doing with my life, someone please dont let these comments end up in the final submission thx)
    Position myPositon = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitudeController.text = myPositon.latitude.toString();
      _longitudeController.text = myPositon.longitude.toString();
      _coordinatesResult = "Current location found!";
    });
  }

  Future<void> _createPin() async {
    await FirebaseFirestore.instance.collection('pins').doc().set({
        'latitude': _latitudeController.text.trim(),
        'longitude': _longitudeController.text.trim(),
        'userID': FirebaseFirestore.instance.collection('users').doc(userId), // check as this make take a little more since we want to create this as a reference in Firebase
        'username': username, // for simplicity
        'description': _descriptionController.text.trim(),
        'timestamp': Timestamp.now()
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a New Pin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: $username',
              style: const TextStyle(fontSize: 18),
            ),
            
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(labelText: 'Enter Address'),

            ), ElevatedButton(
              onPressed: _getCoordinatesFromAddress,
              child: const Text('Convert Address to Coordinates'),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,

            ),
            TextField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _getLocation,
              child: const Text('Use Current Location'),
            ),
            Text(_coordinatesResult, style: const TextStyle(color: Colors.purple)),
            const SizedBox(height: 20),



            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Enter a description'),
              keyboardType: TextInputType.text,
            ),

            TextField(
              decoration: const InputDecoration(labelText: 'Add pin'),

            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed : () async {
                try {
                // Step 1: push to firebase
                  await _createPin();

                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pin saved successfully!')) // Will need to improve UI here
                );

                // Step 2: reload all pins from firebase on the maps_view page

                

                } catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Failed to save pin: $e'))
                  );

                }
              
                
              },
              child: const Text('Save Pin'),
            ),
          ],
        ),
      ),
    );
  }
}
