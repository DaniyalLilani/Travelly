import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
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
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search for events near you',
              filled: true,
              fillColor: Colors.grey[200],
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
          // Event Card 1
          EventCard(
            eventName: 'Tokyo Ramen Festa',
            eventTime: '10 AM - 3 PM, Central Park',
            onAddToCalendar: () {
            },
          ),
          const SizedBox(height: 8),
          // Event Card 2 
          EventCard(
            eventName: 'Ikebukuro Halloween Festival',
            eventTime: '4 PM - 7 PM, Olympic Park',
            onAddToCalendar: () {
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Current Events',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Event Card 3 
          EventCard(
            eventName: 'Tokyo Sake Festival',
            eventTime: '9 PM - 12 AM, Central Park',
            onAddToCalendar: () {
            },
          ),
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