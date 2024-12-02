import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime initialDate;
  final String userId; // Pass user ID to identify the account
  final String username;

  CalendarScreen({required this.initialDate, required this.userId, required this.username});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedEvents;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  TimeOfDay _eventTime = TimeOfDay.now();
  bool _isPublic = false; // Track public/private status for the event

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate;
    _selectedEvents = ValueNotifier([]);
    _loadEventsForDay(_selectedDay);
  }

  Future<void> _loadEventsForDay(DateTime date) async {
    final String formattedDate = _formatDate(date);

    QuerySnapshot snapshot = await _firestore
        .collection('events')
        .where('date', isEqualTo: formattedDate)
        .where('userId', isEqualTo: widget.userId) // Filter by user ID
        .get();

    List<Map<String, dynamic>> events = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'username': doc['username'],
        'description': doc['description'],
        'time': doc['time'],
        'location': doc['location'] ?? 'No location provided',
        'isPublic': doc['isPublic'],
      };
    }).toList();

    _selectedEvents.value = events;
  }

  Future<void> _addEventToFirestore(
      String description, String time, String location) async {
    final String formattedDate = _formatDate(_selectedDay);

    await _firestore.collection('events').add({
      'userId': widget.userId, // Associate event with the user
      'username': widget.username,
      'date': formattedDate,
      'description': description,
      'time': time,
      'location': location,
      'isPublic': _isPublic, // Save public/private status
      'timestamp': Timestamp.now(),
    });

    _loadEventsForDay(_selectedDay);
  }

  Future<void> _editEvent(String eventId, String description, String time,
      String location, bool isPublic) async {
    await _firestore.collection('events').doc(eventId).update({
      'description': description,
      'time': time,
      'location': location,
      'isPublic': isPublic,
    });

    _loadEventsForDay(_selectedDay);
  }

  Future<void> _deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
    _loadEventsForDay(_selectedDay);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _eventTime,
    );

    if (picked != null) {
      setState(() {
        _eventTime = picked;
        _timeController.text = _eventTime.format(context);
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _showEditDialog(Map<String, dynamic> event) {
    _activityController.text = event['description'];
    _timeController.text = event['time'];
    _locationController.text = event['location'];
    _isPublic = event['isPublic'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Event"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _activityController,
                    decoration: InputDecoration(hintText: "Activity Name"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      hintText: "Select Time",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () => _selectTime(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(context),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(hintText: "Location (optional)"),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Public Event"),
                      Switch(
                        value: _isPublic,
                        onChanged: (value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_activityController.text.isNotEmpty &&
                        _timeController.text.isNotEmpty) {
                      _editEvent(
                        event['id'],
                        _activityController.text,
                        _timeController.text,
                        _locationController.text.isNotEmpty
                            ? _locationController.text
                            : 'No location provided',
                        _isPublic,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title:  Text(
          'Calendar',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadEventsForDay(selectedDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: HeaderStyle(
              titleCentered: true, 
              formatButtonVisible: false, 
              titleTextStyle: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 175, 13, 175), 
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
              availableCalendarFormats: const {
            CalendarFormat.month: 'Month', // Change label to "Month"
           
          },
          ),
          const SizedBox(height: 16),
          Text(
            'Activities for ${_formatDate(_selectedDay)}',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text(event['description']),
                      subtitle: Text(
                          "${event['time']} at ${event['location']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(event),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteEvent(event['id']),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _activityController.clear();
          _timeController.clear();
          _locationController.clear();
          _isPublic = false; // Reset the public/private switch

          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text("Add Event"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _activityController,
                          decoration: InputDecoration(hintText: "Activity Name"),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _timeController,
                          decoration: InputDecoration(
                            hintText: "Select Time",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.access_time),
                              onPressed: () => _selectTime(context),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectTime(context),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _locationController,
                          decoration: InputDecoration(hintText: "Location (optional)"),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Public Event"),
                            Switch(
                              value: _isPublic,
                              onChanged: (value) {
                                setState(() {
                                  _isPublic = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_activityController.text.isNotEmpty &&
                              _timeController.text.isNotEmpty) {
                            _addEventToFirestore(
                              _activityController.text,
                              _timeController.text,
                              _locationController.text.isNotEmpty
                                  ? _locationController.text
                                  : 'No location provided',
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text("Save"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
