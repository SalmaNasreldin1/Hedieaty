// GiftListPage.dart
import 'package:flutter/material.dart';
import 'GiftDetailsPage.dart';

class GiftListPage extends StatefulWidget {
  final String eventName;

  const GiftListPage({super.key, required this.eventName});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Map<String, dynamic>> gifts = [
    {'name': 'Phone', 'category': 'Electronics', 'status': 'Pledged', 'price': '\$200'},
    {'name': 'Watch', 'category': 'Accessories', 'status': 'Pending', 'price': '\$100'},
  ];

  String selectedFilter = 'All';

  void _sortGifts(String criteria) {
    setState(() {
      if (criteria == 'Name') {
        gifts.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (criteria == 'Category') {
        gifts.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (criteria == 'Status') {
        gifts.sort((a, b) => a['status'].compareTo(b['status']));
      }
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
          widget.eventName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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

                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 5, blurRadius: 10),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                'Gifts',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ),
                            // Filter Buttons
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  FilterButton(label: 'All', isSelected: selectedFilter == 'All', onTap: () => _sortGifts('All')),
                                  FilterButton(label: 'Name', isSelected: selectedFilter == 'Name', onTap: () => _sortGifts('Name')),
                                  FilterButton(label: 'Category', isSelected: selectedFilter == 'Category', onTap: () => _sortGifts('Category')),
                                  FilterButton(label: 'Status', isSelected: selectedFilter == 'Status', onTap: () => _sortGifts('Status')),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: gifts.length,
                                itemBuilder: (context, index) {
                                  final gift = gifts[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    child: ListTile(
                                      title: Text(gift['name']),
                                      subtitle: Text('Category: ${gift['category']} | Price: ${gift['price']}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.circle, color: gift['status'] == 'Pledged' ? Colors.orangeAccent : Colors.deepPurple.shade100),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.grey),
                                            onPressed: gift['status'] == 'Pledged'
                                                ? null
                                                : () {
                                              setState(() {
                                                gifts.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GiftDetailsPage(
                                              giftName: gift['name'],
                                              category: gift['category'],
                                              price: gift['price'],
                                              status: gift['status'],
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
