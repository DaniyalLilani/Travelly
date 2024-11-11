import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Map<String, dynamic>> pins = [
    {
      "title": "Tokyo Skytree",
      "rating": 4,
      "location": "Tokyo, Japan",
      "image": "https://www.datocms-assets.com/101439/1697302363-tokyo-skytree.webp?auto=format&fit=max&w=1200",
      "comments": [
        {
          "username": "Dani",
          "handle": "@Dani123",
          "comment": "Amazing view!",
          "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Tokyo_Skytree_2023.jpg/1200px-Tokyo_Skytree_2023.jpg"
        },
        {"username": "Rija", "handle": "@rija456", "comment": "A must visit!"}
      ]
    },
    {
      "title": "Great Local Restaurant",
      "rating": 5,
      "location": "Shibuya, Tokyo",
      "image": "",
      "comments": [
        {"username": "Huz", "handle": "@Huz789", "comment": "Delicious food!"},
        {
          "username": "Sahil",
          "handle": "@Sahil101",
          "comment": "Affordable and tasty.",
          "image": "https://www.foodiesfeed.com/wp-content/uploads/2023/06/burger-with-melted-cheese.jpg"
        }
      ]
    },
  ];

  File? _pickedImage; // Holds the picked image for comment
  String _searchQuery = ''; // Search query for searching comments and pins

  // Function to show the comment popup
  void showCommentDialog(int index) {
    final commentController = TextEditingController();


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add a comment"),
          content: SingleChildScrollView( // Make the content scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const SizedBox(height: 10),
    
                const SizedBox(height: 10),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(hintText: "Write your comment here"),
                ),
                const SizedBox(height: 10),
                // Image upload button
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _pickedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: Text("Upload an Image"),
                ),
                if (_pickedImage != null) // Show selected image preview
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Image.file(_pickedImage!, width: 100, height: 100),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (commentController.text.isNotEmpty ) {
                  setState(() {
                    pins[index]["comments"].add({
                      "username": "NewUser", // Add a default or dynamic username here
                      "handle": "@NewUserHandle", // Add a default or dynamic handle here
                      "comment": commentController.text,
                      "image": _pickedImage != null ? _pickedImage!.path : '',
                    });

                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // Function to navigate to the view pin screen
  void viewPinDetails(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinDetailsScreen(pin: pins[index]),
      ),
    );
  }

  // Function to filter pins based on the search query
  List<Map<String, dynamic>> getFilteredPins() {
    return pins.where((pin) {
      return pin["title"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pin["comments"].any((comment) =>
              comment["username"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              comment["handle"].toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore Pins"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              decoration: InputDecoration(
                hintText: "Search for pins or usernames",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Community Pins Section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Community Pins",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...getFilteredPins().map((pin) {
                    int pinIndex = pins.indexOf(pin);
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pin["title"],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Rated: ${pin["rating"]} ⭐"),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    pin["liked"] == true
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_alt_outlined,
                                    color: pin["liked"] == true ? Colors.blue : Colors.grey,
                                  ),
                                  onPressed: () => setState(() {
                                    pin["liked"] = !(pin["liked"] ?? false);
                                  }),
                                ),
                                IconButton(
                                  icon: Icon(Icons.comment),
                                  onPressed: () => showCommentDialog(pinIndex),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            if (pin["comments"].isNotEmpty)
                              ElevatedButton(
                                onPressed: () => viewPinDetails(pinIndex),
                                child: Text("View Comments"),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PinDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> pin;

  const PinDetailsScreen({Key? key, required this.pin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pin["title"]),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView( // Make the comments section scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pin["title"],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Location: ${pin["location"]}"),
              SizedBox(height: 8),
              Text("Rating: ${pin["rating"]} ⭐"),
              SizedBox(height: 16),
              Text("Comments:"),
              SizedBox(height: 8),
              // Show all the comments for the pin
              for (var comment in pin["comments"])
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        "${comment["username"]}:",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      SizedBox(width: 5),
                      Text(
                        comment["handle"],
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment["comment"], style: TextStyle(color: Colors.grey[700])),
                      if (comment["image"] != null && comment["image"].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: comment["image"].startsWith("http")
                              ? Image.network(comment["image"])
                              : Image.file(File(comment["image"])), // Handle both remote and local images
                        ),

                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
