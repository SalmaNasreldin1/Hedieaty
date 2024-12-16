// import 'package:flutter/material.dart';
//
// class EventListPage extends StatefulWidget {
//   @override
//   _EventListPageState createState() => _EventListPageState();
// }
//
// class _EventListPageState extends State<EventListPage> {
//   List<String> events = ['John\'s Birthday', 'Wedding Anniversary'];
//   String selectedFilter = 'All'; // Set 'All' as the default selected filter
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           'Event List',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Stack(
//         children: [
//           // Gradient background
//           Container(
//             height: 170,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.purple.shade300,
//                   Colors.deepOrange.shade200,
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//
//           // Foreground content inside SafeArea
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Search Bar
//                   TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Search Events...',
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.filter_list),
//                         onPressed: () {
//                           // Filtering logic here
//                         },
//                       ),
//                       fillColor: Colors.white,
//                       filled: true,
//                       contentPadding: const EdgeInsets.symmetric(vertical: 10),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30.0),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onChanged: (value) {
//                       // Search functionality logic here
//                     },
//                   ),
//                   const SizedBox(height: 15),
//
//                   // Category Filter Buttons
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         FilterButton(
//                           label: 'All',
//                           isSelected: selectedFilter == 'All',
//                           onTap: () => setState(() {
//                             selectedFilter = 'All';
//                           }),
//                         ),
//                         FilterButton(
//                           label: 'My Events',
//                           isSelected: selectedFilter == 'My Events',
//                           onTap: () => setState(() {
//                             selectedFilter = 'My Events';
//                           }),
//                         ),
//                         FilterButton(
//                           label: 'Status',
//                           isSelected: selectedFilter == 'Status',
//                           onTap: () => setState(() {
//                             selectedFilter = 'Status';
//                           }),
//                         ),
//                         FilterButton(
//                           label: 'Category',
//                           isSelected: selectedFilter == 'Category',
//                           onTap: () => setState(() {
//                             selectedFilter = 'Category';
//                           }),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // List of Events
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: events.length,
//                       itemBuilder: (context, index) {
//                         return Card(
//                           color: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: ListTile(
//                             title: Text(events[index]),
//                             subtitle: const Text('Category: Birthday | Status: Upcoming'),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.orangeAccent),
//                                   onPressed: () {
//                                     // Edit event
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.black45),
//                                   onPressed: () {
//                                     setState(() {
//                                       events.removeAt(index); // Delete event
//                                     });
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//
//       // Floating Action Button for adding new events
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.purple.shade100,
//         onPressed: () {
//           // Add a new event
//           setState(() {
//             events.add('New Event'); // Dynamically add events
//           });
//         },
//         child: const Icon(Icons.add, color: Colors.purple,),
//       ),
//     );
//   }
// }
//
// // Widget for Filter Buttons with conditional styling
// class FilterButton extends StatelessWidget {
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const FilterButton({
//     Key? key,
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.orange.shade50 : Colors.purple.shade50,
//             border: Border.all(
//               color: isSelected ? Colors.deepOrangeAccent.shade200 : Colors.purple,
//             ),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? Colors.deepOrangeAccent.shade200 : Colors.purple,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'GiftListPage.dart';
import 'Controllers/signin_controller.dart';


class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final SignInController signInController = SignInController();
  List<String> events = ['My Birthday', 'My Wedding Anniversary'];
  String selectedFilter = 'All';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
          // Foreground content with rounded, shadowed subpage starting below the search bar
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
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          // Filtering logic here
                        },
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
                      // Search functionality logic here
                    },
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // Subpage with rounded corners and shadow effect
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Category Filter Buttons
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  FilterButton(
                                    label: 'All',
                                    isSelected: selectedFilter == 'All',
                                    onTap: () => setState(() {
                                      selectedFilter = 'All';
                                    }),
                                  ),
                                  FilterButton(
                                    label: 'My Events',
                                    isSelected: selectedFilter == 'My Events',
                                    onTap: () => setState(() {
                                      selectedFilter = 'My Events';
                                    }),
                                  ),
                                  FilterButton(
                                    label: 'Status',
                                    isSelected: selectedFilter == 'Status',
                                    onTap: () => setState(() {
                                      selectedFilter = 'Status';
                                    }),
                                  ),
                                  FilterButton(
                                    label: 'Category',
                                    isSelected: selectedFilter == 'Category',
                                    onTap: () => setState(() {
                                      selectedFilter = 'Category';
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // List of Events
                            Expanded(
                              child: ListView.builder(
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ListTile(
                                      title: Text(events[index]),
                                      subtitle: const Text(
                                        'Category: Birthday | Status: Upcoming',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.orangeAccent),
                                            onPressed: () {
                                              // Edit event
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.black45),
                                            onPressed: () {
                                              setState(() {
                                                events.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        // Navigate to GiftListPage when tapped
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GiftListPage(eventName: events[index]),
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

      // Floating Action Button for adding new events
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade100,
        onPressed: () {
          setState(() {
            events.add('New Event');
          });
        },
        child: const Icon(Icons.add, color: Colors.purple),
      ),
    );
  }
}

// Widget for Filter Buttons with conditional styling
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
              color: isSelected ? Colors.deepOrangeAccent.shade200 : Colors.purple,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.deepOrangeAccent.shade200 : Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

