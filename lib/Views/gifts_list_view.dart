import 'package:flutter/material.dart';
import '../Controllers/gift_controller.dart';
import 'gift_details_view.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


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
  List<Map<String, dynamic>> gifts = [];

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    final data = await _giftController.fetchGifts(widget.eventId);
    setState(() {
      gifts = data;
    });
  }

  Future<void> _showGiftDialog({Map<String, dynamic>? gift}) async {
    final nameController = TextEditingController(text: gift?['name'] ?? '');
    final descriptionController = TextEditingController(text: gift?['description'] ?? '');
    final categoryController = TextEditingController(text: gift?['category'] ?? '');
    final priceController = TextEditingController(text: gift?['price']?.toString() ?? '');
    bool isPledged = gift?['status'] == 'pledged';
    bool isPublished = gift?['published'] == 1;
    File? selectedImage;

    // Load existing image if editing
    if (gift != null && gift['imageLink'] != null) {
      selectedImage = File(gift['imageLink']);
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(gift == null ? 'Add Gift' : 'Edit Gift'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Gift Name'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration:
                    const InputDecoration(labelText: 'Description'),
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
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          selectedImage = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : const Icon(Icons.add_a_photo, color: Colors.grey),
                    ),
                  ),
                ],
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
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Name and Price are required')),
                  );
                  return;
                }

                final giftData = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'category': categoryController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'status': isPledged ? 'pledged' : 'available',
                  'event_id': widget.eventId,
                  'published': isPublished ? 1 : 0,
                  'imageLink': selectedImage?.path, // Include published field
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
      setState(() {
        final index = gifts.indexWhere((g) => g['id'] == updatedGift['id']);
        if (index != -1) {
          gifts[index] = updatedGift; // Update the gift in the list
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gifts for ${widget.eventName}')),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return ListTile(
            leading:  Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), // Slightly rounded corners
                image: DecorationImage(
                  image: gift['imageLink'] != null
                      ? FileImage(File(gift['imageLink']))
                      : const AssetImage('assets/gift_placeholder.png') as ImageProvider,
                  fit: BoxFit.cover, // Ensures the image fits the container
                ),
                color: Colors.grey[200], // Background color for placeholder
              ),
            ),
            title: Text(gift['name']),
            subtitle: Text('Category: ${gift['category']}'),
            trailing:  Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black45),
                  onPressed:
                  gift['status'] == 'pledged'? null:
                      () async {
                    await _giftController.deleteGift(gift);
                    _loadGifts();
                  },
                ),
              ],
            ),
            onTap: () => _navigateToGiftDetails(gift),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGiftDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
