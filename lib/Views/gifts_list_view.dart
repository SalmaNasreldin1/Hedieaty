import 'package:flutter/material.dart';
import '../Controllers/gift_controller.dart';
import 'gift_details_view.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../Controllers/signin_controller.dart';
import '../Controllers/friend_gift_controller.dart';



class GiftListPage extends StatefulWidget {
  final String eventId;
  final String eventName;

  const GiftListPage({Key? key, required this.eventId, required this.eventName})
      : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftController _giftController = GiftController();
  final FriendGiftController _friendGiftController = FriendGiftController();
  final SignInController signInController = SignInController();
  List<Map<String, dynamic>> gifts = [];
  String selectedFilter = 'All';
  String searchQuery = '';
  String sortBy = 'None'; // Default sort by name

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    final data = await _giftController.fetchGifts(widget.eventId);
    setState(() {
      gifts = data;
      _applyFilters();
    });
  }

  void _togglePledgeStatus(Map<String, dynamic> gift, int index, String userId) async {
    final isPledged = gift['status'] == 'pledged';

    try {
      // Update the status in Firebase
      await _friendGiftController.togglePledgeStatus(gift['firebase_id'], !isPledged, userId);

      // Update the local state after a successful Firebase update
      setState(() {
        gifts[index]['status'] = !isPledged ? 'pledged' : 'available';
        gifts[index]['pledged_by'] = !isPledged ? userId : ''; // Update local data
      });
    } catch (e) {
      print(e);
      // Handle errors (e.g., network issues)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating pledge status: $e')),
      );
    }
  }

  void _applyFilters() {
    // Create a mutable copy of the gifts list
    List<Map<String, dynamic>> filteredGifts = List.from(gifts);

    // Apply the search query
    if (searchQuery.isNotEmpty) {
      filteredGifts = filteredGifts
          .where((gift) =>
      gift['name']?.toLowerCase().contains(searchQuery.toLowerCase()) ??
          false)
          .toList();
    }

    // Apply sorting if not "None"
    if (sortBy == 'Name') {
      filteredGifts.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    } else if (sortBy == 'Category') {
      filteredGifts.sort((a, b) =>
          (a['category'] ?? '').compareTo(b['category'] ?? ''));
    } else if (sortBy == 'Status') {
      filteredGifts.sort((a, b) =>
          (a['status'] ?? '').compareTo(b['status'] ?? ''));
    } else if (sortBy == 'Price') {
      filteredGifts.sort((a, b) =>
          (a['price'] ?? 0.0).compareTo(b['price'] ?? 0.0));
    }

    // Update the displayed gifts
    setState(() {
      gifts = filteredGifts;
    });
  }



  Future<void> _showGiftDialog({Map<String, dynamic>? gift}) async {
    final nameController = TextEditingController(text: gift?['name'] ?? '');
    final descriptionController = TextEditingController(text: gift?['description'] ?? '');
    final categoryController = TextEditingController(text: gift?['category'] ?? '');
    final priceController = TextEditingController(text: gift?['price']?.toString() ?? '');
    final imageUrlController = TextEditingController(text: gift?['imageLink'] ?? '');
    bool isPledged = gift?['status'] == 'pledged';
    bool isPublished = gift?['published'] == 1;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(gift == null ? 'Add Gift' : 'Edit Gift'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Gift Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                    CheckboxListTile(
                      title: const Text('Publish Gift'),
                      value: isPublished,
                      onChanged: (bool? value) {
                        setState(() {
                          isPublished = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Pledged'),
                      value: isPledged,
                      onChanged: gift == null
                          ? (value) {
                        setState(() {
                          isPledged = value ?? false;
                        });
                      }
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: imageUrlController.text.isNotEmpty
                              ? NetworkImage(imageUrlController.text) // Display the entered image URL
                              : const AssetImage('assets/gift_placeholder.png')
                          as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and Price are required')),
                  );
                  return;
                }

                final giftData = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'category': categoryController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'status': isPledged ? 'pledged' : 'available',
                  'pledged_by': isPledged ? await signInController.getUserUID() : '',
                  'event_id': widget.eventId,
                  'published': isPublished ? 1 : 0,
                  'imageLink': imageUrlController.text, // Save the URL link
                };

                if (gift == null) {
                  await _giftController.addGift(giftData);
                } else {
                  await _giftController.updateGift(gift['id'], giftData);
                }

                Navigator.pop(context);
                _loadGifts();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }



  void _navigateToGiftDetails(Map<String, dynamic> gift) async {
    final updatedGift = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(gift: gift),
      ),
    );

    if (updatedGift != null) {
      setState(()  {
        final index = gifts.indexWhere((g) => g['id'] == updatedGift['id']);
        if (index != -1) {
          gifts[index] = updatedGift; // Update the gift in the list
        }
         _loadGifts();
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Gifts for ${widget.eventName}',
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
                // Search Bar with Sorting Icon
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Gifts...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: DropdownButton<String>(
                        value: sortBy, // Ensure the default value is in the list
                        icon: const Icon(Icons.sort),
                        underline: Container(), // Removes the underline
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              sortBy = newValue;
                              _applyFilters(); // Reapply filters and sorting
                            });
                          }
                        },
                        items: <String>[
                          'None',
                          'Name',
                          'Category',
                          'Status',
                          'Price',
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
                        child: ListView.builder(
                          itemCount: gifts.length,
                          itemBuilder: (context, index) {
                            final gift = gifts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                leading: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: gift['imageLink'] != null && gift['imageLink'].isNotEmpty
                                          ? NetworkImage(gift['imageLink']) // Use NetworkImage for the URL
                                          : const AssetImage('assets/gift_placeholder.png') as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                    color: Colors.grey[200],
                                  ),
                                ),
                                title: Text(gift['name']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Category: ${gift['category']}'),
                                    Text('Price: \$${gift['price']}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Visual indicator for pledged status
                                    // IconButton(
                                    //   icon: Icon(
                                    //     Icons.card_giftcard,
                                    //     color: gift['status'] == 'pledged'
                                    //         ? Colors.orangeAccent
                                    //         : Colors.grey,
                                    //   ),
                                    //   onPressed: () async {
                                    //     try {
                                    //       // Retrieve the user's Firebase ID asynchronously
                                    //       final userId = await signInController.getUserUID(); // Replace with your actual future function
                                    //
                                    //       print(gift);
                                    //       // Call the _togglePledgeStatus function with the retrieved user ID
                                    //       _togglePledgeStatus(gift,index,userId!);
                                    //     } catch (e) {
                                    //       // Handle potential errors
                                    //       print (e);
                                    //       ScaffoldMessenger.of(context).showSnackBar(
                                    //         SnackBar(content: Text('Error: ${e.toString()}')),
                                    //       );
                                    //     }
                                    //   } ,
                                    // ),
                                    // Publish/unpublish button
                                    IconButton(
                                      icon: Icon(
                                        Icons.cloud_download_rounded,
                                        color: gift['published'] == 1 ? Colors.green : Colors.red,
                                      ),
                                      onPressed: () async {
                                        try {
                                          // Create a copy of the gift to update
                                          Map<String, dynamic> updatedGift = Map<String, dynamic>.from(gift);

                                          if (gift['published'] == 1) {
                                            // Unpublish the gift
                                            await _giftController.unpublishGift(updatedGift);
                                            updatedGift['published'] = 0;
                                          } else {
                                            // Publish the gift
                                            await _giftController.publishGift(updatedGift);
                                            updatedGift['published'] = 1;
                                          }

                                          // Update the gift list
                                          setState(() {
                                            gifts = List<Map<String, dynamic>>.from(gifts);
                                            gifts[index] = updatedGift;
                                          });
                                        } catch (e) {
                                          print(e);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error: ${e.toString()}')),
                                          );
                                        }
                                      },
                                    ),
                                    // Delete button
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.black45),
                                      onPressed: gift['status'] == 'pledged'
                                          ? null
                                          : () async {
                                        await _giftController.deleteGift(gift);
                                        _loadGifts();
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () => _navigateToGiftDetails(gift),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade100,
        onPressed: () => _showGiftDialog(),
        child: const Icon(Icons.add, color: Colors.purple),
      ),
    );
  }
}

