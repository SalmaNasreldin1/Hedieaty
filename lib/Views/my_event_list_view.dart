import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controllers/my_event_list_controller.dart';
import '../Controllers/signin_controller.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController _eventController = EventController();
  final SignInController _signInController = SignInController();
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  /// Fetch events from SQLite and refresh the list
  Future<void> _loadEvents() async {
    List<Map<String, dynamic>> data = await _eventController.fetchEvents();
    setState(() {
      events = data;
    });
  }

  /// Show dialog for adding or editing events
  Future<void> _showEventDialog({Map<String, dynamic>? event}) async {
    final nameController = TextEditingController(text: event?['name'] ?? '');
    final dateController = TextEditingController(
      text: event?['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final locationController = TextEditingController(text: event?['location'] ?? '');
    final descriptionController = TextEditingController(text: event?['description'] ?? '');
    final categoryController = TextEditingController(text: event?['category'] ?? '');
    bool isPublished = event?['published'] == 1;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event == null ? 'Add Event' : 'Edit Event'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Event Name'),
                    ),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    CheckboxListTile(
                      title: const Text('Publish Event'),
                      value: isPublished,
                      onChanged: (bool? value) {
                        setState(() {
                          isPublished = value ?? false;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || dateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event Name and Date are required!')),
                  );
                  return;
                }

                try {
                  Map<String, dynamic> eventData = {
                    'id': event?['id'], // SQLite ID if editing
                    'name': nameController.text,
                    'date': dateController.text,
                    'location': locationController.text,
                    'description': descriptionController.text,
                    'category': categoryController.text,
                    'published': isPublished ? 1 : 0,
                    'firebase_id': event?['firebase_id'], // Retain existing firebase_id
                    'user_id': await _signInController.getUserUID(),
                  };

                  if (event == null) {
                    // Add new event
                    int newId = await _eventController.createEvent(eventData); // Returns SQLite ID
                    eventData['id'] = newId; // Set the SQLite ID in the eventData
                    if (isPublished) {
                      await _eventController.publishEvent(eventData); // Publish event
                    }
                  } else {
                    // Edit existing event
                    await _eventController.editEvent(event['id'], eventData);
                    if (isPublished && event['published'] == 0) {
                      await _eventController.publishEvent(eventData); // Publish event if not already published
                    } else if (!isPublished && event['published'] == 1) {
                      await _eventController.unpublishEvent(eventData); // Unpublish event if needed
                    }
                  }



                  Navigator.pop(context);
                  _loadEvents(); // Refresh event list
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Determine event status based on the date
  String _getEventStatus(String date) {
    DateTime eventDate = DateTime.parse(date);
    DateTime today = DateTime.now();
    eventDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
    today = DateTime(today.year, today.month, today.day);

    if (eventDate.isAfter(today)) return 'Upcoming';
    if (eventDate.isAtSameMomentAs(today)) return 'Current';
    return 'Passed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> event = events[index];
          String status = _getEventStatus(event['date']);

          return Card(
            child: ListTile(
              title: Text(event['name']),
              subtitle: Text(
                  'Category: ${event['category']} | Status: $status'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.cloud,
                      color: event['published'] == 1 ? Colors.green : Colors.red,
                    ),
                    onPressed: () async {
                      try {
                        if (event['published'] == 1) {
                          // Unpublish the event
                          await _eventController.unpublishEvent(event);
                          setState(() {
                            event['published'] = 0;
                          });
                        } else {
                          // Publish the event
                          await _eventController.publishEvent(event);
                          setState(() {
                            event['published'] = 1;
                          });
                        }
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEventDialog(event: event),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await _eventController.removeEvent(event['id']);
                      _loadEvents();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
