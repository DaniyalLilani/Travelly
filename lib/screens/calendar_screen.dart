import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime initialDate;

  CalendarScreen({required this.initialDate});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<String>> _selectedEvents;
  late final CalendarFormat _calendarFormat;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final Map<DateTime, List<String>> _events = {};
  TextEditingController _activityController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TimeOfDay _eventTime = TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _calendarFormat = CalendarFormat.month;
    _selectedDay = widget.initialDate;
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ) ?? TimeOfDay.now();

    setState(() {
      _eventTime = picked;
      _timeController.text = _eventTime.format(context);
    });
  }

  void _addEvent(String activityName, String time, String location, DateTime selectedDate) {
    if (_events[selectedDate] == null) {
      _events[selectedDate] = [];
    }
    setState(() {
      _events[selectedDate]!.add('$activityName at $time in $location');
      _selectedEvents.value = _getEventsForDay(selectedDate); // Update the UI
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
            'Explore',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TableCalendar<String>(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents.value = _getEventsForDay(selectedDay);
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Colors.white),
              weekendTextStyle: TextStyle(color: Colors.black),
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(color: Colors.black),
              formatButtonTextStyle: TextStyle(color: Colors.black),
              formatButtonDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            calendarFormat: _calendarFormat,
          ),
          const SizedBox(height: 16),
          Text(
            'Your activities on ${_selectedDay.toLocal().toString().split(' ')[0]}',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add an Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Add Activity'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _activityController,
                              decoration: const InputDecoration(hintText: 'Activity Name'),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _timeController,
                              decoration: InputDecoration(
                                hintText: 'Select Time',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.access_time),
                                  onPressed: () => _selectTime(context),
                                ),
                              ),
                              readOnly: true,
                              onTap: () => _selectTime(context),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _locationController,
                              decoration: const InputDecoration(hintText: 'Location (optional)'),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (_activityController.text.isNotEmpty && _timeController.text.isNotEmpty) {
                                    _addEvent(
                                      _activityController.text,
                                      _timeController.text,
                                      _locationController.text.isNotEmpty
                                          ? _locationController.text
                                          : 'No location provided',
                                      _selectedDay,
                                    );
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add Activity'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<List<String>>(
            valueListenable: _selectedEvents,
            builder: (context, events, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: events.map((event) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      tileColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Text(
                        event.split(' at ')[0],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        event.split(' at ')[1],
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _events[_selectedDay]!.remove(event);
                            _selectedEvents.value = _getEventsForDay(_selectedDay);
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
