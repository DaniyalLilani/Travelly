import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/database_helper.dart'; // Import the SQLite helper class

/************************************** 
NEXT ITERATION.
LOAD ALL PINS AND COMMENTS FROM FIREBASE
PUSH THEM TO FIREBASE
CACHE RESULTS LOCALLY (which we are doing with local edits right now)
THIS WILL ALLOW FOR A FUTURE OFFLINE MODE
FOR TA: In terms of the midpoint checkin, this is our local storage implementation

Firebase ---> SQflite --> User ---> SQflite 
                           |
                           |
                           | ------> Firebase
***************************************/



class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  //list of pins with location, rating , comments.. each pin has info like title, rating, location, image
  List<Map<String, dynamic>> pins = [
    {
      "title": "Tokyo Skytree",
      "rating": 4,
      "location": "Tokyo, Japan",
      "image": "https://www.datocms-assets.com/101439/1697302363-tokyo-skytree.webp?auto=format&fit=max&w=1200",
      "comments": [
    // Gets filled with user inputs
       
      ]
    },
    {
      "title": "Great Local Restaurant",
      "rating": 5,
      "location": "Shibuya, Tokyo",
      "image": "",
      "comments": [
      ]
    },
  ];

  File? _pickedImage; //stores image file picked by the user
  String _searchQuery = '';//keeps track of the search query entered by the user
  //opens dialog box for adding comments to a pin, allowing for comment to be added
  void showCommentDialog(int index) async {
    final commentController = TextEditingController();
    final dbHelper = DatabaseHelper();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add a comment"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(hintText: "Write your comment here"),
                ),
                const SizedBox(height: 10),
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
                if (_pickedImage != null)
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
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (commentController.text.isNotEmpty) {
                  Map<String, String> newComment = { // change to use firebase commands.
                    "pinId": index.toString(),
                    "username": "NewUser",
                    "handle": "@NewUserHandle",
                    "comment": commentController.text,
                    "image": _pickedImage?.path ?? '',
                  };
                  int pinId = index;
                  await dbHelper.insertComment(newComment, pinId);
                  print(newComment);
                  setState(() {
                    print(newComment);
                    pins[index]["comments"].add(newComment);
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

  // navigates to a detailed page displaying details of selected pin
  void viewPinDetails(int index) async {
    final dbHelper = DatabaseHelper();
    final dbComments = await dbHelper.fetchComments(index);

    setState(() {
      pins[index]["comments"] = dbComments;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinDetailsScreen(pin: pins[index]),
      ),
    );
  }

  //filters the pins based on search query. checks title and comments
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Pins',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding( //search bar to filer pins based on input
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Community Pins",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              //iterate over each filtered pin to display its details in a card
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
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        //displays the rating
                        Text("Rated: ${pin["rating"]} ⭐",
                        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),),
                        SizedBox(height: 8),
                        //like and comment buttons
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                pin["liked"] == true ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
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
                        //buttons to view comments if any
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
        ],
      ),
    );
  }
}
//shows details of selected pin in seperated screen
class PinDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> pin;

  const PinDetailsScreen({Key? key, required this.pin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(pin["title"]),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pin["title"],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Location: ${pin["location"]}",
            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),),
            SizedBox(height: 8),
            Text("Rating: ${pin["rating"]} ⭐", 
            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),),
            SizedBox(height: 16),
            Text("Comments:"),
            SizedBox(height: 8),
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
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment["comment"], style: TextStyle(color: isDarkMode ? Colors.white : Colors.grey[700]),
                    ),
                    //if image is provided display it below comment
                    if (comment["image"] != null && comment["image"].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: comment["image"].startsWith("http")
                            ? Image.network(comment["image"]) //display network image
                            : Image.file(File(comment["image"])),//display local file
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
