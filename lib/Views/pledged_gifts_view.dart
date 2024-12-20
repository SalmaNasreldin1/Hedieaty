import 'package:flutter/material.dart';
import '../Controllers/gift_controller.dart';

class PledgedGiftsPage extends StatefulWidget {
  final String userId; // Current user's ID

  const PledgedGiftsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final GiftController _giftController = GiftController();
  String selectedFilter = 'For Me';
  List<Map<String, dynamic>> displayedGifts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    print(widget.userId);
    if (selectedFilter == 'For Me') {
      List<Map<String, dynamic>> gifts = await _giftController.fetchGiftsForUser(widget.userId);
      print(gifts);
      setState(() {
        displayedGifts = gifts;
      });
    } else if (selectedFilter == 'From Me') {
      List<Map<String, dynamic>> gifts = await _giftController.fetchGiftsPledgedByUser(widget.userId);
      print(gifts);
      setState(() {
        displayedGifts = gifts;
      });
    }
  }

  Future<void> _toggleGiftStatus(int giftId, String currentStatus) async {
    String newStatus = currentStatus == 'pledged' ? 'purchased' : 'pledged';
    await _giftController.updateGift(giftId, {'status': newStatus});
    _loadGifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Pledged Gifts',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
                      hintText: 'Search Gifts...',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                // Filter Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FilterButton(
                      label: 'For Me',
                      isSelected: selectedFilter == 'For Me',
                      onTap: () {
                        setState(() {
                          selectedFilter = 'For Me';
                          _loadGifts();
                        });
                      },
                    ),
                    _FilterButton(
                      label: 'From Me',
                      isSelected: selectedFilter == 'From Me',
                      onTap: () {
                        setState(() {
                          selectedFilter = 'From Me';
                          _loadGifts();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Gifts List
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedGifts.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> gift = displayedGifts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          title: Text(gift['name']),
                          subtitle: Text(
                            selectedFilter == 'For Me'
                                ? 'Pledged By: ${gift['PledgedByName']} | Deadline: ${gift['Deadline']}'
                                : 'Gift Owner: ${gift['OwnerName']} | Deadline: ${gift['Deadline']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                color: gift['status'] == 'purchased' ? Colors.green : Colors.grey,
                              ),
                              if (selectedFilter == 'For Me') ...[
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () => _toggleGiftStatus(
                                    gift['id'],
                                    gift['status'],
                                  ),
                                ),
                              ],
                            ],
                          ),
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
    );
  }
}

// FilterButton Component
class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
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
