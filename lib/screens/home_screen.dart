import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  List<EventCard> _allEvents = [
    EventCard(eventName: 'Tokyo Ramen Festa', eventTime: '10 AM - 3 PM, Central Park', onAddToCalendar: () {}),
    EventCard(eventName: 'Ikebukuro Halloween Festival', eventTime: '4 PM - 7 PM, Olympic Park', onAddToCalendar: () {}),
    EventCard(eventName: 'Tokyo Sake Festival', eventTime: '9 PM - 12 AM, Central Park', onAddToCalendar: () {}),
  ]; // A sample list of events

  List<EventCard> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _filteredEvents = _allEvents; // Initialize with all events
    _searchController.addListener(_filterEvents);  // Add listener for search input
  }

  // Function to filter events based on search query
  void _filterEvents() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        return event.eventName.toLowerCase().contains(query) ||
               event.eventTime.toLowerCase().contains(query); // Filters based on event name or time
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Local Events',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search for events near you',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Render the filtered events
          for (var event in _filteredEvents) event,
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String eventName;
  final String eventTime;
  final VoidCallback onAddToCalendar;

  const EventCard({
    Key? key,
    required this.eventName,
    required this.eventTime,
    required this.onAddToCalendar,
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
        subtitle: Text(eventTime),
        trailing: ElevatedButton.icon(
          onPressed: onAddToCalendar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.calendar_today),
          label: const Text('Add to Calendar'),
        ),
      ),
    );
  }
}
