import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controllers/friends_event_controller.dart';
import 'friend_gift_list.dart';

class FriendEventListPage extends StatefulWidget {
  final String friendFirebaseId;
  final String friendName;

  const FriendEventListPage({
    Key? key,
    required this.friendFirebaseId,
    required this.friendName,
  }) : super(key: key);

  @override
  _FriendEventListPageState createState() => _FriendEventListPageState();
}

class _FriendEventListPageState extends State<FriendEventListPage> {
  final FriendEventController _friendEventController = FriendEventController();
  List<Map<String, dynamic>> events = [];
  String selectedFilter = 'All';
  List<Map<String, dynamic>> displayedEvents = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFriendEvents();
  }

  Future<void> _loadFriendEvents() async {
    final data = await _friendEventController.fetchFriendEvents(widget.friendFirebaseId);
    setState(() {
      events = data;
      _applyFilters();
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

  String _getEventStatus(String date) {
    DateTime eventDate = DateTime.parse(date);
    DateTime today = DateTime.now();
    eventDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
    today = DateTime(today.year, today.month, today.day);

    if (eventDate.isAfter(today)) return 'Upcoming';
    if (eventDate.isAtSameMomentAs(today)) return 'Current';
    return 'Passed';
  }

  String selectedSortOption = 'None';

  void _applySorting() {
    List<Map<String, dynamic>> sortedEvents = List<Map<String, dynamic>>.from(displayedEvents);

    if (selectedSortOption == 'Name') {
      sortedEvents.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (selectedSortOption == 'Category') {
      sortedEvents.sort((a, b) => a['category'].compareTo(b['category']));
    } else if (selectedSortOption == 'Status') {
      sortedEvents.sort((a, b) => _getEventStatus(a['date']).compareTo(_getEventStatus(b['date'])));
    }

    setState(() {
      displayedEvents = sortedEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "${widget.friendName}'s Events",
          style: const TextStyle(
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
                      suffixIcon: DropdownButton<String>(
                        value: selectedSortOption,
                        icon: const Icon(Icons.sort),
                        underline: Container(), // Removes the underline
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedSortOption = newValue;
                              _applySorting(); // Apply sorting logic
                            });
                          }
                        },
                        items: <String>[
                          'None',
                          'Name',
                          'Category',
                          'Status'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
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
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FriendGiftListPage(
                                              friendEventId: event['firebase_id'], // Pass the event ID
                                              friendEventName: event['name'],     // Pass the event name
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
