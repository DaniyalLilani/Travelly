import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime initialDate;
  //constructor which takes the initial date
  CalendarScreen({required this.initialDate});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  //notifier for events on selected day, allows us to update ui reactiviely 
  late final ValueNotifier<List<String>> _selectedEvents;
  //tracks the calendar format
  late final CalendarFormat _calendarFormat;
  //tracks the selected and currently viewed days
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  // Map to store events, where each date has a list of event descriptions
  final Map<DateTime, List<String>> _events = {};
  // Controllers for input fields in the add event dialog
  TextEditingController _activityController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TimeOfDay _eventTime = TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    super.initState();
    // Initialize selected events and calendar format
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _calendarFormat = CalendarFormat.month;
    _selectedDay = widget.initialDate;
  }
  // Get events for a specific day from the map, or return an empty list if none exist
  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }
  // Function to show a time picker and update the time for an event
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
  // Function to add a new event to the selected date
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
              // ensure weekend text is visible in dark mode
              todayTextStyle: TextStyle(color: Colors.white),
              weekendTextStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,),
            ),
            headerStyle: HeaderStyle(
            titleTextStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black,
            ),
            formatButtonTextStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black,
            ),
            formatButtonDecoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[700] 
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

            calendarFormat: _calendarFormat,
          ),
          const SizedBox(height: 16),
          Text(
            'Your activities on ${_selectedDay.toLocal().toString().split(' ')[0]}',
            style: TextStyle(fontSize: 16, 
              color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.grey[600],),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add an Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Button to open the add activity dialog
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
                          children: [ //text field for activity name
                            TextField(
                              controller: _activityController,
                              decoration: const InputDecoration(hintText: 'Activity Name'),
                            ),
                            const SizedBox(height: 10),
                            // textfield to select time
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
                        actions: [
                          Column(
                            children: [
                              // "Save" button styled as purple with white text
                              ElevatedButton(
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // "Cancel" button styled as a white box with black text
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
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
                      tileColor: Theme.of(context).brightness == Brightness.dark 
                       ? Colors.grey[800] 
                        : Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Text(
                        event.split(' at ')[0],
                        style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black,),
                      ),
                      // Displaying event details with dynamic color based on mode
                      subtitle: Text(
                        event.split(' at ')[1],
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white 
                                        : Colors.grey[600],),
                      ),
                      //delete icon to remocve event
                      trailing: IconButton(
                        icon:  Icon(Icons.delete, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
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
