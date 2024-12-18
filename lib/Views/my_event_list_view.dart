import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controllers/my_event_list_controller.dart';
import '../Controllers/signin_controller.dart';
import 'gifts_list_view.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController _eventController = EventController();
  final SignInController _signInController = SignInController();
  List<Map<String, dynamic>> events = [];
  String selectedFilter = 'All';
  List<Map<String, dynamic>> displayedEvents = [];
  String searchQuery = '';


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
      _applyFilters(); // Update displayedEvents based on the current filter
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filteredEvents = events;

    // Apply the selected filter
    if (selectedFilter == 'Upcoming') {
      filteredEvents = filteredEvents
          .where((event) => _getEventStatus(event['date']) == 'Upcoming')
          .toList();
    } else if (selectedFilter == 'Current') {
      filteredEvents = filteredEvents
          .where((event) => _getEventStatus(event['date']) == 'Current')
          .toList();
    } else if (selectedFilter == 'Passed') {
      filteredEvents = filteredEvents
          .where((event) => _getEventStatus(event['date']) == 'Passed')
          .toList();
    }

    // Apply the search query
    if (searchQuery.isNotEmpty) {
      filteredEvents = filteredEvents
          .where((event) =>
          event['name'].toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Update the displayed events
    setState(() {
      displayedEvents = filteredEvents;
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Event List',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Colorful Watercolor Painting.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Events...',
                      prefixIcon: const Icon(Icons.search),
                      // suffixIcon: IconButton(
                      //   icon: const Icon(Icons.filter_list),
                      //   onPressed: () {},
                      // ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                // Filters and Event List
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Filter Buttons
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  FilterButton(
                                    label: 'All',
                                    isSelected: selectedFilter == 'All',
                                    onTap: () => setState(() {
                                      selectedFilter = 'All';
                                      _applyFilters();
                                    }),
                                  ),
                                  FilterButton(
                                    label: 'Upcoming',
                                    isSelected: selectedFilter == 'Upcoming',
                                    onTap: () => setState(() {
                                      selectedFilter = 'Upcoming';
                                      _applyFilters();
                                    }),
                                  ),
                                  FilterButton(
                                    label: 'Current',
                                    isSelected: selectedFilter == 'Current',
                                    onTap: () => setState(() {
                                      selectedFilter = 'Current';
                                      _applyFilters();
                                    }),
                                  ),
                                  FilterButton(
                                    label: 'Passed',
                                    isSelected: selectedFilter == 'Passed',
                                    onTap: () => setState(() {
                                      selectedFilter = 'Passed';
                                      _applyFilters();
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Event List
                            Expanded(
                              child: ListView.builder(
                                itemCount: displayedEvents.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> event = displayedEvents[index];
                                  String status = _getEventStatus(event['date']);

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ListTile(
                                      title: Text(event['name']),
                                      subtitle: Text(
                                          'Category: ${event['category']} | Status: $status'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                          icon: Icon(
                                            Icons.cloud_download_rounded,
                                            color: event['published'] == 1 ? Colors.green : Colors.red,
                                          ),
                                          onPressed: () async {
                                            try {
                                              // Create a copy of the event to update
                                              Map<String, dynamic> updatedEvent = Map<String, dynamic>.from(event);

                                              if (event['published'] == 1) {
                                                // Unpublish the event
                                                await _eventController.unpublishEvent(updatedEvent);
                                                updatedEvent['published'] = 0;
                                              } else {
                                                // Publish the event
                                                await _eventController.publishEvent(updatedEvent);
                                                updatedEvent['published'] = 1;
                                              }

                                              // Replace the event in the list with the updated event
                                              setState(() {
                                                events = List<Map<String, dynamic>>.from(events); // Ensure list is mutable
                                                events[index] = updatedEvent;
                                                _applyFilters();
                                              });
                                            } catch (e) {
                                              print(e);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error: ${e.toString()}')),
                                              );
                                            }
                                          },
                                        ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.orangeAccent),
                                            onPressed: () =>
                                                _showEventDialog(event: event),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.black45),
                                            onPressed: () async {
                                              await _eventController
                                                  .removeEvent(event['id'],event);
                                              _loadEvents();
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GiftListPage(
                                              eventId: event['firebase_id'], // Pass the event ID
                                              eventName: event['name'],     // Pass the event name
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade100,
        onPressed: () => _showEventDialog(),
        child: const Icon(Icons.add, color: Colors.purple),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.shade50 : Colors.purple.shade50,
            border: Border.all(
              color: isSelected
                  ? Colors.deepOrangeAccent.shade200
                  : Colors.purple,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.deepOrangeAccent.shade200
                  : Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
