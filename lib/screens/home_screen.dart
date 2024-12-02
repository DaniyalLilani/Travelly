import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchUpcomingEvents();
  }

  // Fetch upcoming events from Firebase
  Future<void> _fetchUpcomingEvents() async {
    FirebaseFirestore.instance
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: DateTime.now().toString())
        .where('isPublic', isEqualTo: true) // Fetch only public events
        .orderBy('date') // Sort by date
        .limit(5) // Limit to next 5 events
        .get()
        .then((snapshot) {
      setState(() {
        _allEvents = snapshot.docs.map((doc) {
          return {
            'eventName': doc['description'],
            'eventUser': doc['userId'],
            'eventTime': doc['time'],
            'eventDate': doc['date'],
            'eventId': doc.id,
            'location': doc['location'] ?? 'No location provided',
          };
        }).toList();
        _filteredEvents = _allEvents; // Initialize filtered events
      });
    });
  }

  // Function to filter events based on search query
  void _filterEvents(String query) {
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        return event['eventName'].toLowerCase().contains(query.toLowerCase()) ||
            event['eventTime'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.black 
        : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white 
                : Colors.black, 
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (query) => _filterEvents(query),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search for events near you',
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Display filtered events
            for (var event in _filteredEvents)
              EventCard(
                eventName: event['eventName'],
                eventDate: event['eventDate'],
                onViewDetails: () {
                  // Navigate to EventDetailsScreen with the eventId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(
                        eventId: event['eventId'], // Pass eventId
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      );
    }
  }

class EventCard extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final VoidCallback onViewDetails;

  const EventCard({
    Key? key,
    required this.eventName,
    required this.eventDate,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          eventName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(eventDate),
        trailing: ElevatedButton.icon(
          onPressed: onViewDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.info),
          label: const Text('View Details'),
        ),
      ),
    );
  }
}

class EventDetailsScreen extends StatelessWidget {
  final String eventId;

  EventDetailsScreen({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('events').doc(eventId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Event Details')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Event Details')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text('Event Details')),
            body: Center(child: Text('Event not found')),
          );
        }

        final eventData = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(title: Text('Event Details')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventData['description'] ?? 'No description',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Time: ${eventData['time']}',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Location: ${eventData['location']}',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${eventData['date']}',
                  style: TextStyle(fontSize: 18),
                ),
                    Text(
              'User: ${eventData['userId'].split('@')[0]}',
              style: TextStyle(fontSize: 18),
              ),

              ],
            ),
          ),
        );
      },
    );
  }
}
